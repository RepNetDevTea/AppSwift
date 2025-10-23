//
//  FilterButtonComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
//boton en forma de pildora disenado para ser usado en filtros y ordenes



import SwiftUI

struct FilterButtonComponent: View {
    //binding para guardar input
    @Binding var selection: String
    //arreglo que muestra opciones
    let options: [String]
    //nombre del icono a la izqueirda
    let iconName: String

    var body: some View {
        //en si es un menu
        Menu {
            //cada elemento del arreglo se convierte en un boton del menu
            ForEach(options, id: \.self) { option in
                Button(action: {
                    //se actuaaliza el boton del binding
                    selection = option
                }) {
                    Text(option)
                }
            }
        } label: {
            //etiqueta del menu, lo que el usuario ve
            HStack(spacing: 5) {
                Image(systemName: iconName)
                //texto del menu refleja seleccion actual
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

