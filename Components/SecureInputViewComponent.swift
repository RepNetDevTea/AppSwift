//
//  SecureInputViewComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//
//campo de texto seguro, reutilizable para contrasenas



import SwiftUI

struct SecureInputViewComponent: View {
    //binding que almacena el string que el usuario introduce
    @Binding var text: String
    //texto que se muestra cuando el campo esta vacio
    let placeholder: String
    //booleano para errores de validacion
    var isError: Bool = false
    //estado para hacer texto visible u oculto
    @State private var isPasswordVisible = false

    var body: some View {
        HStack {
            // decide si mostrar un textfield normal o puntitos
            if isPasswordVisible {
                TextField(placeholder, text: $text)
            } else {
                SecureField(placeholder, text: $text)
            }
            
            //boton de icono de ojo para hacer texto visible
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundColor(.textSecondary)
            }
        }
        .font(.bodyText)
        //cambia el color de texto si 'eserror' es verdadero
        .foregroundColor(isError ? .errorRed : .textPrimary)
        .padding(15)
        //importante para contrasena (sugerido por ia)
        .autocapitalization(.none)
    }
}
