//
//  ReportsAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//

import Foundation

// este archivo define el `reportsapiservice`, un servicio que centraliza
// todas las llamadas a la api que tienen que ver con reportes.

// agrupa las funciones para obtener y crear reportes.
// usa el `networkclient` generico para realizar las peticiones.
struct ReportsAPIService {
    private let networkClient = NetworkClient()
    
    /// Obtiene la lista de reportes del usuario, aplicando los filtros del lado del servidor.
    /// Esta función ha sido actualizada para aceptar parámetros que se convertirán en query params en la URL.
    /// - Parameters:
    ///   - status: El estado por el cual filtrar (ej. "pending").
    ///   - category: La categoría por la cual filtrar (ej. "Malware").
    ///   - sortBy: El campo por el cual ordenar.
    // En ReportsAPIService.swift

    /// Obtiene la lista de reportes del usuario, aplicando los filtros del lado del servidor.
    func fetchMyReports(userId: Int, status: String, category: String, sortBy: String) async throws -> [ReportResponseDTO] {
        
        var components = URLComponents(string: AppConfig.reportsURL)
        // ✨ CORREGIDO: Se añade el userId como el primer parámetro de filtro.
        // Esto asegura que la API solo devuelva los reportes del usuario loggeado.
        components?.queryItems = [
            URLQueryItem(name: "userId", value: String(userId))
        ]
        
        // ✨ CORREGIDO: Se "traducen" los valores del filtro de estado de español a inglés.
        let statusMap = [
            "revisión": "pending",
            "aceptados": "accepted",
            "rechazados": "rejected"
        ]
        let statusInEnglish = statusMap[status.lowercased()]

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
            isAuthenticated: true
        )
    }
    
    /// --- FUNCIÓN 'createReport' ACTUALIZADA ---
    /// Ahora devuelve el 'ReportResponseDTO' del reporte recién creado.
    /// Esto es crucial porque nos da acceso al 'id' que necesitamos para subir las evidencias.
    func createReport(data: CreateReportRequestDTO) async throws -> CreateReportResponseDTO {
        let endpoint = AppConfig.reportsURL
        return try await networkClient.request(
            endpoint: endpoint,
            method: "POST",
            body: data,
            isAuthenticated: true
        )
    }
    
    // obtiene la lista de reportes publicos, los que puede ver cualquier persona (logueada o no).
    // usa el mismo endpoint que `fetchmyreports`, pero la diferencia clave es `isauthenticated: false`.
    // el backend interpreta la ausencia del token como una solicitud de los reportes publicos.
    func fetchPublicReports() async throws -> [ReportResponseDTO] {
        let endpoint = AppConfig.reportsURL
        return try await networkClient.request(
            endpoint: endpoint,
            method: "GET",
            isAuthenticated: false // <-- esta es la diferencia.
        )
    }
    
    
    /// Envía los datos actualizados de un reporte existente al backend.
    /// Utiliza el método 'PATCH', que es ideal para modificaciones parciales.
    /// - Parameters:
    ///   - reportId: El ID del reporte que se va a modificar.
    ///   - data: Un DTO que contiene solo los campos que el usuario ha cambiado.
    func updateReport(reportId: Int, data: UpdateReportRequestDTO) async throws {
        /// Construimos la URL específica para el reporte, ej: /reports/32
        let endpoint = AppConfig.reportsURL + "/\(reportId)"
        
        try await networkClient.request(
            endpoint: endpoint,
            method: "PATCH",
            body: data,
            isAuthenticated: true
        )
    }
    
    
    /// Sube una imagen de evidencia para un reporte específico.
      func addEvidence(toReportId reportId: Int, imageData: Data) async throws {
        // Usa la nueva función de AppConfig para construir la URL.
        let endpoint = AppConfig.evidencesURL(forReportId: reportId)
        
        try await networkClient.upload(
            endpoint: endpoint,
            imageData: imageData,
            fieldName: "file", // El backend espera que el campo se llame "file".
            fileName: "\(UUID().uuidString).jpg",
            isAuthenticated: true
        )
      }
      
      /// Obtiene la lista de evidencias para un reporte específico.
      func fetchEvidences(forReportId reportId: Int) async throws -> [EvidenceResponseDTO] {
        let endpoint = AppConfig.evidencesURL(forReportId: reportId)
        return try await networkClient.request(
            endpoint: endpoint,
            method: "GET",
            isAuthenticated: true // Necesitamos estar logueados para ver las evidencias.
        )
      }
      
      /// Elimina una evidencia específica de un reporte.
      func deleteEvidence(evidenceId: Int, fromReportId reportId: Int) async throws {
        // Construye la URL completa, ej: /reports/32/evidences/1
        let endpoint = AppConfig.evidencesURL(forReportId: reportId) + "/\(evidenceId)"
        try await networkClient.request(
            endpoint: endpoint,
            method: "DELETE",
            isAuthenticated: true
        )
      }
    
    
    // MARK: -calcular severity score

    /// Llama al endpoint para que el backend calcule la severidad de un reporte.
    func calculateSeverityScore(forReportId reportId: Int) async throws {
        let endpoint = AppConfig.reportsURL + "/\(reportId)/severityScore"
        // Usamos la versión de 'request' que no espera datos de vuelta.
        try await networkClient.request(
            endpoint: endpoint,
            method: "PATCH",
            isAuthenticated: true
        )
    }
    
}
