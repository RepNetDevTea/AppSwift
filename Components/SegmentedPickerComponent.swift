//
//  SegmentedPickerComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
// un control de seleccion segmentado y personalizable con una animacion fluida.
// a diferencia de un picker estandar, este componente tiene un fondo que se desliza
// suavemente a la opcion seleccionada y soporta scroll horizontal para muchas opciones.

import SwiftUI

struct SegmentedPickerComponent: View {
    
    // el arreglo de strings que se mostraran como opciones.
    let options: [String]
    
    // un binding al string que almacena la opcion actualmente seleccionada.
    @Binding var selectedOption: String
    
    // el namespace se usa para coordinar la animacion `matchedgeometryeffect`.
    // conecta el fondo de la opcion anterior con el de la nueva para crear el deslizamiento.
    @Namespace private var animation

    var body: some View {
       
    // el scrollview permite que el componente maneje mas opciones de las que caben en la pantalla.
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedOption = option
                        }
                    }) {
                        Text(option)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .foregroundColor(selectedOption == option ? .primaryBlue : .textSecondary)
                            .background(
                                
                // este zstack con el `if` se encarga de dibujar el fondo blanco
                // solo para la opcion que esta actualmente seleccionada.
                                ZStack {
                                    if selectedOption == option {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .matchedGeometryEffect(id: "picker", in: animation)
                                            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                                    }
                                }
                            )
                    }
                }
            }
            .padding(5)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(16)
        }
    }
}

// vista preview ai
struct SegmentedPickerComponent_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var selection = "Aceptados"
        let options = ["Todos", "Pendientes de Revisión", "Aceptados", "Rechazados", "Archivados", "Borradores"]
        
        var body: some View {
            SegmentedPickerComponent(options: options, selectedOption: $selection)
                .padding()
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
