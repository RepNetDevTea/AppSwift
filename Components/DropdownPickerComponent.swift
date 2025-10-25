//
//  DropdownPickerComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//



import SwiftUI

// componente es un selector desplegable
// muestra un boton con un titulo y al tocarlo, despliega un menu de opciones
// esta disenado para formularios donde el usuario debe elegir una sola opcion
//

struct DropdownPickerComponent: View {
    let title: String
    let options: [String]
    // binding al viewmodel para guardar la opcion seleccionada
    @Binding var selection: String

    var body: some View {
        Menu {
            // crea un boton por cada opcion en el array
            ForEach(options, id: \.self) { option in
                Button(action: {
                    // al tocar, actualiza la seleccion en el viewmodel
                    selection = option
                }) {
                    // muestra el texto de la opcion
                    TagComponent(text: option)
                }
            }
        } label: {
            // esta es la parte visible del boton
            HStack {
                // muestra la seleccion actual, o el titulo si no hay seleccion
                Text(selection.isEmpty ? title : selection)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
            }
            .font(.bodyText)
            .foregroundColor(selection.isEmpty ? .textSecondary : .textPrimary)
            .padding()
            .background(Color.textFieldBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// preview hecha con ia 
struct DropdownPickerComponent_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var categorySelection = ""
        let categories = ["Otro", "Malware", "Phishing"]
        
        @State private var severitySelection = "Alta"
        let severities = ["Severa", "Alta", "Media", "Baja"]
        
        var body: some View {
            VStack(spacing: 20) {
                // prueba con una seleccion vacia
                DropdownPickerComponent(
                    title: "Categoria",
                    options: categories,
                    selection: $categorySelection
                )
                
                DropdownPickerComponent(
                    title: "Severidad",
                    options: severities,
                    selection: $severitySelection
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
