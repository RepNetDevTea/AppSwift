//
//  InputViewComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//
//

import SwiftUI

//campo de texto estandar y reutilizable para formularios
// envuelve un textfield, anadiendo estilos consistentes
// estado de error visual
//
//

struct InputViewComponent: View {
    // binding al viewmodel para guardar el texto
    @Binding var text: String
    // el texto gris que se muestra cuando esta vacio
    let placeholder: String
    // si es true, muestra el texto en rojo
    var isError: Bool = false
    
    // permite personalizar el tipo de teclado
    var keyboardType: UIKeyboardType = .default
    // permite personalizar las mayusculas
    // por defecto es .sentences
    var autocapitalization: UITextAutocapitalizationType = .sentences

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.bodyText)
            .foregroundColor(isError ? .errorRed : .textPrimary)
            .padding(15)
            .keyboardType(keyboardType)
            .autocapitalization(autocapitalization)
            .disableAutocorrection(true)
    }
}

// --- vista previa ---
// preview hecha con ia
struct InputViewComponent_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var textNormal = ""
        @State var textError = "texto incorrecto"
        @State var emailText = ""
        
        var body: some View {
            VStack(spacing: 20) {
                // prueba 1: campo normal
                InputViewComponent(
                    text: $textNormal,
                    placeholder: "Campo de texto normal (sin autocorreccion)"
                )
                
                // prueba 2: campo de email
                InputViewComponent(
                    text: $emailText,
                    placeholder: "Campo de email",
                    keyboardType: .emailAddress,
                    autocapitalization: .none
                )
                
                // prueba 3: campo con error
                InputViewComponent(
                    text: $textError,
                    placeholder: "Campo con error",
                    isError: true
                )
            }
            .padding()
            .background(Color.textFieldBackground)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
