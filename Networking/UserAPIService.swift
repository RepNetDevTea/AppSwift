//
//  UserAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//

import Foundation

// este archivo define el 'userapiservice', un servicio para todas las
// llamadas a la api que tienen que ver con el perfil del usuario
//
// agrupa las funciones para obtener, actualizar y eliminar el perfil
// usa el 'networkclient' generico para las peticiones
//

struct UserAPIService {
    
    // una instancia privada del cliente de red generico
    private let networkClient = NetworkClient()
    
    
    // recupera los datos del perfil del usuario que ha iniciado sesion (get /users/me)
    // es una peticion autenticada, por lo que envia el token
    // devuelve un 'userprofileresponsedto' con los datos del usuario
    func fetchUserProfile() async throws -> UserProfileResponseDTO {
        return try await networkClient.request(
            endpoint: AppConfig.userProfileURL,
            method: "GET",
            isAuthenticated: true
        )
    }
    
    // envia los datos actualizados del perfil al backend (patch /users/me)
    // 'data' es el dto que contiene todos los campos (llenos o nulos)
    func updateUserProfile(data: UpdateProfileRequestDTO) async throws {
        // se usa el metodo "patch" para actualizaciones
        // usa la funcion 'request' que no espera un cuerpo de respuesta
        try await networkClient.request(
            endpoint: AppConfig.userProfileURL,
            method: "PATCH",
            body: data, // el dto se envia como el cuerpo json
            isAuthenticated: true // requiere token
        )
    }
    
    // envia la peticion para eliminar la cuenta del usuario (delete /users/me)
    func deleteUser() async throws {
        try await networkClient.request(
            endpoint: AppConfig.userProfileURL,
            method: "DELETE",
            isAuthenticated: true // requiere token
        )
    }
}
