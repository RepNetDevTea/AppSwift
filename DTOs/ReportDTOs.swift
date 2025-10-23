//
//  ReportDTOs.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//
// este archivo define los dtos para crear y recibir reportes de la api.

import Foundation

// --- DTOs para ENVIAR (Crear/Actualizar) ---

struct TagImpactID: Encodable {
    let id: Int
}

struct CreateReportRequestDTO: Encodable {
    let reportTitle: String
    let reportUrl: String
    let reportDescription: String
    let siteDomain: String
    let tags: [TagImpactID]
    let impacts: [TagImpactID]
}

struct UpdateReportRequestDTO: Encodable {
    var reportTitle: String? = nil
    var reportUrl: String? = nil
    var reportDescription: String? = nil
    var addedTags: [String]? = nil
    var deletedTags: [String]? = nil
    var addedImpacts: [String]? = nil
    var deletedImpacts: [String]? = nil
}

// --- DTOs para RECIBIR (Respuestas de la API) ---

struct CreateReportResponseDTO: Decodable {
    let id: Int
}

// ✨ NUEVO: Struct para leer {"tagId": X, "reportId": Y}
struct ReportTagIdDTO: Decodable, Hashable {
    let tagId: Int
    // reportId is ignored for now
}

// ✨ NUEVO: Struct para leer {"impactId": X, "reportId": Y}
struct ReportImpactIdDTO: Decodable, Hashable {
    let impactId: Int
    // reportId is ignored for now
}

// DTO principal para recibir un reporte completo.
struct ReportResponseDTO: Decodable, Identifiable {
    let id: Int
    let reportTitle: String
    let reportUrl: String
    let reportDescription: String
    let reportStatus: String
    let severity: Int
    let createdAt: String
    let adminFeedback: String?
    let siteId: Int
    let userId: Int
    let updatedAt: String
    let site: SiteDTO?
    let user: UserInReportDTO?

    let votes: [VoteDTO]
    let evidences: [EvidenceResponseDTO]

    // ✨ CORREGIDO: Usan los nuevos DTOs que solo contienen IDs.
    let tags: [ReportTagIdDTO]
    let impacts: [ReportImpactIdDTO]
}


// --- Sub-DTOs para las respuestas ---

struct SiteDTO: Decodable {
    let id: Int
    let siteDomain: String
}

struct UserInReportDTO: Decodable, Equatable {
    let username: String
}

struct VoteDTO: Decodable {
    let userId: Int
    let voteType: String
}

struct EvidenceResponseDTO: Decodable, Identifiable {
    let id: Int
    let evidenceType: String
    let evidenceKey: String?
    let evidenceFileUrl: String?
    let evidenceFileUri: String?
}

// ✨ ELIMINADO: ReportTagDTO, TagDetailDTO, ReportImpactDTO, ImpactDetailDTO
// Ya no son necesarios porque haremos el mapeo de IDs en el ViewModel.
