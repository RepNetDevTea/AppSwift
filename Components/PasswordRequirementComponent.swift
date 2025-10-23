//
//  PasswordRequirementComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//
// una vista simple que muestra una sola linea de requisito para una contrasena.
// cambia su icono y color (exito, fallo, neutral) basado en un `validationstate`.
// este componente dependia del enum `validationstate` pero se elimino

import SwiftUI



struct PasswordRequirementComponent: View {
    //texto de requerimientos a mostrar
    let requirement: String
    //estado de validacion actual
    let state: ValidationState

    var body: some View {
        HStack {
            //icono se agarra del estado de validacion
            Image(systemName: state.iconName)
            Text(requirement)
            Spacer()
        }
        .font(.caption)
        //color y texto tambien dependen del estado de valdiacion
        .foregroundColor(state.color)
    }
}

//preview
struct PasswordRequirementComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 10) {
            PasswordRequirementComponent(requirement: "8 caracteres mínimo.", state: .neutral)
            PasswordRequirementComponent(requirement: "1 caracter especial (!@#$%^&*?).", state: .success)
            PasswordRequirementComponent(requirement: "1 caracter numérico (1 2 3 4).", state: .failure)
        }
        .padding()
    }
}
