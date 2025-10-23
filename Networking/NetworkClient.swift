//
//  NetworkClient.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case serverError(message: String)
}

struct NetworkClient {
    
    // Función para peticiones que SÍ devuelven datos.
    func request<T: Decodable>(endpoint: String, method: String, body: (any Encodable)? = nil, isAuthenticated: Bool = false) async throws -> T {
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if isAuthenticated {
            guard let token = KeychainService.getAccessToken() else {
                print("❌ error: no se encontro el accesstoken para una peticion autenticada.")
                throw APIError.serverError(message: "no se encontro el token de autenticacion.")
            }
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(body)
                request.httpBody = data
                
                // Print para depuración
                print("📤 Cuerpo (Body) del JSON enviado:\n\(String(data: data, encoding: .utf8) ?? "No se pudo decodificar el body")")

            } catch {
                print("❌ Error al codificar el body para la petición: \(error)")
                throw error
            }
        }
        
        print("➡️ enviando peticion: \(request.httpMethod ?? "") a \(endpoint)")
        print("    headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(statusCode: 0)
        }
        
        print("⬅️ respuesta recibida con codigo: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data), let message = errorResponse["message"] {
                throw APIError.serverError(message: message)
            }
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // ✨ CORREGIDO: Se añadió el mismo bloque de depuración a la función que NO devuelve datos.
    // Función para peticiones que NO devuelven datos.
    func request(endpoint: String, method: String, body: (any Encodable)? = nil, isAuthenticated: Bool = false) async throws {
        
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if isAuthenticated {
            guard let token = KeychainService.getAccessToken() else { throw APIError.serverError(message: "no authentication token found.") }
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(body)
                request.httpBody = data
                
                // Print para depuración (añadido aquí también)
                print("📤 Cuerpo (Body) del JSON enviado:\n\(String(data: data, encoding: .utf8) ?? "No se pudo decodificar el body")")

            } catch {
                print("❌ Error al codificar el body para la petición: \(error)")
                throw error
            }
        }
        
        print("➡️ enviando peticion: \(request.httpMethod ?? "") a \(endpoint)")
        print("    headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse(statusCode: 0) }
        
        print("⬅️ respuesta recibida con codigo: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data), let message = errorResponse["message"] {
                throw APIError.serverError(message: message)
            }
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    
    /// --- NUEVA FUNCIÓN AÑADIDA ---
        /// Realiza una petición de red para subir un archivo en formato multipart/form-data.
        /// - Parameters:
        ///   - endpoint: La URL completa del endpoint.
        ///   - imageData: Los datos binarios de la imagen.
        ///   - fieldName: El nombre del campo que el backend espera para el archivo (ej. "file").
        ///   - fileName: El nombre que tendrá el archivo en el servidor.
        ///   - isAuthenticated: Si la petición requiere el token de autenticación.
        func upload(endpoint: String, imageData: Data, fieldName: String, fileName: String, isAuthenticated: Bool) async throws {
            guard let url = URL(string: endpoint) else {
                throw APIError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            if isAuthenticated {
                guard let token = KeychainService.getAccessToken() else {
                    throw APIError.serverError(message: "No authentication token found.")
                }
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            // Construye el cuerpo de la petición multipart
            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            // Realiza la llamada de red
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse(statusCode: 0)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data), let message = errorResponse["message"] {
                    throw APIError.serverError(message: message)
                }
                throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
            }
            
            print("✅ Archivo subido exitosamente a \(endpoint)")
        }
    
    
}
