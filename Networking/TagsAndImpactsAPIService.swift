//
//  TagsAndImpactsAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 20/10/25.
//


import Foundation

// este archivo define el 'tagsandimpactsapiservice'
// es un servicio simple que solo se usa para cargar las listas
// completas de tags e impacts desde el backend
//

struct TagsAndImpactsAPIService {
    
    // una instancia privada del cliente de red generico
    private let networkClient = NetworkClient()
    
    
    // obtiene la lista completa de todos los tags disponibles
    func fetchAllTags() async throws -> [Tag] {
        return try await networkClient.request(endpoint: AppConfig.tagsURL, method: "GET")
    }
    
    // obtiene la lista completa de todos los impacts disponibles
    func fetchAllImpacts() async throws -> [Impact] {
        return try await networkClient.request(endpoint: AppConfig.impactsURL, method: "GET")
    }
}
