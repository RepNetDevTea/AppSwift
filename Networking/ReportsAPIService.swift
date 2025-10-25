//
//  ReportsAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//

import Foundation

// este archivo define el 'reportsapiservice'
// centraliza todas las llamadas a la api que tienen que ver con reportes
// usa el 'networkclient' generico para realizar las peticiones

struct ReportsAPIService {
    
    // una instancia privada del cliente de red generico
    private let networkClient = NetworkClient()
    
    // MARK: - Obtener Reportes (GET)
    
    // obtiene la lista de reportes para un usuario especifico, con filtros
    func fetchMyReports(userId: Int, status: String, category: String, sortBy: String) async throws -> [ReportResponseDTO] {
        
        var components = URLComponents(string: AppConfig.reportsURL)
        // anade el 'userid' como parametro principal de filtro
        components?.queryItems = [
            URLQueryItem(name: "userId", value: String(userId))
        ]
        
        // "traduce" los valores de estado de espanol (ui) a ingles (api)
        let statusMap = [
            "pendiente": "pending",
            "aprobado": "approved",
            "aceptados": "accepted",
            "rechazado": "rejected",
            "rechazados": "rejected"
        ]
        let statusInEnglish = statusMap[status.lowercased()]

        // anade los filtros a la url si no son los valores por defecto
        if status != "Todos", let backendStatus = statusInEnglish {
            components?.queryItems?.append(URLQueryItem(name: "status", value: backendStatus))
        }
        
        if category != "Categoría" {
            components?.queryItems?.append(URLQueryItem(name: "tag", value: category))
        }
        
        if sortBy != "Ordenar" {
            components?.queryItems?.append(URLQueryItem(name: "sortBy", value: sortBy.lowercased()))
        }
        
        let endpoint = components?.url?.absoluteString ?? AppConfig.reportsURL
        
        return try await networkClient.request(
            endpoint: endpoint,
            method: "GET",
            isAuthenticated: true // requiere token
        )
    }
    
    // obtiene la lista de todos los reportes publicos (aprobados)
  
    func fetchPublicReports() async throws -> [ReportResponseDTO] {
        let endpoint = AppConfig.reportsURL
        return try await networkClient.request(
            endpoint: endpoint,
            method: "GET",
            isAuthenticated: false // no requiere token
        )
    }
    
    // obtiene un solo reporte por su id
    func fetchReport(withId reportId: Int) async throws -> ReportResponseDTO {
        let endpoint = AppConfig.reportsURL + "/\(reportId)"
        return try await networkClient.request(
            endpoint: endpoint,
            method: "GET",
            isAuthenticated: true // asumo que requiere token
        )
    }
    
    // MARK: - Crear y Modificar Reportes (POST / PATCH)

    // crea un nuevo reporte con los datos de texto (paso 1 del flujo)
    // devuelve un 'createreportresponsedto' que solo contiene el id
    func createReport(data: CreateReportRequestDTO) async throws -> CreateReportResponseDTO {
        let endpoint = AppConfig.reportsURL
        return try await networkClient.request(
            endpoint: endpoint,
            method: "POST",
            body: data,
            isAuthenticated: true
        )
    }
    
    // envia los datos actualizados de un reporte (ej. cambiar titulo, anadir/borrar tags)
    // usa el metodo 'patch' para actualizaciones parciales
    func updateReport(reportId: Int, data: UpdateReportRequestDTO) async throws {
        let endpoint = AppConfig.reportsURL + "/\(reportId)"
        
        // usa la funcion 'request' que no devuelve cuerpo
        try await networkClient.request(
            endpoint: endpoint,
            method: "PATCH",
            body: data,
            isAuthenticated: true
        )
    }
    
    // MARK: - Evidencias (POST / GET / DELETE)

    // sube una imagen de evidencia para un reporte especifico
    func addEvidence(toReportId reportId: Int, imageData: Data) async throws {
        let endpoint = AppConfig.evidencesURL(forReportId: reportId)
        
        // usa la funcion especial 'upload' del networkclient
        try await networkClient.upload(
            endpoint: endpoint,
            imageData: imageData,
            fieldName: "file", // el nombre del campo que espera el backend
            fileName: "\(UUID().uuidString).jpg",
            isAuthenticated: true
        )
    }
    
    // obtiene la lista de evidencias para un reporte
    func fetchEvidences(forReportId reportId: Int) async throws -> [EvidenceResponseDTO] {
        let endpoint = AppConfig.evidencesURL(forReportId: reportId)
        return try await networkClient.request(
            endpoint: endpoint,
            method: "GET",
            isAuthenticated: true
        )
    }
    
    // elimina una evidencia especifica de un reporte
    func deleteEvidence(evidenceId: Int, fromReportId reportId: Int) async throws {
        let endpoint = AppConfig.evidencesURL(forReportId: reportId) + "/\(evidenceId)"
        try await networkClient.request(
            endpoint: endpoint,
            method: "DELETE",
            isAuthenticated: true
        )
    }
    
    // MARK: - Scoring (PATCH)

    // llama al endpoint para que el backend calcule la severidad (paso 3 del flujo de creacion)
    func calculateSeverityScore(forReportId reportId: Int) async throws {
        let endpoint = AppConfig.reportsURL + "/\(reportId)/severityScore"
        try await networkClient.request(
            endpoint: endpoint,
            method: "PATCH",
            isAuthenticated: true
        )
    }
}
