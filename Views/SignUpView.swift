//
//  SignUpView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

// esta es la vista de swiftui para la pantalla de "registro".
// es un formulario grande cuya logica y validacion en tiempo real
// son manejadas por el `signupviewmodel`.

// -- componentes utilizados --
// - inputviewcomponent
// - secureinputviewcomponent
// - passwordrequirementcomponent
// - primarybuttoncomponent

import SwiftUI

struct SignUpView: View {
    
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState private var isPasswordEditing: Bool
    /// --- NUEVA PROPIEDAD DE ESTADO AÑADIDA ---
    /// Controla si la hoja modal de los Términos y Condiciones está visible.
    @State private var showTermsSheet = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Text("Crea tu cuenta")
                        .font(.largeTitle)
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                    
                    // Formulario de campos de texto
                    VStack(spacing: 0) {
                        InputViewComponent(text: $viewModel.name, placeholder: "Nombre")
                        Divider().padding(.horizontal)
                        InputViewComponent(text: $viewModel.fathersLastName, placeholder: "Apellido Paterno")
                        Divider().padding(.horizontal)
                        InputViewComponent(text: $viewModel.mothersLastName, placeholder: "Apellido Materno")
                        Divider().padding(.horizontal)
                        InputViewComponent(text: $viewModel.username, placeholder: "Nombre de usuario")
                        
                        /// --- CAMBIO #1: Divisor más prominente ---
                        /// Se añade un divisor más grueso y oscuro para separar
                        /// visualmente los datos personales de las credenciales.
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                            .padding(.horizontal)
                        
                        InputViewComponent(text: $viewModel.email, placeholder: "Correo", isError: viewModel.emailErrorMessage != nil)
                        Divider().padding(.horizontal)
                        SecureInputViewComponent(text: $viewModel.password, placeholder: "Contraseña").focused($isPasswordEditing)
                        Divider().padding(.horizontal)
                        SecureInputViewComponent(text: $viewModel.confirmPassword, placeholder: "Confirma contraseña", isError: viewModel.passwordsMatch == .failure).focused($isPasswordEditing)
                    }
                    .background(Color.textFieldBackground)
                    .cornerRadius(16)
                    
                    if let emailError = viewModel.emailErrorMessage {
                        Text(emailError).font(.caption).foregroundColor(.errorRed)
                    }
                    
                    if isPasswordEditing {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(PasswordRequirement.allCases, id: \.self) { requirement in
                                PasswordRequirementComponent(
                                    requirement: requirement.rawValue,
                                    state: viewModel.passwordValidationStates[requirement] ?? .neutral
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if let passwordError = viewModel.passwordErrorMessage {
                        Text(passwordError).font(.caption).foregroundColor(.errorRed)
                    }
                    
                    /// --- CAMBIO #2: Sección de Términos y Condiciones alineada ---
                    HStack {
                        // El Checkbox
                        Button(action: {
                            viewModel.hasAgreedToTerms.toggle()
                        }) {
                            Image(systemName: viewModel.hasAgreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(viewModel.hasAgreedToTerms ? .primaryBlue : .textSecondary)
                        }
                        .disabled(!viewModel.hasOpenedTerms)
                        
                        // El Texto y el Enlace
                        HStack(spacing: 4) {
                            Text("He leído y acepto los")
                            Button("Términos y Condiciones") {
                                showTermsSheet = true
                            }
                            .foregroundColor(.textLink)
                            .fontWeight(.bold)
                        }
                        .font(.caption)
                        
                        Spacer() // <-- Este Spacer empuja todo el contenido a la izquierda.
                    }
                    
                    PrimaryButtonComponent(
                        title: "Crear cuenta",
                        action: { Task { await viewModel.signUp() } },
                        isEnabled: viewModel.isFormValid
                    )
                    
                    Spacer()

                    HStack(spacing: 4) {
                        Text("¿Ya tienes cuenta?").foregroundColor(.textSecondary)
                        Button("Inicia Sesión") { presentationMode.wrappedValue.dismiss() }
                            .foregroundColor(.textLink).fontWeight(.bold)
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(30)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .disabled(viewModel.isLoading)
            .alert("Registro Exitoso", isPresented: $viewModel.registrationSuccessful) {
                Button("OK", role: .cancel) { presentationMode.wrappedValue.dismiss() }
            } message: { Text("Tu cuenta ha sido creada. Ahora puedes iniciar sesión.") }
            
            .sheet(isPresented: $showTermsSheet, onDismiss: {
                viewModel.userDidOpenTerms()
            }) {
                TermsAndConditionsView()
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().scaleEffect(1.5).tint(.white)
            }
        }
    }
}



struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
