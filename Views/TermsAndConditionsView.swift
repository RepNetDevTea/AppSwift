//
//  TermsAndConditionsView.swift
//  RepNet
//
//  Created by Angel Bosquez on 18/10/25.
//


import SwiftUI

struct TermsAndConditionsView: View {
    
    // El 'presentationMode' nos permite cerrar esta vista modal.
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        // Usamos un ZStack para poner el color de fondo en toda la pantalla.
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // --- Encabezado ---
                HStack {
                    Text("Términos y Condiciones")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    // Botón para cerrar la vista modal
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                
                // --- Tarjeta con el Contenido ---
                ScrollView {
                    // Usamos texto de ejemplo (Lorem Ipsum).
                    // En una app real, aquí iría el texto legal completo.
                    Text("""
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
                    
                    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
                    
                    Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
                    """)
                    .font(.bodyText)
                    .foregroundColor(.textSecondary)
                }
                .padding()
                .background(Color.textFieldBackground)
                .cornerRadius(16)
            }
            .padding()
        }
    }
}

// Vista previa para poder diseñar la pantalla de forma aislada.
struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}