//
//  InputViewComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//
//
//un campo de texto estandar y reutilizable para formularios.
//
//este componente envuelve un `textfield` de swiftui, anadiendo estilos
//consistentes para la app y manejo visual de errores.
//pensando para correos electronicos

import SwiftUI

struct InputViewComponent: View {
    @Binding var text: String
    let placeholder: String
    var isError: Bool = false

    var body: some View {
        TextField(placeholder, text: $text)
        // cambia el color del texto para dar feedback visual de error
            .font(.bodyText)
            .foregroundColor(isError ? .errorRed : .textPrimary)
            .padding(15)
            .autocapitalization(.none)
        //pensando para emails
            .keyboardType(.emailAddress)
    }
}

#Preview {
    //preview en ia 
    struct PreviewWrapper: View {
        @State var textNormal = ""
        @State var textError = "texto incorrecto"
        
        var body: some View {
            VStack(spacing: 20) {
                InputViewComponent(
                    text: $textNormal,
                    placeholder: "Campo de texto normal"
                )
                
                InputViewComponent(
                    text: $textError,
                    placeholder: "Campo con error",
                    isError: true
                )
            }
            .padding()
            //simula fondo de cards
            .background(Color.white)
        }
    }
    
    return PreviewWrapper()
}
