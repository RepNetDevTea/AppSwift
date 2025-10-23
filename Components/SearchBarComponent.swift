//
//  SearchBarComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 01/10/25.
//
// una barra de busqueda reutilizable con un icono de lupa y un boton para limpiar el texto

import SwiftUI

struct SearchBarComponent: View {
    // un binding al string que almacena el texto de la busqueda
    @Binding var text: String
    
    let placeholder: String

    var body: some View {
    // el hstack organiza el icono, el campo de texto y el boton de limpiar horizontalmente.
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)

            TextField(placeholder, text: $text)
                .foregroundColor(.textPrimary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
    // muestra el boton de limpiar solo si el usuario ha escrito algo.
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.textFieldBackground)
        .cornerRadius(12)
    }
}

// --- VISTA PREVIA AÑADIDA ---
struct SearchBarComponent_Previews: PreviewProvider {
    // Usamos una vista contenedora para poder usar @State con el @Binding.
    struct PreviewWrapper: View {
        @State private var searchTextEmpty = ""
        @State private var searchTextFilled = "aiura.com.mx"
        
        var body: some View {
            VStack(spacing: 20) {
                // Instancia para ver el estado vacío
                SearchBarComponent(
                    text: $searchTextEmpty,
                    placeholder: "Buscar por página o reporte..."
                )
                
                // Instancia para ver el estado con texto (y el botón de limpiar)
                SearchBarComponent(
                    text: $searchTextFilled,
                    placeholder: "Buscar por página o reporte..."
                )
            }
            .padding()
            .background(Color.appBackground)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
