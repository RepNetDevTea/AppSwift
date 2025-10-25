//
//  CreateReportViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//

import Foundation
import Combine
import UIKit

// este es el viewmodel para la pantalla de "crear reporte"
@MainActor
class CreateReportViewModel: ObservableObject {

    // MARK: - Propiedades y Servicios
    
    // servicios de api para reportes y para tags/impacts
    private let reportsAPIService = ReportsAPIService()
    private let tagsAndImpactsAPIService = TagsAndImpactsAPIService()

    // almacenes privados para guardar las listas de tags e impacts
    // que se obtienen de la api
    private var allTags: [Tag] = []
    private var allImpacts: [Impact] = []

    // para manejar las suscripciones de combine
    private var cancellables = Set<AnyCancellable>()
    
    // --- datos del formulario ---
    // (propiedades @published que la vista observa)
    @Published var evidenceItems: [EvidenceItem] = [] // guarda las imagenes seleccionadas
    @Published var reportTitle = ""
    @Published var reportUrl = ""
    @Published var reportDescription = ""
    @Published var selectedTags: Set<Tag> = [] // guarda los objetos 'tag' seleccionados
    @Published var selectedImpacts: Set<Impact> = [] // guarda los objetos 'impact' seleccionados

    // --- estado de la ui ---
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var creationSuccessful = false // se pone 'true' si todo el flujo termina bien
    @Published var isFormValid = false // controla si el boton "enviar" esta habilitado

    // --- opciones para los pickers ---
    // estas propiedades computadas exponen las listas de tags/impacts a la vista
    var tagOptions: [Tag] { allTags.sorted { $0.name < $1.name } }
    var impactOptions: [Impact] { allImpacts.sorted { $0.name < $1.name } }


    // MARK: - Inicializador
    
    init() {
        // configura los listeners de combine
        setupValidation()
        // inicia la carga de datos iniciales (tags/impacts)
        Task {
            await fetchInitialData()
        }
    }

    // MARK: - Logica de API
    
    // obtiene los tags e impacts del servidor para llenar los selectores
    func fetchInitialData() async {
        isLoading = true
        errorMessage = nil
        do {
            // llama a ambos servicios en paralelo para ahorrar tiempo
            async let tags = tagsAndImpactsAPIService.fetchAllTags()
            async let impacts = tagsAndImpactsAPIService.fetchAllImpacts()

            // espera a que ambos terminen y guarda los resultados
            self.allTags = try await tags
            self.allImpacts = try await impacts
        } catch {
            errorMessage = "no se pudieron cargar las opciones de tags/impacts."
            print("❌ error fetching initial data: \(error)")
        }
        isLoading = false
    }

    // la funcion principal que se llama al tocar "enviar"
    func submitReport() async {
        // 1. guard para la validacion del formulario
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        // 2. guard para asegurar que se selecciono al menos un tag/impact
        guard !selectedTags.isEmpty, !selectedImpacts.isEmpty else {
            errorMessage = "debes seleccionar al menos una categoria y un impacto."
            isLoading = false
            return
        }

        // 3. prepara los datos para enviar
        // convierte el 'set<tag>' a '[tagimpactid]'
        let tagIds = selectedTags.map { TagImpactID(id: $0.id) }
        let impactIds = selectedImpacts.map { TagImpactID(id: $0.id) }

        // crea el dto para el paso 1
        let reportData = CreateReportRequestDTO(
            reportTitle: reportTitle,
            reportUrl: reportUrl,
            reportDescription: reportDescription,
            siteDomain: extractDomain(from: reportUrl),
            tags: tagIds,
            impacts: impactIds
        )

        // 4. ejecuta el flujo de 3 pasos
        do {
            // --- paso 1: crear el reporte (solo texto) ---
            print("🚀 paso 1: creando reporte...")
            let newReport = try await reportsAPIService.createReport(data: reportData)
            print("✅ reporte creado con id: \(newReport.id)")

            // --- paso 2: subir las evidencias (si hay) ---
            // filtra 'evidenceitems' para obtener solo las imagenes nuevas (.new)
            let newImagesToUpload = evidenceItems.compactMap { item -> UIImage? in
                if case .new(let selectedImage) = item {
                    return selectedImage.uiImage
                }
                return nil
            }

            if !newImagesToUpload.isEmpty {
                print("🚀 paso 2: subiendo \(newImagesToUpload.count) evidencias...")
                // itera y sube cada imagen una por una
                for image in newImagesToUpload {
                    guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
                    try await reportsAPIService.addEvidence(toReportId: newReport.id, imageData: imageData)
                }
                print("✅ todas las evidencias fueron subidas.")
            } else {
                 print("ℹ️ no hay nuevas evidencias para subir.")
            }

            // --- paso 3: calcular la severidad ---
            print("🚀 paso 3: solicitando calculo de severidad...")
            try await reportsAPIService.calculateSeverityScore(forReportId: newReport.id)
            print("✅ flujo de creacion de reporte completado.")

            // si todo sale bien, marca como exitoso
            creationSuccessful = true

        } catch {
             print("❌ error durante el proceso de creacion/subida: \(error)")
             errorMessage = "no se pudo enviar el reporte. intentalo de nuevo."
        }
        isLoading = false
    }

    // MARK: - Logica de Validacion
    
    // configura los listeners de combine para validar el formulario en tiempo real
    private func setupValidation() {
        // combina los 3 campos de texto
        let textFieldsPublisher = Publishers.CombineLatest3($reportTitle, $reportUrl, $reportDescription)
            .map { title, url, desc in
                return !title.isEmpty && !url.isEmpty && !desc.isEmpty
            }
            .prepend(!reportTitle.isEmpty && !reportUrl.isEmpty && !reportDescription.isEmpty)

        // combina los 2 selectores (sets de objetos)
        let selectionsPublisher = Publishers.CombineLatest($selectedTags, $selectedImpacts)
            .map { tags, impacts in
                return !tags.isEmpty && !impacts.isEmpty
            }
            .prepend(!selectedTags.isEmpty && !selectedImpacts.isEmpty)

        // combina los dos resultados
        Publishers.CombineLatest(textFieldsPublisher, selectionsPublisher)
            .map { textFieldsValid, selectionsValid in
                // el formulario es valido solo si ambos son validos
                return textFieldsValid && selectionsValid
            }
            .removeDuplicates() // evita calculos innecesarios
            .assign(to: \.isFormValid, on: self) // asigna el resultado a 'isformvalid'
            .store(in: &cancellables)
    }

    // MARK: - Helpers
    
    // funcion auxiliar para extraer el dominio de una url
    private func extractDomain(from urlString: String) -> String {
        return URL(string: urlString)?.host ?? urlString
    }
}
