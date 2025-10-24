//
//  SearchDTOs.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

// este archivo define el dto para los resultados de la busqueda.
// la api de busqueda devuelve directamente un arreglo de estos objetos: `[siteresponsedto]`

import Foundation

// 1. DTO para el Sitio (el objeto principal de la respuesta)
struct SiteResponseDTO: Decodable, Identifiable {
    let id: Int
    let siteDomain: String
    let siteReputation: Int
    let reports: [SearchReportDTO]
}

// 2. DTO para el Reporte anidado en la búsqueda
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
    
    // ✨ CORREGIDO: Hechas opcionales para que coincidan con el JSON de x.com
    let votes: [VoteDTO]?
    let evidences: [EvidenceResponseDTO]?
    
    let tags: [SearchReportTagDTO]
    let impacts: [SearchReportImpactDTO]
}

// 3. DTOs Wrapper (para leer el formato anidado {"tag": {...}})
struct SearchReportTagDTO: Decodable, Hashable {
    let tag: SearchTagDetailDTO
}
struct SearchTagDetailDTO: Decodable, Hashable {
    let tagName: String
}
struct SearchReportImpactDTO: Decodable, Hashable {
    let impact: SearchImpactDetailDTO
}
struct SearchImpactDetailDTO: Decodable, Hashable {
    let impactName: String
}

// Nota: UserInReportDTO, VoteDTO, y EvidenceResponseDTO
// se asume que están definidos globalmente (en ReportDTOs.swift) y se pueden reutilizar.
