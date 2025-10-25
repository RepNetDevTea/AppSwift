//
//  FilterButtonComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//


import SwiftUI

// boton de filtro en forma de pildora
// al tocarlo, muestra un menu desplegable con opciones
//

struct FilterButtonComponent: View {
    // binding al viewmodel, guarda la opcion seleccionada
    @Binding var selection: String
    // el array de strings con las opciones del menu
    let options: [String]
    // el nombre del icono de sf symbols a la izquierda
    let iconName: String

    var body: some View {
        // el componente principal es un menu
        Menu {
            // itera sobre las opciones y crea un boton para cada una
            ForEach(options, id: \.self) { option in
                Button(action: {
                    // al tocar, actualiza el estado en el viewmodel
                    selection = option
                }) {
                    Text(option)
                }
            }
        } label: {
            // esta es la etiqueta del menu
            HStack(spacing: 5) {
                Image(systemName: iconName)
                // el texto del boton siempre refleja la seleccion actual
                Text(selection)
            }
            .font(.caption)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(20)
        }
    }
}

// preview hecha con ia
struct FilterButtonComponent_Previews: PreviewProvider {
    // se usa un 'wrapper' para poder simular el @state
    struct PreviewWrapper: View {
        @State private var categorySelection = "Malware"
        let categories = ["Malware", "Phishing", "Otro"]
        
        @State private var sortSelection = "Severidad"
        let sortOptions = ["Severidad", "Fecha Asc", "Fecha Desc"]
        
        var body: some View {
            HStack {
                FilterButtonComponent(selection: $categorySelection, options: categories, iconName: "line.3.horizontal.decrease")
                FilterButtonComponent(selection: $sortSelection, options: sortOptions, iconName: "arrow.up.arrow.down")
            }
            .padding()
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
