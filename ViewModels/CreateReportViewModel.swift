//
//  CreateReportViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//

import Foundation
import Combine
import UIKit // Keep UIKit for UIImage

@MainActor
class CreateReportViewModel: ObservableObject {

    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()

    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []

    // --- Published Properties ---
    @Published var evidenceItems: [EvidenceItem] = [] // Uses EvidenceItem
    @Published var reportTitle = ""
    @Published var reportUrl = ""
    @Published var reportDescription = ""
    @Published var selectedTags: Set<Tag> = []      // Uses Set<Tag>
    @Published var selectedImpacts: Set<Impact> = [] // Uses Set<Impact>

    // UI State
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var creationSuccessful = false
    @Published var isFormValid = false

    // Options for Pickers
    var tagOptions: [Tag] { allTags.sorted { $0.name < $1.name } }
    var impactOptions: [Impact] { allImpacts.sorted { $0.name < $1.name } }

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupValidation()
        Task {
            await fetchInitialData()
        }
    }

    func fetchInitialData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let tags = tagsAndImpactsAPIService.fetchAllTags()
            async let impacts = tagsAndImpactsAPIService.fetchAllImpacts()

            self.allTags = try await tags
            self.allImpacts = try await impacts
        } catch {
            errorMessage = "No se pudieron cargar las opciones de tags/impacts."
            print("❌ Error fetching initial data: \(error)")
        }
        isLoading = false
    }

    func submitReport() async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        guard !selectedTags.isEmpty, !selectedImpacts.isEmpty else {
            errorMessage = "Debes seleccionar al menos una categoría y un impacto."
            isLoading = false
            return
        }

        let tagIds = selectedTags.map { TagImpactID(id: $0.id) }
        let impactIds = selectedImpacts.map { TagImpactID(id: $0.id) }

        let reportData = CreateReportRequestDTO(
            reportTitle: reportTitle,
            reportUrl: reportUrl,
            reportDescription: reportDescription,
            siteDomain: extractDomain(from: reportUrl),
            tags: tagIds,
            impacts: impactIds
        )

        do {
            // STEP 1: Create Report
            print("🚀 Paso 1: Creando reporte...")
            let newReport = try await reportsAPIService.createReport(data: reportData)
            print("✅ Reporte creado con ID: \(newReport.id)")

            // STEP 2: Upload Evidences
            let newImagesToUpload = evidenceItems.compactMap { item -> UIImage? in
                if case .new(let selectedImage) = item {
                    return selectedImage.uiImage
                }
                return nil
            }

            if !newImagesToUpload.isEmpty {
                print("🚀 Paso 2: Subiendo \(newImagesToUpload.count) evidencias...")
                for image in newImagesToUpload {
                    guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
                    try await reportsAPIService.addEvidence(toReportId: newReport.id, imageData: imageData)
                }
                print("✅ Todas las evidencias fueron subidas.")
            } else {
                 print("ℹ️ No hay nuevas evidencias para subir.")
            }

            // STEP 3: Calculate Severity
            print("🚀 Paso 3: Solicitando cálculo de severidad...")
            try await reportsAPIService.calculateSeverityScore(forReportId: newReport.id)
            print("✅ Flujo de creación de reporte completado.")

            creationSuccessful = true

        } catch {
             print("❌ Error durante el proceso de creación/subida: \(error)")
             errorMessage = "No se pudo enviar el reporte. Inténtalo de nuevo."
        }
        isLoading = false
    }

    // ✨ CORRECTED setupValidation ✨
    private func setupValidation() {
        // Combine the text fields first
        let textFieldsPublisher = Publishers.CombineLatest3($reportTitle, $reportUrl, $reportDescription)
            .map { title, url, desc in
                return !title.isEmpty && !url.isEmpty && !desc.isEmpty
            }
            // Start immediately with current values, don't wait for change
            .prepend(!reportTitle.isEmpty && !reportUrl.isEmpty && !reportDescription.isEmpty)

        // Combine the selection sets
        let selectionsPublisher = Publishers.CombineLatest($selectedTags, $selectedImpacts)
            .map { tags, impacts in
                return !tags.isEmpty && !impacts.isEmpty
            }
            // Start immediately with current values
            .prepend(!selectedTags.isEmpty && !selectedImpacts.isEmpty)

        // Combine the results of the previous two publishers
        Publishers.CombineLatest(textFieldsPublisher, selectionsPublisher)
            .map { textFieldsValid, selectionsValid in
                // Form is valid if both text fields AND selections are valid
                return textFieldsValid && selectionsValid
            }
            .removeDuplicates() // Avoid unnecessary updates if validity doesn't change
            .assign(to: \.isFormValid, on: self) // Assign the final Bool result
            .store(in: &cancellables)
    }


    private func extractDomain(from urlString: String) -> String {
        return URL(string: urlString)?.host ?? urlString
    }
}

// Ensure SelectedImage struct exists if EvidenceManagerView uses it internally
// (Likely defined within EvidenceManagerView or another file)
/*
 struct SelectedImage: Identifiable, Equatable {
     let id = UUID()
     let uiImage: UIImage
 }
 */
