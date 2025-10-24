//
//  SearchViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

import Foundation
import Combine
import SwiftUI

enum SearchState {
    case initial, loading, success([Site]), empty, error(String)
}

@MainActor
class SearchViewModel: ObservableObject {

    private let searchAPIService = SearchAPIService()
    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()

    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []

    @Published var searchQuery = ""
    @Published var state: SearchState = .initial
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    init() {
        Task { await fetchInitialLookups() }
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

    func performSearch(query: String) async {
        state = .loading
        errorMessage = nil

        do {
            let siteDTO = try await searchAPIService.search(query: query)
            if let foundSiteDTO = siteDTO {
                let site = mapSingleSiteDTOToSite(foundSiteDTO)
                state = .success([site])
            } else {
                state = .empty
            }
        } catch APIError.invalidResponse(let statusCode) where statusCode == 500 {
             print("❌ Error 500 en la búsqueda: \(query)")
             state = .error("Error del servidor al buscar. Inténtalo de nuevo.")
        } catch {
            print("❌ Error en la búsqueda: \(error)")
            self.state = .error("No se pudieron obtener los resultados.")
        }
    }

    private func mapSingleSiteDTOToSite(_ dto: SiteResponseDTO) -> Site {
        let reports = mapSearchReportDTOsToReports(dto.reports)
        return Site(
            id: dto.id,
            domain: dto.siteDomain,
            reputationScore: dto.siteReputation,
            reports: reports
        )
    }

    private func mapSearchReportDTOsToReports(_ dtos: [SearchReportDTO]) -> [Report] {
        let formatter = ISO8601DateFormatter()
        // No necesitamos los lookups de ID aquí, los nombres ya vienen

        return dtos.map { dto in
            let createdAtDate = formatter.date(from: dto.createdAt) ?? Date()
            
            var score = 0
            // ✨ CORREGIDO: Maneja 'votes' opcional
            for vote in dto.votes ?? [] {
                if vote.voteType == "upvote" { score += 1 }
                else if vote.voteType == "downvote" { score -= 1 }
            }
            
            let categoryNames = dto.tags.map { $0.tag.tagName }
            let impactNames = dto.impacts.map { $0.impact.impactName }
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
                // ✨ CORREGIDO: Maneja 'evidences' opcional
                evidences: dto.evidences ?? [],
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
}
