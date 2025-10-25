//
//  VotesAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

import Foundation

// este archivo define el 'votesapiservice'
// es un servicio dedicado exclusivamente a las llamadas de red
// relacionadas con los votos (upvote/downvote)


struct VotesAPIService {
    
    // una instancia privada del cliente de red generico
    private let networkClient = NetworkClient()
    
    
    // envia un voto (upvote o downvote) para un reporte especifico
    func castVote(reportId: Int, voteType: String) async throws {
        
        // la ruta es especifica para 'togglear' el voto en un reporte
        let endpoint = AppConfig.reportsURL + "/\(reportId)/toggleVote"
        
        // el backend espera un cuerpo json simple con el 'votetype'
        let voteData = ["voteType": voteType]
        
        // se llama a la version de 'request' que no espera un cuerpo de respuesta
        try await networkClient.request(
            endpoint: endpoint,
            method: "POST",
            body: voteData,
            isAuthenticated: true // requiere token para saber que usuario esta votando
        )
    }
}
