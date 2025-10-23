//
//  DropdownPickerComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
//componente para seleccion desplegable
//cuando se toca muestra un menu de opciones
//
//pensando para formularios donde se selecciona una opcion predeterminada


import SwiftUI

struct DropdownPickerComponent: View {
    //texto predeterminado
    let title: String
    //array de strings para opcioens del menu
    let options: [String]
    //binding para almacenar la seleccion del usuario
    @Binding var selection: String

    var body: some View {
        Menu {
            //botones para cada uno de los opciones
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    //tag component para cada opcion del menu
                    TagComponent(text: option)
                }
            }
        } label: {
            //parte que se ve antes de que se abra el menu
            HStack {
                //muestra seleccion actual (o nada)
                Text(selection.isEmpty ? title : selection)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
            }
            .font(.bodyText)
            //color cambia cuando se selecciona
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

//vista previa hecha con ia
struct DropdownPickerComponent_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var categorySelection = ""
        let categories = ["Otro", "Malware", "Phishing"]
        
        @State private var severitySelection = "Alta"
        let severities = ["Severa", "Alta", "Media", "Baja"]
        
        var body: some View {
            VStack(spacing: 20) {
                DropdownPickerComponent(
                    title: "Categoría",
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
