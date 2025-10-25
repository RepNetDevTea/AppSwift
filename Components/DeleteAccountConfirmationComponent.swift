//
//  DeleteAccountConfirmationComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 22/10/25.
//


import SwiftUI

//  vista modal para confirmar la eliminacion de la cuenta
// recibe bindings para controlar su visibilidad y para obtener la contrasena
// tambien recibe una accion 'onDelete' que se ejecuta al confirmar
//


struct DeleteAccountConfirmationComponent: View {
    
    // binding para controlar si el modal esta visible o no
    @Binding var isPresented: Bool
    // binding para guardar la contrasena que el usuario escribe
    @Binding var password: String
    // la accion que se llama cuando el usuario confirma la eliminacion
    let onDelete: () -> Void
    
    var body: some View {
        // vstack principal que centra la alerta y pone el fondo oscuro
        VStack {
            // vstack para el contenido de la alerta (la caja blanca)
            VStack(spacing: 20) {
                Text("Eliminar mi cuenta")
                    .font(.headline)
                
                Text("Esta accion es permanente. Para confirmar, por favor introduce tu contrasena.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                // campo de texto seguro para la contrasena
                SecureField("Contrasena", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                // hstack para los botones de accion
                HStack {
                    Button("Cancelar") {
                        isPresented = false
                        password = "" // limpia la contrasena al cancelar
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.textPrimary)
                    .cornerRadius(12)
                    
                    // boton de eliminar
                    Button("Si, eliminar", role: .destructive, action: onDelete)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.errorRed)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.textFieldBackground)
            .cornerRadius(16)
            .shadow(radius: 20)
            .padding(40) // da espacio alrededor del modal
            
            Spacer() // empuja el modal hacia arriba
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4).ignoresSafeArea())
    }
}
