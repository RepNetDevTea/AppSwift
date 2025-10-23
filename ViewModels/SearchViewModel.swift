//
//  SearchViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

import Foundation
import Combine
import SwiftUI

// SearchState enum se mantiene igual
enum SearchState {
    case initial
    case loading
    case success([Site])
    case empty
    case error(String)
}

@MainActor
class SearchViewModel: ObservableObject {

    private let searchAPIService = SearchAPIService()
    private let reportsAPIService = ReportsAPIService() // Necesario para construir la lista base si la búsqueda de API falla
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()

    // Almacenes para mapeo
    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []

    @Published var searchQuery = ""
    @Published var state: SearchState = .initial
    @Published var errorMessage: String? = nil // Usado en el catch

    private var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await fetchInitialLookups()
        }
        setupSearchListener()
    }

    private func fetchInitialLookups() async {
        if case .initial = state { state = .loading }
        errorMessage = nil
        do {
            async let tags = tagsAndImpactsAPIService.fetchAllTags()
            async let impacts = tagsAndImpactsAPIService.fetchAllImpacts()
            self.allTags = try await tags
            self.allImpacts = try await impacts
            if case .loading = state { state = .initial }
        } catch {
            print("❌ Error al cargar listas de tags/impacts en Search: \(error)")
            self.state = .error("No se pudo preparar la búsqueda.")
        }
    }

    private func setupSearchListener() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                let trimmedQuery = query.trimmingCharacters(in: .whitespaces)

                if trimmedQuery.isEmpty {
                    self.state = .initial
                } else if trimmedQuery.contains(".") {
                     guard !self.allTags.isEmpty, !self.allImpacts.isEmpty else {
                         print("Lookups not ready for search yet.")
                         self.state = .error("Cargando datos iniciales...")
                         return
                     }
                    Task {
                        await self.performSearch(query: trimmedQuery)
                    }
                } else {
                    self.state = .initial
                    print("Query needs to include a domain extension like .com")
                }
            }
            .store(in: &cancellables)
    }

    // ✨ CORREGIDO: Maneja la respuesta opcional del servicio ✨
    func performSearch(query: String) async {
        state = .loading
        errorMessage = nil

        do {
            // Llama al servicio que ahora devuelve SiteResponseDTO?
            let siteDTO = try await searchAPIService.search(query: query)

            // Si el servicio devolvió un sitio...
            if let foundSiteDTO = siteDTO {
                // ...lo mapeamos...
                let site = mapSingleSiteDTOToSite(foundSiteDTO)
                // ...y lo ponemos en un array para el estado .success.
                state = .success([site])
            } else {
                // Si el servicio devolvió nil, significa que no se encontró.
                state = .empty
            }

        } catch APIError.invalidResponse(let statusCode) where statusCode == 500 {
             print("❌ Error 500 en la búsqueda: \(query)")
             state = .error("Error del servidor al buscar. Inténtalo de nuevo.")
        } catch {
            print("❌ Error en la búsqueda: \(error)")
            state = .error("No se pudieron obtener los resultados.")
        }
    }


    // --- MAPPING LOGIC ---

    // ✨ NUEVO: Helper para mapear UN solo SiteDTO a Site ✨
    private func mapSingleSiteDTOToSite(_ dto: SiteResponseDTO) -> Site {
        // Mapea los reportes anidados usando la lógica existente
        let reports = mapReportDTOsToReports(dto.reports)
        return Site(
            id: dto.id,
            domain: dto.siteDomain,
            reputationScore: dto.siteReputation,
            reports: reports
        )
    }

    // Mapea Report DTOs usando ID lookups (se mantiene igual)
    private func mapReportDTOsToReports(_ dtos: [ReportResponseDTO]) -> [Report] {
        let formatter = ISO8601DateFormatter()
        guard !allTags.isEmpty, !allImpacts.isEmpty else {
            print("⚠️ Attempted to map reports before lookups were loaded.")
            return []
        }
        let tagLookup = Dictionary(uniqueKeysWithValues: allTags.map { ($0.id, $0.tagName) })
        let impactLookup = Dictionary(uniqueKeysWithValues: allImpacts.map { ($0.id, $0.impactName) })

        return dtos.map { dto in
            let createdAtDate = formatter.date(from: dto.createdAt) ?? Date()

            var score = 0
            for vote in dto.votes {
                 if vote.voteType == "upvote" { score += 1 }
                 else if vote.voteType == "downvote" { score -= 1 }
            }

            // Mapeo ID -> Nombre
            let categoryNames = dto.tags.compactMap { tagLookup[$0.tagId] ?? "Categoría Desconocida" }
            let impactNames = dto.impacts.compactMap { impactLookup[$0.impactId] ?? "Impacto Desconocido" }
            let categoriesString = categoryNames.joined(separator: ", ")

            return Report(
                displayId: String(dto.id),
                title: dto.reportTitle,
                date: createdAtDate.formatted(date: .long, time: .omitted),
                url: dto.reportUrl,
                description: dto.reportDescription,
                category: categoriesString.isEmpty ? "General" : categoriesString,
                severity: mapSeverity(dto.severity),
                user: dto.user ?? UserInReportDTO(username: "Anónimo"),
                createdAt: createdAtDate,
                evidences: dto.evidences,
                impacts: impactNames,
                severityScore: dto.severity,
                statusText: dto.reportStatus,
                statusColor: mapStatusColor(dto.reportStatus),
                voteScore: score,
                userVoteStatus: nil,
                userId: dto.userId,
                adminFeedback: dto.adminFeedback
            )
        }
    }

    // --- Funciones auxiliares (sin cambios) ---
    private func mapSeverity(_ severity: Int) -> String {
        switch severity {
        case ...25: return "Baja"
        case 26...50: return "Media"
        case 51...75: return "Alta"
        default: return "Severa"
        }
    }

    private func mapStatusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending", "revision": return .statusReview
        case "approved", "accepted", "aceptado": return .statusAccepted
        case "rejected", "rechazado": return .statusRejected
        default: return .gray
        }
    }

} // End Class
