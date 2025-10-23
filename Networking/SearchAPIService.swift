//
//  SearchAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

import Foundation

struct SearchAPIService {
    private let networkClient = NetworkClient()

    // Busca sitios por dominio, esperando un solo resultado o ninguno.
    func search(query: String) async throws -> SiteResponseDTO? { // <-- Devuelve un solo DTO opcional

        // Validación básica (solo busca si parece un dominio)
        guard query.contains(".") else {
             print("Formato de búsqueda inválido: \(query)")
             return nil // Devuelve nil si la consulta no es válida
        }

        // Usa URLComponents para construir la URL de forma segura
        guard var components = URLComponents(string: AppConfig.sitesURL) else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "siteDomain", value: query),
            URLQueryItem(name: "page", value: "1") // Mantenemos page=1 por si acaso
        ]

        guard let endpoint = components.url?.absoluteString else {
            throw APIError.invalidURL
        }

        print("➡️ Searching sites with URL: \(endpoint)")

        // ✨ CORRECCIÓN: Espera un solo objeto (SiteResponseDTO.self) ✨
        // Usa try? para manejar casos 404 (no encontrado) sin error de decodificación.
        let result: SiteResponseDTO? = try? await networkClient.request(
            endpoint: endpoint,
            method: "GET",
            isAuthenticated: false // Asumiendo búsqueda pública
        )
        return result
    }
}
