//
//  PublicReportsViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//

import Foundation
import SwiftUI
import Combine 

// este es el viewmodel para la pantalla "reportes publicos"
//


@MainActor
class PublicReportsViewModel: ObservableObject {

    // MARK: - Propiedades y Servicios
    
    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()

    // almacenes para guardar los "diccionarios" de tags/impacts
    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []

    // --- estado principal ---
    @Published var reports: [Report] = [] // la lista base (solo reportes aprobados)
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // --- estado de los filtros ---
    @Published var selectedFilter: String = "Todos"
    let filterOptions = ["Todos", "Trending", "Mas recientes"]

    @Published var selectedCategory: String = "Categorias" // opcion "todos"
    var categoryOptions: [String] {
        // anade "categorias" a la lista de tags descargada
        ["Categorias"] + allTags.map { $0.tagName }.sorted()
    }

    // MARK: - Propiedad Computada (Filtros)
    
    // esta es la lista que la vista *realmente* muestra
    // toma la lista 'reports' (ya filtrada por 'approved')
    // y le aplica los filtros de la ui
    var filteredReports: [Report] {
        var processedReports: [Report]

        // 1. aplica el filtro principal (todos, trending, mas recientes)
        switch selectedFilter {
        case "Trending":
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            processedReports = reports.filter { report in
                let score = report.voteScore ?? 0
                return score > 50 && report.createdAt >= oneWeekAgo
            }
        case "Mas recientes":
            processedReports = reports.sorted { $0.createdAt > $1.createdAt }
        default: // "todos"
             processedReports = reports
        }

        // 2. aplica el filtro de categoria (sobre la lista ya filtrada)
        if selectedCategory != "Categorias" {
            processedReports = processedReports.filter { report in
                report.category.localizedCaseInsensitiveContains(selectedCategory)
            }
        }

        return processedReports
    }

    // MARK: - Inicializador
    
    // load lookups on initialization
    init() {
        Task {
            // carga los tags/impacts silenciosamente al iniciar
            await fetchInitialLookups(showLoading: false)
        }
    }

    // MARK: - Logica de API
    
    // obtiene las listas completas de tags e impacts
    private func fetchInitialLookups(showLoading: Bool) async {
        if showLoading { isLoading = true }
        // no limpia el error aqui, deja que la funcion principal lo maneje
        do {
            async let tags = tagsAndImpactsAPIService.fetchAllTags()
            async let impacts = tagsAndImpactsAPIService.fetchAllImpacts()
            self.allTags = try await tags
            self.allImpacts = try await impacts
        } catch {
            print("❌ error al cargar listas de tags/impacts: \(error)")
            if errorMessage == nil {
                self.errorMessage = "no se pudieron cargar las opciones de filtro."
            }
        }
        if showLoading { isLoading = false }
    }


    // la funcion principal para cargar los reportes publicos
    func fetchPublicReports() async {
        // 1. guard para evitar cargas duplicadas (arregla error -999)
        guard !isLoading else {
            print("fetch already in progress (public). skipping.")
            return
        }

        // 2. pone el estado de carga
        isLoading = true
        errorMessage = nil

        // 3. asegura que los "diccionarios" de tags/impacts esten cargados
        if allTags.isEmpty || allImpacts.isEmpty {
             await fetchInitialLookups(showLoading: false)
             if allTags.isEmpty || allImpacts.isEmpty {
                 isLoading = false // detiene la carga si los lookups fallaron
                 return
             }
        }

        // 4. (opcional) re-chequeo por si acaso
        guard isLoading else { return }


        do {
            // 5. llama a la api
            let allReportDTOs = try await reportsAPIService.fetchPublicReports()

            // 6. filtra en el cliente para mostrar solo los 'approved'
            let approvedReports = allReportDTOs.filter { dto in
                return dto.reportStatus.lowercased() == "approved"
            }

            // 7. mapea los dtos filtrados al modelo 'report'
            self.reports = mapDTOsToReports(approvedReports)

        } catch {
            print("❌ error al obtener reportes publicos: \(error)")
            self.errorMessage = "no se pudieron cargar los reportes."
        }

        // 8. quita el estado de carga al final
        isLoading = false
    }

    // MARK: - Logica de Mapeo
    
    // "traduce" los dtos de la api a los modelos 'report' que usa la ui
    private func mapDTOsToReports(_ dtos: [ReportResponseDTO]) -> [Report] {
        let formatter = ISO8601DateFormatter()
        
        // asegura que los diccionarios esten listos
        guard !allTags.isEmpty, !allImpacts.isEmpty else {
            print("⚠️ se intento mapear reportes sin tener los lookups.")
            return []
        }
        // crea los diccionarios para busqueda rapida de id -> nombre
        let tagLookup = Dictionary(uniqueKeysWithValues: allTags.map { ($0.id, $0.tagName) })
        let impactLookup = Dictionary(uniqueKeysWithValues: allImpacts.map { ($0.id, $0.impactName) })

        return dtos.map { dto in
            let createdAtDate = formatter.date(from: dto.createdAt) ?? Date()

            // calcula la puntuacion de votos
            var score = 0
            // maneja 'votes' opcional (gracias al dto de busqueda)
            for vote in dto.votes {
                 if vote.voteType == "upvote" { score += 1 }
                 else if vote.voteType == "downvote" { score -= 1 }
            }

            // "traduce" los ids a nombres
            let categoryNames = dto.tags.compactMap { tagLookup[$0.tagId] ?? "categoria desconocida" }
            let impactNames = dto.impacts.compactMap { impactLookup[$0.impactId] ?? "impacto desconocido" }
            let categoriesString = categoryNames.joined(separator: ", ")

            // crea el objeto 'report' final
            return Report(
                displayId: String(dto.id),
                title: dto.reportTitle,
                date: createdAtDate.formatted(date: .long, time: .omitted),
                url: dto.reportUrl,
                description: dto.reportDescription,
                category: categoriesString.isEmpty ? "general" : categoriesString,
                severity: mapSeverity(dto.severity),
                user: dto.user ?? UserInReportDTO(username: "anonimo"),
                createdAt: createdAtDate,
                evidences: dto.evidences,
                impacts: impactNames,
                severityScore: dto.severity,
                statusText: dto.reportStatus,
                statusColor: mapStatusColor(dto.reportStatus),
                voteScore: score,
                userVoteStatus: nil, // no aplica en publico
                userId: dto.userId,
                adminFeedback: dto.adminFeedback
            )
        }
    }

    // --- helpers de mapeo ---
    private func mapSeverity(_ severity: Int) -> String {
        switch severity {
        case ...25: return "baja"
        case 26...50: return "media"
        case 51...75: return "alta"
        default: return "severa"
        }
    }

    private func mapStatusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending", "revision", "pendiente": return .statusReview
        case "approved", "accepted", "aceptado", "aprobado": return .statusAccepted
        case "rejected", "rechazado": return .statusRejected
        default: return .gray
        }
    }
}
