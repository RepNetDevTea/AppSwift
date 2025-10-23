//
//  Report.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
// edefine el modelo `report`, la estructura de datos principal
// que la aplicacion usa para manejar y mostrar la informacion de un reporte en la ui.

// representa los dos estados posibles del voto de un usuario en un reporte.
// `codable` permite que se lea y escriba facilmente desde/hacia json.

import Foundation
import SwiftUI

enum UserVoteStatus: String, Codable {
    case upvoted
    case downvoted
}

struct Report: Identifiable, Equatable {
    static func == (lhs: Report, rhs: Report) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let displayId: String
    let title: String
    let date: String
    let url: String
    let description: String
    let category: String
    let severity: String
    let user: UserInReportDTO
    let createdAt: Date
    
    // ✨ CORREGIDO: Se añadieron estas nuevas propiedades para almacenar los datos completos.
    let evidences: [EvidenceResponseDTO]
    let impacts: [String]
    let severityScore: Int
    
    // Propiedades opcionales
    let statusText: String?
    let statusColor: Color?
    let voteScore: Int?
    let userVoteStatus: UserVoteStatus?
    let adminFeedback: String?
    let userId: Int // Added userId
    
    // ✨ CORREGIDO: Se actualizó el inicializador para aceptar las nuevas propiedades.
    init(
        id: UUID = UUID(),
        displayId: String,
        title: String,
        date: String,
        url: String,
        description: String,
        category: String,
        severity: String, // 'severity' es el texto, ej. "Alta"
        user: UserInReportDTO,
        createdAt: Date,
        evidences: [EvidenceResponseDTO], // Nuevo
        impacts: [String],                // Nuevo
        severityScore: Int,               // Nuevo
        statusText: String? = nil,
        statusColor: Color? = nil,
        voteScore: Int? = nil,
        userVoteStatus: UserVoteStatus? = nil,
        userId: Int, // ✨ ADD userId parameter ✨
        adminFeedback: String? = nil // ✨ ADD adminFeedback parameter ✨
        
    ) {
        self.id = id
        self.displayId = displayId
        self.title = title
        self.date = date
        self.url = url
        self.description = description
        self.category = category
        self.severity = severity
        self.user = user
        self.createdAt = createdAt
        self.evidences = evidences
        self.impacts = impacts
        self.severityScore = severityScore
        self.statusText = statusText
        self.statusColor = statusColor
        self.voteScore = voteScore
        self.userVoteStatus = userVoteStatus
        self.userId = userId // ✨ Assign userId ✨
        self.adminFeedback = adminFeedback // ✨ Assign adminFeedback ✨
    }
}
