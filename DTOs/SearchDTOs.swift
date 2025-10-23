//
//  SearchDTOs.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

// este archivo define el dto para los resultados de la busqueda.
// la api de busqueda devuelve directamente un arreglo de estos objetos: `[siteresponsedto]`

import Foundation

// Ya no necesitamos un 'SearchResponseDTO' que envuelva la lista.
// El APIService ahora esperará directamente un array: [SiteResponseDTO]

// Este DTO representa un único objeto de sitio devuelto por la API.
// Los nombres de las claves coinciden con tu base de datos (en formato camelCase).

// DTO for the site search response
struct SiteResponseDTO: Decodable, Identifiable {
    let id: Int
    let siteDomain: String
    let siteReputation: Int
    // Needs to use the ReportResponseDTO which handles nested tags/impacts
    let reports: [ReportResponseDTO]
    // createdAt and updatedAt can be ignored if not needed
}
