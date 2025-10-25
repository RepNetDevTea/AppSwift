//
//  NetworkClient.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//

import Foundation

// este archivo es el centro de red de la app
//ia sugirio tener un cliente generico para no tener un archivo mas largo 
// define el 'networkclient', que es un cliente http generico
// todos los 'apiservice' (auth, reports, etc) usan este cliente
// para hacer las llamadas reales a la api

// MARK: - API Error

// define los errores personalizados que puede lanzar el networkclient
// esto ayuda a los viewmodels a saber que tipo de error ocurrio
enum APIError: Error {
    case invalidURL // la url que se le paso no es valida
    case invalidResponse(statusCode: Int) // la api devolvio un codigo de error (ej. 404, 500)
    case decodingError(Error) // no se pudo convertir el json de la api a nuestros dtos
    case serverError(message: String) // el servidor devolvio un mensaje de error especifico
}

// MARK: - Network Client

struct NetworkClient {
    
    // MARK: - Peticion GET
    
    // funcion principal para peticiones que devuelven un cuerpo json
    // es generica (<t>), puede decodificar cualquier tipo que sea 'decodable'
    func request<T: Decodable>(endpoint: String, method: String, body: (any Encodable)? = nil, isAuthenticated: Bool = false) async throws -> T {
        
        // 1. crear la url y la peticion basica
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2. si la peticion requiere autenticacion, anade el token
        if isAuthenticated {
            guard let token = KeychainService.getAccessToken() else {
                print("❌ error: no se encontro el accesstoken para una peticion autenticada.")
                throw APIError.serverError(message: "no se encontro el token de autenticacion.")
            }
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 3. si la peticion tiene un cuerpo (body), se codifica a json
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted // para logs legibles
                let data = try encoder.encode(body)
                request.httpBody = data
                
                // print de depuracion
                print("📤 Cuerpo (Body) del JSON enviado:\n\(String(data: data, encoding: .utf8) ?? "No se pudo decodificar el body")")

            } catch {
                print("❌ Error al codificar el body para la peticion: \(error)")
                throw error
            }
        }
        
        // 4. prints de depuracion para la peticion
        print("➡️ enviando peticion: \(request.httpMethod ?? "") a \(endpoint)")
        print("    headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // 5. se ejecuta la llamada a la red
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(statusCode: 0)
        }
        
        print("⬅️ respuesta recibida con codigo: \(httpResponse.statusCode)")
        
        // 6. se valida que el codigo de estado sea exitoso (200-299)
        guard (200...299).contains(httpResponse.statusCode) else {
            // si es un error, se intenta leer un mensaje de error del json
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data), let message = errorResponse["message"] {
                throw APIError.serverError(message: message)
            }
            // si no, se lanza un error generico con el codigo
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 7. si todo salio bien, se decodifica el json al tipo 't' esperado
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // si la decodificacion falla, se lanza un error especifico
            print("❌ Error al decodificar respuesta: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Peticion  POST, PATCH
    
    // sobrecarga de la funcion para peticiones donde no esperamos un cuerpo json de vuelta
    // (ej. signup, update, delete). solo nos importa si la operacion fue exitosa (codigo 20x)
    func request(endpoint: String, method: String, body: (any Encodable)? = nil, isAuthenticated: Bool = false) async throws {
        
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if isAuthenticated {
            guard let token = KeychainService.getAccessToken() else { throw APIError.serverError(message: "no authentication token found.") }
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // la logica para codificar y printear el body es identica
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(body)
                request.httpBody = data
                
                print("📤 Cuerpo (Body) del JSON enviado:\n\(String(data: data, encoding: .utf8) ?? "No se pudo decodificar el body")")

            } catch {
                print("❌ Error al codificar el body para la peticion: \(error)")
                throw error
            }
        }
        
        print("➡️ enviando peticion: \(request.httpMethod ?? "") a \(endpoint)")
        print("    headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // la logica de la llamada y manejo de errores es identica
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse(statusCode: 0) }
        
        print("⬅️ respuesta recibida con codigo: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data), let message = errorResponse["message"] {
                throw APIError.serverError(message: message)
            }
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        // no hay paso 7, porque no decodificamos un cuerpo de exito
    }
    
    // MARK: - Peticion de Subida (Multipart)
    
    // funcion especial para subir archivos (imagenes)
    // usa formato 'multipart/form-data' en lugar de json
    func upload(endpoint: String, imageData: Data, fieldName: String, fileName: String, isAuthenticated: Bool) async throws {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 1. se crea un 'boundary' unico para separar las partes del body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 2. se anade el token si es necesario
        if isAuthenticated {
            guard let token = KeychainService.getAccessToken() else {
                throw APIError.serverError(message: "No authentication token found.")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 3. se construye el cuerpo de la peticion 'multipart'
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // 4. se ejecuta la llamada
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(statusCode: 0)
        }
        
        print("⬅️ respuesta de subida recibida con codigo: \(httpResponse.statusCode)")
        
        // 5. se maneja la respuesta (logica de error identica)
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data), let message = errorResponse["message"] {
                throw APIError.serverError(message: message)
            }
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        print("✅ Archivo subido exitosamente a \(endpoint)")
    }
}
