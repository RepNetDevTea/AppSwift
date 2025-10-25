//
//  SearchAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

import Foundation

// este archivo define el 'searchapiservice'
// es un servicio especifico para la funcionalidad de busqueda
// se conecta al endpoint 'get /sites'
//

struct SearchAPIService {
    
    // una instancia privada del cliente de red generico
    private let networkClient = NetworkClient()

    // MARK: - Funcion de Busqueda
    
    // busca un sitio por dominio, esperando un solo 'siteresponsedto' o 'nil'
    func search(query: String) async throws -> SiteResponseDTO? {

        // validacion basica, solo busca si el texto incluye un '.'
        guard query.contains(".") else {
            print("formato de busqueda invalido: \(query)")
            return nil // devuelve nil si la consulta no es un dominio valido
        }

        // usa urlcomponents para construir la url de forma segura
        guard var components = URLComponents(string: AppConfig.sitesURL) else {
            throw APIError.invalidURL
        }

        // anade los parametros 'sitedomain' y 'page' a la url
        components.queryItems = [
            URLQueryItem(name: "siteDomain", value: query),
            URLQueryItem(name: "page", value: "1") // se usa '1' como pagina por defecto
        ]

        guard let endpoint = components.url?.absoluteString else {
            throw APIError.invalidURL
        }

        print("➡️ searching sites with url: \(endpoint)")

       
        // se usa 'try?' para manejar un error 404 (no encontrado) como 'nil'
        // esto evita que la app falle si la api no devuelve nada
        let result: SiteResponseDTO? = try? await networkClient.request(
            endpoint: endpoint,
            method: "GET",
            isAuthenticated: false // la busqueda es publica
        )
        return result
    }
}
