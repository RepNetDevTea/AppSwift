//
//  PasswordRequirementComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//


import SwiftUI

import SwiftUI

// simple linea de texto con un icono
// se usa para mostrar un solo requisito de contrasena
// el icono y el color cambian (verde, rojo, gris) segun el estado de validacion
//

struct PasswordRequirementComponent: View {
    // el texto del requisito a mostrar
    let requirement: String
    // el estado actual (neutral, success, failure)
    let state: ValidationState

    var body: some View {
        HStack {
            Image(systemName: state.iconName)
            Text(requirement)
            Spacer()
        }
        .font(.caption)
        .foregroundColor(state.color)
    }
}

// preview hecha con ia
struct PasswordRequirementComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 10) {
            PasswordRequirementComponent(requirement: "8 caracteres minimo.", state: .neutral)
            PasswordRequirementComponent(requirement: "1 caracter especial (!@#$%^&*?).", state: .success)
            PasswordRequirementComponent(requirement: "1 caracter numerico (1 2 3 4).", state: .failure)
        }
        .padding()
    }
}
