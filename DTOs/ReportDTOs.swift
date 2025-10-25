//
//  ReportDTOs.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//


import Foundation


// MARK: - DTOs request

struct TagImpactID: Encodable {
    let id: Int
}

// dto para crear un nuevo repore
struct CreateReportRequestDTO: Encodable {
    let reportTitle: String
    let reportUrl: String
    let reportDescription: String
    let siteDomain: String
    let tags: [TagImpactID]
    let impacts: [TagImpactID]
}

// dto para actualizar un reporte
struct UpdateReportRequestDTO: Encodable {
    var reportTitle: String? = nil
    var reportUrl: String? = nil
    var reportDescription: String? = nil
    var addedTags: [String]? = nil
    var deletedTags: [String]? = nil
    var addedImpacts: [String]? = nil
    var deletedImpacts: [String]? = nil
}

// MARK: - DTOs Response

struct CreateReportResponseDTO: Decodable {
    let id: Int
}

// dto principal para recibir un reporte completo
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
    
    // objetos anidados
    let site: SiteDTO?
    let user: UserInReportDTO?

    // listas anidadas
    let votes: [VoteDTO]
    let evidences: [EvidenceResponseDTO]
    
    //  listasm de is
    let tags: [ReportTagIdDTO]
    let impacts: [ReportImpactIdDTO]
}


// MARK: - Componentes de Respuesta

// struct para leer tags
struct ReportTagIdDTO: Decodable, Hashable {
    let tagId: Int
}

// struct para leer impacts
struct ReportImpactIdDTO: Decodable, Hashable {
    let impactId: Int
}

// dto para la informacion del sitio
struct SiteDTO: Decodable {
    let id: Int
    let siteDomain: String
}

// dto para la informacion del usuario que reporta
struct UserInReportDTO: Decodable, Equatable {
    let username: String
}

// dto para la informacion de un voto
struct VoteDTO: Decodable {
    let userId: Int
    let voteType: String
}

// dto para la informacion de una evidencia
struct EvidenceResponseDTO: Decodable, Identifiable {
    let id: Int
    let evidenceType: String
    let evidenceKey: String?
    let evidenceFileUrl: String?
    let evidenceFileUri: String?
}
