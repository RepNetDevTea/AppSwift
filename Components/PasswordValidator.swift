//
//  PasswordValidator.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//

import Foundation
import SwiftUI

// define toda la logica para validar contrasenas
// incluye los estados visuales


// MARK: - ValidationState

enum ValidationState {
    case neutral
    case success
    case failure
    
    var iconName: String {
        switch self {
        case .neutral: return "circle"
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .neutral: return .textSecondary
        case .success: return .green
        case .failure: return .errorRed
        }
    }
}


// MARK: - PasswordRequirement


enum PasswordRequirement: String, CaseIterable {
    case minLength = "8 caracteres minimo."
    case maxLength = "20 caracteres maximo."
    case hasUppercase = "1 letra mayuscula."
    case hasNumber = "1 numero."
    case hasSpecialChar = "1 caracter especial (!@#$%^&*?)."
}



// MARK: - PasswordValidator

struct PasswordValidator {
    
    static func validate(password: String) -> [PasswordRequirement: ValidationState] {
        var states: [PasswordRequirement: ValidationState] = [:]
        
        // si el campo esta vacio, todos los requisitos estan en 'neutral'
        if password.isEmpty {
            PasswordRequirement.allCases.forEach { states[$0] = .neutral }
            return states
        }
        
        // validacion de cada requisito individual
        states[.minLength] = password.tieneLongitudMinima ? .success : .failure
        states[.maxLength] = password.tieneLongitudMaxima ? .success : .failure
        states[.hasUppercase] = password.tieneMayuscula ? .success : .failure
        states[.hasNumber] = password.tieneNumero ? .success : .failure
        states[.hasSpecialChar] = password.tieneCaracterEspecial ? .success : .failure
        
        return states
    }
}
