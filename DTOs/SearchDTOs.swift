//
//  SearchDTOs.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//


import Foundation

// edefine los dtos para la respuesta de la api de busqueda
// la estructura de los reportes aqui es diferente a la de get /reports

// MARK: - DTO  de Sitio

struct SiteResponseDTO: Decodable, Identifiable {
    let id: Int
    let siteDomain: String
    let siteReputation: Int
    let reports: [SearchReportDTO]
}

// MARK: - DTO de Reporte Anidado

// dto para el reporte que viene anidado dentro del sitio
struct SearchReportDTO: Decodable, Identifiable {
    let id: Int
    let reportTitle: String
    let reportUrl: String
    let reportDescription: String
    let reportStatus: String
    let severity: Int
    let userId: Int
    let createdAt: String
    let adminFeedback: String?
    let user: UserInReportDTO?
    let votes: [VoteDTO]?
    let evidences: [EvidenceResponseDTO]?
        let tags: [SearchReportTagDTO]
    let impacts: [SearchReportImpactDTO]
}

// MARK: - wrappers


struct SearchReportTagDTO: Decodable, Hashable {
    // el contenedor "tag"
    let tag: SearchTagDetailDTO
}
struct SearchTagDetailDTO: Decodable, Hashable {
    // el nombre del tag que viene adentro
    let tagName: String
}

struct SearchReportImpactDTO: Decodable, Hashable {
    // el contenedor "impact"
    let impact: SearchImpactDetailDTO
}
struct SearchImpactDetailDTO: Decodable, Hashable {
    // el nombre del impacto que viene adentro
    let impactName: String
}

