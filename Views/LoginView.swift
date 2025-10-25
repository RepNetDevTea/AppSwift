//
//  LoginView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//


import SwiftUI

// esta es la vista de swiftui para la pantalla de "login".
// son manejados por el `loginviewmodel`.


struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                
                Text("inicia sesion")
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                
                // seccion para los campos de email y contrasena.
                VStack(spacing: 0) {
                    InputViewComponent(text: $viewModel.email, placeholder: "correo", isError: viewModel.errorMessage != nil)
                    Divider().padding(.horizontal)
                    SecureInputViewComponent(text: $viewModel.password, placeholder: "contrasena", isError: viewModel.errorMessage != nil)
                }
                .background(Color.textFieldBackground)
                .cornerRadius(16)
                
                // seccion para el mensaje de error. aparece solo si hay un error en el viewmodel.
                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(errorMessage)
                        Spacer()
                    }
                    .foregroundColor(.errorRed).font(.caption).padding(.leading)
                }
                
                // el boton principal de login.
                PrimaryButtonComponent(
                    title: "iniciar sesion",
                    action: {
                        Task {
                            await viewModel.login(with: authManager)
                        }
                    },

                    isEnabled: viewModel.isFormValid
                )
                
                Spacer()

                // seccion inferior con enlaces para registrarse
                VStack(spacing: 15) {
                    HStack(spacing: 4) {
                        Text("¿no tienes cuenta?").foregroundColor(.textSecondary)
                        NavigationLink("registrate", destination: SignUpView())
                            .foregroundColor(.textLink).fontWeight(.bold)
                    }
                }
                .font(.body)
            }
            .padding(30)
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().scaleEffect(1.5).tint(.white)
            }
        }
        .navigationBarHidden(true)
    }
}

// la vista previa necesita el `authenticationmanager` en su entorno para funcionar.
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
                .environmentObject(AuthenticationManager())
        }
    }
}
