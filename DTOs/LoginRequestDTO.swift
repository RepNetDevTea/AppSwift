//
//  LoginRequestDTO.swift
//  RepNet
//
//  Created by Angel Bosquez on 01/10/25.
//

import Foundation

import Foundation

// El 'struct' que enviamos al backend. No necesita cambios.
struct LoginRequestDTO: Codable {
    let email: String
    let password: String
}

// El 'struct' que recibimos del backend, ahora corregido.
struct LoginResponseDTO: Decodable {
    let user: UserDTO
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
          case user
          case accessToken, refreshToken
      }
}

// El DTO para los datos del usuario. Ya está correcto, ya que solo
// decodifica los campos que necesita e ignora los demás (como hashedPassword).
struct UserDTO: Decodable {
    let id: Int
    let name: String
    let fathersLastName: String
    let mothersLastName: String
    let username: String
    let email: String
}

