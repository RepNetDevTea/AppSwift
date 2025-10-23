//
//  MyReportsViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MyReportsViewModel: ObservableObject {

    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()
    private var cancellables = Set<AnyCancellable>()

    private var currentUserId: Int?

    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []

    @Published var reports: [Report] = [] // Base list filtered by user/status
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    @Published var selectedStatus: String = "Todos"
    @Published var selectedCategory: String = "Categoría" // Default "all" option
    @Published var selectedSort: String = "Ordenar"

    // Filter/Sort Options
    let statusOptions = ["Todos", "Pendiente", "Aprobado", "Rechazado"]
    var categoryOptions: [String] {
        ["Categoría"] + allTags.map { $0.tagName }.sorted()
    }
    let sortOptions = ["Ordenar", "Severidad", "Fecha"]

    // Computed property for filtering/sorting
    var filteredAndSortedReports: [Report] {
        var processedReports = reports // Start with the base list

        // --- Apply Category Filter ---
        if selectedCategory != "Categoría" {
            processedReports = processedReports.filter { report in
                report.category.localizedCaseInsensitiveContains(selectedCategory)
            }
        }

        // --- Apply Sorting ---
        switch selectedSort {
        case "Severidad":
            processedReports.sort { $0.severityScore > $1.severityScore }
        case "Fecha":
            processedReports.sort { $0.createdAt > $1.createdAt }
        default: // "Ordenar"
            break
        }

        return processedReports
    }

    init() {
        setupFilterListener()
        Task {
            // Fetch lookups silently initially
            await fetchInitialLookups(showLoading: false)
        }
    }

    // Fetches the lists of tags and impacts
    private func fetchInitialLookups(showLoading: Bool) async {
        if showLoading { isLoading = true }
        // Don't clear error message here
        do {
            async let tags = tagsAndImpactsAPIService.fetchAllTags()
            async let impacts = tagsAndImpactsAPIService.fetchAllImpacts()
            self.allTags = try await tags
            self.allImpacts = try await impacts
        } catch {
            print("❌ Error al cargar listas de tags/impacts: \(error)")
            if errorMessage == nil { // Set error only if not already set
                self.errorMessage = "No se pudieron cargar las opciones de filtro."
            }
        }
        if showLoading { isLoading = false }
    }


    private func setupFilterListener() {
        Publishers.CombineLatest3($selectedStatus, $selectedCategory, $selectedSort)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (status, category, sortBy) in
                Task {
                    guard let self = self else { return }
                    // Re-fetch reports when status filter changes
                    await self.fetchReports(status: status, category: category, sortBy: sortBy, userId: self.currentUserId)
                }
            }
            .store(in: &cancellables)
    }

    func fetchReports(status: String, category: String, sortBy: String, userId: Int?) async {
        // ✨ Guard 1: Prevent duplicate fetches ✨
        guard !isLoading else {
            print("Fetch already in progress (MyReports). Skipping.")
            return
        }

        // ✨ Set isLoading TRUE here ✨
        isLoading = true
        errorMessage = nil // Clear previous errors

        // Ensure lookups are loaded
        if allTags.isEmpty || allImpacts.isEmpty {
             await fetchInitialLookups(showLoading: false) // Fetch lookups silently
             if allTags.isEmpty || allImpacts.isEmpty {
                 isLoading = false // Turn off loading if lookups failed
                 return
             }
        }

        // Guard 2: Check for valid User ID
        if let userId = userId { self.currentUserId = userId }
        guard let validUserId = self.currentUserId else {
            print("⚠️ Se intentó buscar 'Mis Reportes' sin un userId.")
            self.errorMessage = "Error de usuario. Intenta reiniciar."
            isLoading = false // Turn off loading
            return
        }

        // Guard 3: Re-check isLoading (optional, safety)
        guard isLoading else { return }

        do {
            let allReportDTOs = try await reportsAPIService.fetchPublicReports() // Fetch all reports

            // Client-side filtering for User
            var userReports = allReportDTOs.filter { $0.userId == validUserId }

            // Client-side filtering for Status
            let statusMap = ["pendiente": "pending", "aprobado": "approved", "rechazado": "rejected"]
            if status != "Todos", let backendStatus = statusMap[status.lowercased()] {
                userReports = userReports.filter { $0.reportStatus.lowercased() == backendStatus }
            }

            // Map the results filtered only by user and status
            self.reports = mapDTOsToReports(userReports, currentUserId: validUserId)

        } catch {
            print("❌ error al obtener mis reportes: \(error)")
            self.errorMessage = "No se pudieron cargar tus reportes."
        }

        // ✨ Set isLoading FALSE only at the very end ✨
        isLoading = false
    }

    // mapDTOsToReports function remains the same (implements ID -> Name mapping)
    private func mapDTOsToReports(_ dtos: [ReportResponseDTO], currentUserId: Int?) -> [Report] {
        let formatter = ISO8601DateFormatter()
        // Ensure lookups are ready
        guard !allTags.isEmpty, !allImpacts.isEmpty else { return [] }
        let tagLookup = Dictionary(uniqueKeysWithValues: allTags.map { ($0.id, $0.tagName) })
        let impactLookup = Dictionary(uniqueKeysWithValues: allImpacts.map { ($0.id, $0.impactName) })

        return dtos.map { dto in
            let createdAtDate = formatter.date(from: dto.createdAt) ?? Date()

            var score = 0
            var currentUserVote: UserVoteStatus? = nil
            for vote in dto.votes {
                 if vote.voteType == "upvote" { score += 1 }
                 else if vote.voteType == "downvote" { score -= 1 }
                 if let userId = currentUserId, vote.userId == userId {
                     currentUserVote = UserVoteStatus(rawValue: vote.voteType)
                 }
            }

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
                userVoteStatus: currentUserVote,
                userId: dto.userId,
                adminFeedback: dto.adminFeedback
            )
        }
    }

    // Helper functions (mapSeverity, mapStatusColor) remain the same
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
