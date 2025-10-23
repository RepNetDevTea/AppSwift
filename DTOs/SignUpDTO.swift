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
    
    
    // `codingkeys` se usa para mapear los nombres de nuestras propiedades
        // a nombres diferentes en el json que se envia al servidor.
    enum CodingKeys: String, CodingKey {
        // estas propiedades se envian en el json con el mismo nombre que tienen aqui.
        case name, fathersLastName, mothersLastName, username, email
        
        // aqui le decimos que nuestra propiedad `password` debe llamarse `hashedpassword` en el json.
        // esto es util si el backend espera un nombre diferente al que usamos en swift.
        case password = "hashedPassword"
    }
}
