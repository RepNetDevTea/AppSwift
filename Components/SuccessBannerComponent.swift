//
//  SuccessBannerComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//
//banner simple que se extiende a lo ancho para mostrar un mensaje de exito.
// tiene un estilo visual predefinido con colores verdes para indicar una operacion exitosa.

import SwiftUI

struct SuccessBannerComponent: View {
    
    //mensaje de exito 
    let message: String
    
    var body: some View {
        Text(message)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.green)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
    }
}
//hola emi we
