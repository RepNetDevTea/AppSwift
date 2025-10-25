//
//  LoginRequestDTO.swift
//  RepNet
//
//  Created by Angel Bosquez on 01/10/25.
//

import Foundation

struct LoginRequestDTO: Codable {
    let email: String
    let password: String
}

struct LoginResponseDTO: Decodable {
    let user: UserDTO
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
          case user
          case accessToken, refreshToken
      }
}

//hola profe
struct UserDTO: Decodable {
    let id: Int
    let name: String
    let fathersLastName: String
    let mothersLastName: String
    let username: String
    let email: String
}

