//
//  SignUpDTO.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//
// define el dto para la peticion de registro de un nuevo usuario.

import Foundation

struct SignUpRequestDTO: Encodable {
    let name: String
    let fathersLastName: String
    let mothersLastName: String
    let username: String
    let email: String
    let password: String
    
    
   //sugerido de ia por la discrepancia de nombres
    enum CodingKeys: String, CodingKey {
        case name, fathersLastName, mothersLastName, username, email
        case password = "hashedPassword"
    }
}
