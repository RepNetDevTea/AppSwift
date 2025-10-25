//
//  MyReportsViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//

import Foundation
import SwiftUI
import Combine

// este es el viewmodel para la pantalla de "mis reportes"
// @mainactor asegura que todas las actualizaciones de @published
// se hagan en el hilo principal
@MainActor
class MyReportsViewModel: ObservableObject {

    // MARK: - Propiedades y Servicios
    
    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()
    private var cancellables = Set<AnyCancellable>()

    // id del usuario logueado, se guarda despues de la primera carga
    private var currentUserId: Int?

    // almacenes privados para guardar las listas de tags e impacts
    // se usan como "diccionario" para mapear ids a nombres
    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []

    // --- estado principal ---
    // la lista base de reportes (ya filtrada por usuario y estado)
    @Published var reports: [Report] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // --- estado de los filtros ---
    // la vista se enlaza (bind) a estas propiedades
    @Published var selectedStatus: String = "Todos"
    @Published var selectedCategory: String = "Categoría"
    @Published var selectedSort: String = "Ordenar"

    // --- opciones para los pickers ---
    let statusOptions = ["Todos", "Pendiente", "Aprobado", "Rechazado"]
    var categoryOptions: [String] {
        // anade "categoria" como opcion por defecto a la lista de tags
        ["Categoría"] + allTags.map { $0.tagName }.sorted()
    }
    let sortOptions = ["Ordenar", "Severidad", "Fecha"]

  
    // toma la lista 'reports' y le aplica los filtros de categoria y orden
    var filteredAndSortedReports: [Report] {
        var processedReports = reports

        // --- aplicar filtro de categoria ---
        if selectedCategory != "Categoría" {
            processedReports = processedReports.filter { report in
                // revisa si el string "phishing, fraude" contiene "phishing"
                report.category.localizedCaseInsensitiveContains(selectedCategory)
            }
        }

        // --- aplicar ordenamiento ---
        switch selectedSort {
        case "Severidad":
            // ordena por puntuacion (mas alta primero)
            processedReports.sort { $0.severityScore > $1.severityScore }
        case "Fecha":
            // ordena por fecha de creacion (mas nueva primero)
            processedReports.sort { $0.createdAt > $1.createdAt }
        default: // "ordenar"
            break // mantiene el orden actual (de la api)
        }

        return processedReports
    }

    // MARK: - Inicializador
    
    init() {
        // configura el listener de combine
        setupFilterListener()
        Task {
            // carga los tags/impacts silenciosamente al inicio
            await fetchInitialLookups(showLoading: false)
        }
    }

    // MARK: - Logica de API
    
    // obtiene las listas completas de tags e impacts
    private func fetchInitialLookups(showLoading: Bool) async {
        if showLoading { isLoading = true }
        errorMessage = nil
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

    // configura el listener que reacciona a los cambios en los filtros
    private func setupFilterListener() {
        Publishers.CombineLatest3($selectedStatus, $selectedCategory, $selectedSort)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (status, category, sortBy) in
                Task {
                    guard let self = self else { return }
                    // vuelve a cargar los datos de la api
                    // (necesario si cambia el 'status', ya que ese filtro es en el cliente)
                    await self.fetchReports(status: status, category: category, sortBy: sortBy, userId: self.currentUserId)
                }
            }
            .store(in: &cancellables)
    }

    // la funcion principal para cargar los reportes del usuario
    func fetchReports(status: String, category: String, sortBy: String, userId: Int?) async {
        // 1. guard para evitar cargas duplicadas si ya esta cargando
        guard !isLoading else {
            print("fetch already in progress (myreports). skipping.")
            return
        }

        // 2. pone el estado de carga
        isLoading = true
        errorMessage = nil

        // 3. asegura que los tags/impacts (el "diccionario") esten cargados
        if allTags.isEmpty || allImpacts.isEmpty {
             await fetchInitialLookups(showLoading: false)
             if allTags.isEmpty || allImpacts.isEmpty {
                 isLoading = false
                 return
             }
        }

        // 4. asegura que tengamos el id del usuario
        if let userId = userId { self.currentUserId = userId }
        guard let validUserId = self.currentUserId else {
            print("⚠️ se intento buscar 'mis reportes' sin un userid.")
            self.errorMessage = "error de usuario. intenta reiniciar."
            isLoading = false
            return
        }

        // 5. llama a la api
        do {
            // pide *todos* los reportes publicos
            let allReportDTOs = try await reportsAPIService.fetchPublicReports()

            // --- filtrado en el cliente ---
            
            // 6. filtra por usuario
            var userReports = allReportDTOs.filter { $0.userId == validUserId }

            // 7. filtra por estado
            let statusMap = ["pendiente": "pending", "aprobado": "approved", "rechazado": "rejected"]
            if status != "Todos", let backendStatus = statusMap[status.lowercased()] {
                userReports = userReports.filter { $0.reportStatus.lowercased() == backendStatus }
            }

            // 8. mapea los dtos filtrados al modelo 'report'
            self.reports = mapDTOsToReports(userReports, currentUserId: validUserId)

        } catch {
            print("❌ error al obtener mis reportes: \(error)")
            self.errorMessage = "no se pudieron cargar tus reportes."
        }

        // 9. quita el estado de carga
        isLoading = false
    }

    // MARK: - Logica de Mapeo
    
    // esta funcion es el "traductor" de datos de la api a datos de la ui
    private func mapDTOsToReports(_ dtos: [ReportResponseDTO], currentUserId: Int?) -> [Report] {
        let formatter = ISO8601DateFormatter()
        
        // crea los diccionarios para busqueda rapida
        let tagLookup = Dictionary(uniqueKeysWithValues: allTags.map { ($0.id, $0.tagName) })
        let impactLookup = Dictionary(uniqueKeysWithValues: allImpacts.map { ($0.id, $0.impactName) })

        return dtos.map { dto in
            let createdAtDate = formatter.date(from: dto.createdAt) ?? Date()

            // calcula la puntuacion y el voto del usuario actual
            var score = 0
            var currentUserVote: UserVoteStatus? = nil
            for vote in dto.votes {
                 if vote.voteType == "upvote" { score += 1 }
                 else if vote.voteType == "downvote" { score -= 1 }
                 if let userId = currentUserId, vote.userId == userId {
                     currentUserVote = UserVoteStatus(rawValue: vote.voteType)
                 }
            }

            // traduce los ids de tags a nombres
            let categoryNames = dto.tags.compactMap { tagLookup[$0.tagId] ?? "categoria desconocida" }
            // "traduce" los ids de impacts a nombres
            let impactNames = dto.impacts.compactMap { impactLookup[$0.impactId] ?? "impacto desconocido" }
            // une los nombres de las categorias en un solo string
            let categoriesString = categoryNames.joined(separator: ", ")

            // crea el objeto 'report' final que usa la vista
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
                userVoteStatus: currentUserVote,
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
