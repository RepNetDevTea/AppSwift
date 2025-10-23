//
//  TagsAndImpactsAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 20/10/25.
//


import Foundation

struct TagsAndImpactsAPIService {
    private let networkClient = NetworkClient()
    
    func fetchAllTags() async throws -> [Tag] {
        // Asumimos que AppConfig.tagsURL apunta a http://.../tags
        return try await networkClient.request(endpoint: AppConfig.tagsURL, method: "GET")
    }
    
    func fetchAllImpacts() async throws -> [Impact] {
        // Asumimos que AppConfig.impactsURL apunta a http://.../impacts
        return try await networkClient.request(endpoint: AppConfig.impactsURL, method: "GET")
    }
}