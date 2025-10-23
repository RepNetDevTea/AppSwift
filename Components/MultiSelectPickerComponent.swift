//
//  MultiSelectPickerComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//

// un selector que permite al usuario elegir multiples opciones de una lista.
// presenta las opciones como una cuadricula detags  que se ajusta al espacio.

import SwiftUI

// ✨ CORREGIDO: Eliminadas las definiciones duplicadas de 'Nameable' y las extensiones.
// El componente ahora simplemente *usa* el protocolo 'Nameable' que está definido en otro archivo.

struct MultiSelectPickerComponent<Item: Hashable & Nameable>: View {
    let title: String
    let options: [Item] // Lista de objetos Tag o Impact
    @Binding var selections: Set<Item> // Set de objetos Tag o Impact seleccionados

    // Los diccionarios de traducción ya no son necesarios aquí.
    // La lógica de mostrar el nombre correcto está en el propio objeto (gracias a Nameable).

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.textSecondary)
                .padding(.leading)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        if selections.contains(option) {
                            selections.remove(option)
                        } else {
                            selections.insert(option)
                        }
                    }) {
                        // ✨ SIMPLIFICADO: Se muestra directamente la propiedad 'name'.
                        Text(option.name) // El objeto ya sabe dar su nombre en español
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selections.contains(option) ? Color.primaryBlue : Color.gray.opacity(0.15))
                            .foregroundColor(selections.contains(option) ? .white : .textPrimary)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    // La función auxiliar displayName ya no es necesaria.
}

// --- VISTA PREVIA (Asegúrate de que 'Impact' esté definido) ---
// (Si 'Impact' no está definido aquí, la Preview fallará.
// Lo ideal es tenerla en TagsAndImpactsDTO.swift)
struct MultiSelectPickerComponent_Previews: PreviewProvider {
    // Definición local de Impact SÓLO para la Preview (si no está global)
    // struct PreviewImpact: Identifiable, Hashable, Nameable {
    //     let id: Int
    //     var name: String { impactName }
    //     let impactName: String
    // }

    struct PreviewWrapper: View {
         // Asegúrate de que Impact esté definido aquí o globalmente
         let sampleImpacts = [
             Impact(id: 1, impactName: "Robo de credenciales", impactScore: nil, impactDescription: nil),
             Impact(id: 2, impactName: "Pérdida financiera", impactScore: nil, impactDescription: nil),
             Impact(id: 4, impactName: "Infección de malware", impactScore: nil, impactDescription: nil)
         ]
        @State private var selectedImpacts: Set<Impact> = [] // Usa Impact aquí

        var body: some View {
            MultiSelectPickerComponent(
                title: "Impactos Potenciales",
                options: sampleImpacts,
                selections: $selectedImpacts
            )
            .padding()
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
