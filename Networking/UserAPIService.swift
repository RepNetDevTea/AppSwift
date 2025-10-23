//
//  UserAPIService.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//


import Foundation

// este archivo define el `userapiservice`, un servicio para todas las
// llamadas a la api que tienen que ver con el perfil del usuario.

// agrupa las funciones para obtener y actualizar el perfil de usuario.
// usa el `networkclient` generico para las peticiones.
struct UserAPIService {
    
    private let networkClient = NetworkClient()
    
    // recupera los datos del perfil del usuario que ha iniciado sesion.
    // es una peticion autenticada (`isauthenticated: true`), por lo que envia el token.
    // se asume que existe un `userprofileresponsedto` para decodificar la respuesta.
    func fetchUserProfile() async throws -> UserProfileResponseDTO {
        return try await networkClient.request(
            endpoint: AppConfig.userProfileURL,
            method: "GET",
            isAuthenticated: true
        )
    }
    
    // envia los datos actualizados del perfil al backend.
    // `data` es el dto con los nuevos datos y la contrasena de confirmacion.
    func updateUserProfile(data: UpdateProfileRequestDTO) async throws {
        // se usa el metodo "patch", que es para actualizaciones parciales.
        // a veces los backends usan "put". es importante confirmar cual se usa.
        try await networkClient.request(
            endpoint: AppConfig.userProfileURL,
            method: "PATCH",
            // el `dto` con los datos del formulario se envia como el cuerpo de la peticion.
            body: data,
            // esta tambien es una operacion que requiere que el usuario este logueado.
            isAuthenticated: true
        )
    }
    
    // aqui se podria anadir en el futuro la funcion para borrar la cuenta.
    // func deleteuser(password: string) async throws { ... }

        func deleteUser() async throws {
            try await networkClient.request(
                endpoint: AppConfig.userProfileURL,
                method: "DELETE",
                isAuthenticated: true
            )
        }
}
