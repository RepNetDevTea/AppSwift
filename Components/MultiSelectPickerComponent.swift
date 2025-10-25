//
//  MultiSelectPickerComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//


import SwiftUI

// elector de multiples opciones
// muestra una cuadricula de botones (tags) que se pueden seleccionar
// esta disenado para ser generico y funcionar con cualquier tipo de dato
// siempre y cuando ese dato cumpla con los protocolos 'hashable' y 'nameable'
//


struct MultiSelectPickerComponent<Item: Hashable & Nameable>: View {
    let title: String
    let options: [Item] // lista de objetos tag o impact
    @Binding var selections: Set<Item> // set de objetos tag o impact seleccionados


    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.textSecondary)
                .padding(.leading)

            // una cuadricula que se adapta al tamano de la pantalla
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        // logica para anadir o quitar del 'set'
                        if selections.contains(option) {
                            selections.remove(option)
                        } else {
                            selections.insert(option)
                        }
                    }) {
                        
                        Text(option.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            // el fondo cambia si el item esta seleccionado
                            .background(selections.contains(option) ? Color.primaryBlue : Color.gray.opacity(0.15))
                            .foregroundColor(selections.contains(option) ? .white : .textPrimary)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
}


// preview hecha con ia
struct MultiSelectPickerComponent_Previews: PreviewProvider {
    struct PreviewWrapper: View {
         // asegurate de que 'impact' este definido (normalmente en tagsandimpactsdto.swift)
         let sampleImpacts = [
             Impact(id: 1, impactName: "Robo de credenciales", impactScore: nil, impactDescription: nil),
             Impact(id: 2, impactName: "Perdida financiera", impactScore: nil, impactDescription: nil),
             Impact(id: 4, impactName: "Infeccion de malware", impactScore: nil, impactDescription: nil)
         ]
        @State private var selectedImpacts: Set<Impact> = [] 

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
