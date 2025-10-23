//
//  AuthAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//
// este archivo define el `authapiservice`, un servicio especializado
// para manejar todas las llamadas a la api relacionadas con la autenticacion (login, registro).

// el servicio agrupa las funciones de login y registro.


import Foundation

struct AuthAPIService {
    
    // una instancia privada del cliente de red generico.
    private let networkClient = NetworkClient()
    
    // envia las credenciales al backend para iniciar sesion.
       // si tiene exito, devuelve un `loginresponsedto`. si falla, lanza un error.
    func login(credentials: LoginRequestDTO) async throws -> LoginResponseDTO {
        
      
        // bloque de depuracion para ver el json exacto que se esta enviando.
        if let data = try? JSONEncoder().encode(credentials), let jsonString = String(data: data, encoding: .utf8) {
            print("📤 Enviando JSON al servidor:\n\(jsonString)")
        }
        
        // llama al cliente de red para ejecutar la peticion post y decodificar la respuesta.
        return try await networkClient.request(
            endpoint: AppConfig.loginURL,
            method: "POST",
            body: credentials
        )
    }
    
    // envia los datos de un nuevo usuario al backend para registrarlo.
    // si tiene exito, no devuelve nada. si falla, lanza un error.

    func signUp(userData: SignUpRequestDTO) async throws {
        
        // bloque de depuracion para el json de registro.
        
        if let data = try? JSONEncoder().encode(userData), let jsonString = String(data: data, encoding: .utf8) {
            print("📤 Enviando JSON de registro al servidor:\n\(jsonString)")
        }
        
        // se llama a una version de `request` que no espera decodificar un cuerpo en la respuesta.
        
        try await networkClient.request(
            endpoint: AppConfig.registerURL,
            method: "POST",
            body: userData
        )
    }
}
