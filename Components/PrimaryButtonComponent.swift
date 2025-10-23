//
//  PrimaryButtonComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//
//boton reutilizable que representa la accion principal
//

import SwiftUI

struct PrimaryButtonComponent: View {
    //texto dentro del boton
    let title: String
    //accion cuando se preciona el boton
    let action: () -> Void
    //booleano que controla si el boton esta interactuando ono
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.buttonFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
            //cambio de color
                .background(isEnabled ? Color.primaryBlue : Color.disabledGray)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }
}

//preview hecha con ia
#Preview {
    VStack(spacing: 20) {
        PrimaryButtonComponent(title: "Botón Activado", action: {}, isEnabled: true)
        PrimaryButtonComponent(title: "Botón Desactivado", action: {}, isEnabled: false)
    }
    .padding()
}
