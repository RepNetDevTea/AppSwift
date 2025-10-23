//
//  DeleteAccountConfirmationComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 22/10/25.
//


import SwiftUI

/// Componente reutilizable para la confirmación de eliminación de cuenta.
struct DeleteAccountConfirmationComponent: View {
    @Binding var isPresented: Bool
    @Binding var password: String
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Eliminar mi cuenta")
                    .font(.headline)
                Text("Esta acción es permanente. Para confirmar, por favor introduce tu contraseña.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                HStack {
                    Button("Cancelar") {
                        isPresented = false
                        password = ""
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.textPrimary)
                    .cornerRadius(12)
                    
                    Button("Sí, eliminar", role: .destructive, action: onDelete)
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
            .padding(40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4).ignoresSafeArea())
    }
}
