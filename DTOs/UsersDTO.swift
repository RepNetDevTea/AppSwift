//
//  UsersDTO.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//
//Nota para Emi: este tiene problemas con el JWTauthguard, como tal si se conecta pero no lo deja pasar -- ARREGLADO

import Foundation

// este archivo define los dtos del perfil de usuario

// MARK: - DTO Response

//  get /users/me
struct UserProfileResponseDTO: Decodable {
    let name: String
    let fathersLastName: String
    let mothersLastName: String
    let email: String
    let username: String
}

// MARK: - DTOs Request

//  actualizar el perfil (patch /users/me)
struct UpdateProfileRequestDTO: Encodable {
    var name: String? = nil
    var fathersLastName: String? = nil
    var mothersLastName: String? = nil
    var username: String? = nil
    var email: String? = nil
    var hashedPassword: String? = nil
}

// este dto se usa para eliminar la cuenta (delete /users/me)
// esta vacio porque la autorizacion se maneja por el token
struct DeleteAccountRequestDTO: Encodable {
    // no necesita cuerpo
}
