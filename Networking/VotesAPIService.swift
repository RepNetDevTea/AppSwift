//
//  VotesAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

import Foundation

/// Un servicio dedicado exclusivamente a las llamadas de red relacionadas con los votos.
struct VotesAPIService {
    private let networkClient = NetworkClient()
    
    /// Envía un voto (upvote o downvote) para un reporte específico.
    /// - Parameters:
    ///   - reportId: El ID del reporte que se está votando.
    ///   - voteType: El tipo de voto, que debe ser "upvote" o "downvote".
    func castVote(reportId: Int, voteType: String) async throws {
        // --- CORRECCIÓN CLAVE AQUÍ ---
        // Basado en el código de tu 'ReportsController', la ruta correcta es específica
        // para cada reporte y se encarga de "alternar" el voto (toggle).
        let endpoint = AppConfig.reportsURL + "/\(reportId)/toggleVote"
        
        // El backend espera un cuerpo JSON con el 'voteType'.
        let voteData = ["voteType": voteType]
        
        // Esta es una acción autenticada, por lo que necesita el token del usuario.
        try await networkClient.request(
            endpoint: endpoint,
            method: "POST",
            body: voteData,
            isAuthenticated: true
        )
    }
}


