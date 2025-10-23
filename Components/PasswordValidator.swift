//
//  PasswordValidator.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
//parte logica de passwordrequirementcontroller

import Foundation
import SwiftUI

// este enum define el estado visual de un requisito de contrasena (color e icono).
// se usa en la ui para mostrar si un requisito se cumple, no se cumple o esta pendiente.

enum ValidationState {
    case neutral
    case success
    case failure
//simbolos para el estado
    var iconName: String {
        switch self {
        case .neutral: return "circle"
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }
//colores para el estado
    var color: Color {
        switch self {
        case .neutral: return .textSecondary
        case .success: return .green
        case .failure: return .errorRed
        }
    }
}

// este enum define todas las reglas de contrasena que se deben validar.
// el tipo es `string` para tener el texto descriptivo de cada regla.
// `caseiterable` permite iterar sobre todos los casos
enum PasswordRequirement: String, CaseIterable {
    case minLength = "8 caracteres mínimo."
    case maxLength = "20 caracteres máximo."
    case hasUppercase = "1 letra mayúscula."
    case hasNumber = "1 número."
    case hasSpecialChar = "1 caracter especial (!@#$%^&*?)."
}


struct PasswordValidator {
    
    // valida una contrasena dada contra todos los `passwordrequirement`.
    // devuelve un diccionario que mapea cada requisito a su estado de validacion.
    
    static func validate(password: String) -> [PasswordRequirement: ValidationState] {
        var states: [PasswordRequirement: ValidationState] = [:]
        
        //si el campo esta vacio devuelve neutral
        
        if password.isEmpty {
            PasswordRequirement.allCases.forEach { states[$0] = .neutral }
            return states
        }
        
        //validacion de requisitos de manera individual
        states[.minLength] = password.tieneLongitudMinima ? .success : .failure
        states[.maxLength] = password.tieneLongitudMaxima ? .success : .failure
        states[.hasUppercase] = password.tieneMayuscula ? .success : .failure
        states[.hasNumber] = password.tieneNumero ? .success : .failure
        states[.hasSpecialChar] = password.tieneCaracterEspecial ? .success : .failure
        
        return states
    }
}
