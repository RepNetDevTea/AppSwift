//
//  EditReportViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 15/10/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class EditReportViewModel: ObservableObject {
    
    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()
    private var cancellables = Set<AnyCancellable>()
    
    private let originalReport: Report
    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []
    private var originalEvidenceIds: Set<Int> = []
    
    // --- Campos del Formulario ---
    @Published var reportTitle: String
    @Published var reportUrl: String
    @Published var reportDescription: String
    
    @Published var selectedTags: Set<Tag> = []
    @Published var selectedImpacts: Set<Impact> = []
    
    @Published var evidenceItems: [EvidenceItem] = []
    
    // --- Estado de la UI ---
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var updateSuccessful = false
    @Published var isFormValid = false
    
    // Opciones para los menús (dinámicas)
    var tagOptions: [Tag] { allTags }
    var impactOptions: [Impact] { allImpacts }

    init(report: Report) {
        self.originalReport = report
        self.reportTitle = report.title
        self.reportUrl = report.url
        self.reportDescription = report.description
        
        setupFormValidation()
        
        Task {
            await fetchInitialDataAndPopulateSaves()
        }
    }
    
    func fetchInitialDataAndPopulateSaves() async {
        isLoading = true
        errorMessage = nil
        do {
            async let tags = tagsAndImpactsAPIService.fetchAllTags()
            async let impacts = tagsAndImpactsAPIService.fetchAllImpacts()
            self.allTags = try await tags
            self.allImpacts = try await impacts
            
            // Pre-llenamos las selecciones
            let originalTagNames = Set(originalReport.category.components(separatedBy: ", ").filter { !$0.isEmpty })
            self.selectedTags = Set(allTags.filter { originalTagNames.contains($0.name) })
            
            let originalImpactNames = Set(originalReport.impacts)
            self.selectedImpacts = Set(allImpacts.filter { originalImpactNames.contains($0.name) })
            
        } catch {
            errorMessage = "No se pudieron cargar las opciones de tags/impacts."
        }
        isLoading = false
    }
    
    func fetchInitialEvidences() async {
        guard let reportId = Int(originalReport.displayId) else { return }
        
        isLoading = true
        do {
            let evidenceDTOs = try await reportsAPIService.fetchEvidences(forReportId: reportId)
            self.evidenceItems = evidenceDTOs.compactMap { dto in
                if let urlString = dto.evidenceFileUrl {
                    return .existing(id: dto.id, url: urlString)
                }
                return nil
            }
            self.originalEvidenceIds = Set(evidenceDTOs.map { $0.id })
        } catch {
            print("⚠️ No se pudieron cargar las evidencias existentes: \(error)")
        }
        isLoading = false
    }
    
    func saveChanges() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let reportId = Int(originalReport.displayId) else { throw APIError.invalidURL }
            try await updateReportText(reportId: reportId)
            try await deleteRemovedEvidences(reportId: reportId)
            try await uploadNewEvidences(reportId: reportId)
            updateSuccessful = true
        } catch {
            print("❌ Error al actualizar el reporte: \(error)")
            errorMessage = "No se pudieron guardar los cambios."
        }
        isLoading = false
    }
    
    private func updateReportText(reportId: Int) async throws {
        let originalTagNames = Set(originalReport.category.components(separatedBy: ", ").filter { !$0.isEmpty })
        let newTagNames = Set(selectedTags.map { $0.name })
        
        let originalImpactNames = Set(originalReport.impacts)
        let newImpactNames = Set(selectedImpacts.map { $0.name })
        
        let addedTags = Array(newTagNames.subtracting(originalTagNames))
        let deletedTags = Array(originalTagNames.subtracting(newTagNames))
        
        let addedImpacts = Array(newImpactNames.subtracting(originalImpactNames))
        let deletedImpacts = Array(originalImpactNames.subtracting(newImpactNames))
        
        let updateData = UpdateReportRequestDTO(
            reportTitle: reportTitle == originalReport.title ? nil : reportTitle,
            reportUrl: reportUrl == originalReport.url ? nil : reportUrl,
            reportDescription: reportDescription == originalReport.description ? nil : reportDescription,
            addedTags: addedTags.isEmpty ? nil : addedTags,
            deletedTags: deletedTags.isEmpty ? nil : deletedTags,
            addedImpacts: addedImpacts.isEmpty ? nil : addedImpacts,
            deletedImpacts: deletedImpacts.isEmpty ? nil : deletedImpacts
        )
        
        try await reportsAPIService.updateReport(reportId: reportId, data: updateData)
        print("✅ Texto del reporte actualizado.")
    }
    
    private func deleteRemovedEvidences(reportId: Int) async throws {
        let currentEvidenceIds = Set(evidenceItems.compactMap {
            if case .existing(let id, _) = $0 { return id }
            return nil
        })
        let idsToDelete = originalEvidenceIds.subtracting(currentEvidenceIds)
        
        guard !idsToDelete.isEmpty else { return }
        
        print("🚀 Eliminando \(idsToDelete.count) evidencias...")
        for id in idsToDelete {
            try await reportsAPIService.deleteEvidence(evidenceId: id, fromReportId: reportId)
        }
        print("✅ Evidencias eliminadas.")
    }
    
    private func uploadNewEvidences(reportId: Int) async throws {
        let newImages = evidenceItems.compactMap {
            if case .new(let image) = $0 { return image.uiImage }
            return nil
        }
        
        guard !newImages.isEmpty else { return }

        print("🚀 Subiendo \(newImages.count) nuevas evidencias...")
        for image in newImages {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            try await reportsAPIService.addEvidence(toReportId: reportId, imageData: imageData)
        }
        print("✅ Nuevas evidencias subidas.")
    }
    
    private func setupFormValidation() {
        Publishers.CombineLatest3($reportTitle, $reportUrl, $reportDescription)
            .combineLatest($selectedTags, $selectedImpacts)
            .map { [weak self] (formInputs, tags, impacts) in
                guard let self = self else { return false }
                let (title, url, desc) = formInputs
                
                let originalTagNames = Set(self.originalReport.category.components(separatedBy: ", ").filter { !$0.isEmpty })
                let newTagNames = Set(tags.map { $0.name })
                
                let originalImpactNames = Set(self.originalReport.impacts)
                let newImpactNames = Set(impacts.map { $0.name })

                let hasChanges = title != self.originalReport.title ||
                                 url != self.originalReport.url ||
                                 desc != self.originalReport.description ||
                                 originalTagNames != newTagNames ||
                                 originalImpactNames != newImpactNames
                
                return hasChanges && !title.isEmpty && !url.isEmpty && !desc.isEmpty && !tags.isEmpty
            }
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }
}
