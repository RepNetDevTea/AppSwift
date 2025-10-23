//
//  PublicReportsViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//

import Foundation
import SwiftUI
import Combine // Added Combine import if needed later, good practice

@MainActor
class PublicReportsViewModel: ObservableObject {

    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()

    // Store the complete lists for lookups
    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []

    @Published var reports: [Report] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    @Published var selectedFilter: String = "Todos"
    let filterOptions = ["Todos", "Trending", "Más recientes"]

    // ✨ ADD Category filter properties ✨
    @Published var selectedCategory: String = "Categorías" // Default "all" option
    var categoryOptions: [String] {
        ["Categorías"] + allTags.map { $0.tagName }.sorted()
    }

    // Computed property for UI filtering
    var filteredReports: [Report] {
        var processedReports: [Report]

        // --- Apply Status/Trending/Recent Filter ---
        switch selectedFilter {
        case "Trending":
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            processedReports = reports.filter { report in
                let score = report.voteScore ?? 0
                return score > 50 && report.createdAt >= oneWeekAgo
            }
        case "Más recientes":
            processedReports = reports.sorted { $0.createdAt > $1.createdAt }
        default: // "Todos"
             processedReports = reports
        }

        // --- Apply Category Filter ---
        if selectedCategory != "Categorías" {
            processedReports = processedReports.filter { report in
                report.category.localizedCaseInsensitiveContains(selectedCategory)
            }
        }

        return processedReports
    }

    // Load lookups on initialization
    init() {
        Task {
            // Fetch lookups silently in the background initially
            await fetchInitialLookups(showLoading: false)
        }
    }

    // Fetches the lists of tags and impacts
    private func fetchInitialLookups(showLoading: Bool) async {
        if showLoading { isLoading = true } // Show loading only if requested
        // Don't clear error message here, let fetchPublicReports handle it
        do {
            async let tags = tagsAndImpactsAPIService.fetchAllTags()
            async let impacts = tagsAndImpactsAPIService.fetchAllImpacts()
            self.allTags = try await tags
            self.allImpacts = try await impacts
        } catch {
            print("❌ Error al cargar listas de tags/impacts: \(error)")
            // Set error only if the main report fetch hasn't already set one
            if errorMessage == nil {
                self.errorMessage = "No se pudieron cargar las opciones de filtro."
            }
        }
        if showLoading { isLoading = false } // Hide loading only if shown
    }


    // Fetches lookups first, then filters reports
    func fetchPublicReports() async {
        // ✨ Guard 1: Prevent duplicate fetches ✨
        guard !isLoading else {
            print("Fetch already in progress (Public). Skipping.")
            return
        }

        // ✨ Set isLoading TRUE here ✨
        isLoading = true
        errorMessage = nil // Clear previous errors

        // Ensure lookups are loaded, show loading indicator while doing so if needed
        if allTags.isEmpty || allImpacts.isEmpty {
             await fetchInitialLookups(showLoading: false) // Fetch lookups without extra loading indicator
             // If lookups failed (errorMessage will be set by fetchInitialLookups)
             if allTags.isEmpty || allImpacts.isEmpty {
                 isLoading = false // Turn off loading
                 return
             }
        }

        // Guard 2: Re-check isLoading (optional, for safety)
        guard isLoading else { return }


        do {
            let allReportDTOs = try await reportsAPIService.fetchPublicReports()

            // Filter for approved status
            let approvedReports = allReportDTOs.filter { dto in
                return dto.reportStatus.lowercased() == "approved"
            }

            // Map using the lookups
            self.reports = mapDTOsToReports(approvedReports)

        } catch {
            print("❌ Error al obtener reportes públicos: \(error)")
            self.errorMessage = "No se pudieron cargar los reportes."
        }

        // ✨ Set isLoading FALSE at the very end ✨
        isLoading = false
    }

    // mapDTOsToReports function remains the same (implements ID -> Name mapping)
    private func mapDTOsToReports(_ dtos: [ReportResponseDTO]) -> [Report] {
        let formatter = ISO8601DateFormatter()
        // Ensure lookups are ready before mapping
        guard !allTags.isEmpty, !allImpacts.isEmpty else {
            print("⚠️ Attempted to map reports before lookups were loaded.")
            return [] // Return empty if lookups aren't ready
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

            // Map IDs to Names
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

    // --- Helper functions ---
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
