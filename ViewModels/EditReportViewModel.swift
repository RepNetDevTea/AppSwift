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
    
    // MARK: - Propiedades y Servicios
    
    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()
    private var cancellables = Set<AnyCancellable>()
    
    // guarda el reporte original que se paso a esta vista
    // se usa para pre-llenar el formulario y para comparar si hubo cambios
    private let originalReport: Report
    
    // almacenes para las listas de tags/impacts y sus opciones
    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []
    
    // guarda los ids de las evidencias que venian con el reporte
    // se usa para saber cuales borrar si el usuario las quita
    private var originalEvidenceIds: Set<Int> = []
    
    // --- campos del formulario ---
    @Published var reportTitle: String
    @Published var reportUrl: String
    @Published var reportDescription: String
    
    // guarda los objetos 'tag' e 'impact' seleccionados
    @Published var selectedTags: Set<Tag> = []
    @Published var selectedImpacts: Set<Impact> = []
    
    // guarda la lista de evidencias (existentes y nuevas)
    @Published var evidenceItems: [EvidenceItem] = []
    
    // --- estado de la ui ---
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var updateSuccessful = false
    @Published var isFormValid = false
    
    // --- opciones para los pickers ---
    // exponen las listas de tags/impacts a la vista
    var tagOptions: [Tag] { allTags }
    var impactOptions: [Impact] { allImpacts }

    // MARK: - Inicializador
    
    init(report: Report) {
        self.originalReport = report
        
        // pre-llena los campos de texto con los datos del reporte original
        self.reportTitle = report.title
        self.reportUrl = report.url
        self.reportDescription = report.description
        
        // configura los listeners de combine
        setupFormValidation()
        
        // inicia la carga de datos (tags, impacts)
        Task {
            await fetchInitialDataAndPopulateSaves()
        }
    }
    
    // MARK: - Logica de API
    
    // obtiene los tags/impacts y pre-selecciona los que el reporte ya tenia
    func fetchInitialDataAndPopulateSaves() async {
        isLoading = true
        errorMessage = nil
        do {
            // obtiene las listas completas de la api
            async let tags = tagsAndImpactsAPIService.fetchAllTags()
            async let impacts = tagsAndImpactsAPIService.fetchAllImpacts()
            self.allTags = try await tags
            self.allImpacts = try await impacts
            
            // --- pre-llenado de selecciones ---
            // 'originalreport.category' es un string "phishing, fraude"
            // lo convierte a un set de strings ["phishing", "fraude"]
            let originalTagNames = Set(originalReport.category.components(separatedBy: ", ").filter { !$0.isEmpty })
            // filtra la lista 'alltags' para encontrar los objetos 'tag' que coincidan
            self.selectedTags = Set(allTags.filter { originalTagNames.contains($0.name) })
            
            // 'originalreport.impacts' ya es un array de strings ["robo de identidad"]
            let originalImpactNames = Set(originalReport.impacts)
            // filtra la lista 'allimpacts'
            self.selectedImpacts = Set(allImpacts.filter { originalImpactNames.contains($0.name) })
            
        } catch {
            errorMessage = "no se pudieron cargar las opciones de tags/impacts."
        }
        isLoading = false
    }
    
    // obtiene la lista de evidencias (imagenes) que ya tiene el reporte
    func fetchInitialEvidences() async {
        guard let reportId = Int(originalReport.displayId) else { return }
        
        isLoading = true
        do {
            let evidenceDTOs = try await reportsAPIService.fetchEvidences(forReportId: reportId)
            // convierte los dtos en 'evidenceitem.existing'
            // usa compactmap para ignorar de forma segura las evidencias que no tengan url
            self.evidenceItems = evidenceDTOs.compactMap { dto in
                if let urlString = dto.evidenceFileUrl {
                    return .existing(id: dto.id, url: urlString)
                }
                return nil
            }
            // guarda los ids originales para saber que borrar despues
            self.originalEvidenceIds = Set(evidenceDTOs.map { $0.id })
        } catch {
            print("⚠️ no se pudieron cargar las evidencias existentes: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Logica de API (Guardado)
    
    // proceso completo de guardado en 3 etapas
    func saveChanges() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let reportId = Int(originalReport.displayId) else { throw APIError.invalidURL }
            
            // etapa 1: actualizar texto, tags e impacts
            try await updateReportText(reportId: reportId)
            // etapa 2: borrar evidencias eliminadas
            try await deleteRemovedEvidences(reportId: reportId)
            // etapa 3: subir evidencias nuevas
            try await uploadNewEvidences(reportId: reportId)
            
            updateSuccessful = true // si todo sale bien, marca como exitoso
        } catch {
            print("❌ error al actualizar el reporte: \(error)")
            errorMessage = "no se pudieron guardar los cambios."
        }
        isLoading = false
    }
    
    // etapa 1: envia los cambios de texto, tags e impacts
    private func updateReportText(reportId: Int) async throws {
        // --- calculo de diferencias (
        // 'updatedtoreport' del backend espera strings de lo que se anadio/borro
        
        let originalTagNames = Set(originalReport.category.components(separatedBy: ", ").filter { !$0.isEmpty })
        let newTagNames = Set(selectedTags.map { $0.name })
        
        let originalImpactNames = Set(originalReport.impacts)
        let newImpactNames = Set(selectedImpacts.map { $0.name })
        
        // calcula los arrays de strings
        let addedTags = Array(newTagNames.subtracting(originalTagNames))
        let deletedTags = Array(originalTagNames.subtracting(newTagNames))
        
        let addedImpacts = Array(newImpactNames.subtracting(originalImpactNames))
        let deletedImpacts = Array(originalImpactNames.subtracting(newImpactNames))
        
        // construye el dto de 'patch'
        // solo envia los campos que cambiaron (los deja 'nil' si son iguales)
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
        print("✅ texto del reporte actualizado.")
    }
    
    // etapa 2: borra las evidencias que el usuario quito
    private func deleteRemovedEvidences(reportId: Int) async throws {
        // obtiene los ids de las evidencias .existing que aun estan en la lista
        let currentEvidenceIds = Set(evidenceItems.compactMap {
            if case .existing(let id, _) = $0 { return id }
            return nil
        })
        // compara con los ids originales para ver cuales faltan
        let idsToDelete = originalEvidenceIds.subtracting(currentEvidenceIds)
        
        guard !idsToDelete.isEmpty else { return } // no hace nada si no hay nada que borrar
        
        print("🚀 eliminando \(idsToDelete.count) evidencias...")
        for id in idsToDelete {
            try await reportsAPIService.deleteEvidence(evidenceId: id, fromReportId: reportId)
        }
        print("✅ evidencias eliminadas.")
    }
    
    // etapa 3: sube las evidencias nuevas que el usuario anadio
    private func uploadNewEvidences(reportId: Int) async throws {
        // obtiene solo las imagenes nuevas (.new) de la lista
        let newImages = evidenceItems.compactMap {
            if case .new(let image) = $0 { return image.uiImage }
            return nil
        }
        
        guard !newImages.isEmpty else { return } // no hace nada si no hay nada que subir

        print("🚀 subiendo \(newImages.count) nuevas evidencias...")
        for image in newImages {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            try await reportsAPIService.addEvidence(toReportId: reportId, imageData: imageData)
        }
        print("✅ nuevas evidencias subidas.")
    }
    
    // MARK: - Logica de Validacion
    
    // configura los listeners de combine para validar el formulario
    private func setupFormValidation() {
        Publishers.CombineLatest3($reportTitle, $reportUrl, $reportDescription)
            .combineLatest($selectedTags, $selectedImpacts)
            .map { [weak self] (formInputs, tags, impacts) in
                guard let self = self else { return false }
                let (title, url, desc) = formInputs
                
                // --- calculo de cambios ---
                let originalTagNames = Set(self.originalReport.category.components(separatedBy: ", ").filter { !$0.isEmpty })
                let newTagNames = Set(tags.map { $0.name })
                
                let originalImpactNames = Set(self.originalReport.impacts)
                let newImpactNames = Set(impacts.map { $0.name })

                // 'haschanges' es true si cualquier campo de texto o seleccion es diferente
                let hasChanges = title != self.originalReport.title ||
                                 url != self.originalReport.url ||
                                 desc != self.originalReport.description ||
                                 originalTagNames != newTagNames ||
                                 originalImpactNames != newImpactNames
                
                // 'isformvalid' es true si:
                // 1. hubo cambios
                // 2. los campos de texto no estan vacios
                // 3. se selecciono al menos un tag
               
                return hasChanges && !title.isEmpty && !url.isEmpty && !desc.isEmpty && !tags.isEmpty
            }
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }
}
