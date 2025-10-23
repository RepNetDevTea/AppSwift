//
//  VoteDTOs.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

import Foundation

// DTO para enviar un voto al backend.
// Le diremos al servidor en qué reporte estamos votando y qué tipo de voto es.
struct VoteRequestDTO: Encodable {
    let reportId: Int
    let voteType: String // Será "upvote" o "downvote"
}

