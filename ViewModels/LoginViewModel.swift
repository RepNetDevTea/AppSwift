//
//  LoginViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import Foundation

// este es el viewmodel para la pantalla de "login".
// se encarga de manejar el estado del formulario (email, contrasena), la validacion
// y el proceso de autenticacion contra la api.
@MainActor
class LoginViewModel: ObservableObject {
    
    private let authAPIService = AuthAPIService()
    
    // -- estado del formulario y la ui --
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    
    // una propiedad calculada para la validacion del formulario.
    // el boton de login en la vista se activara/desactivara basado en este valor.
    // usa la extension `.escorreovalido` que definimos en `string`.
    var isFormValid: Bool { !email.isEmpty && email.esCorreoValido && !password.isEmpty }
    
    // orquesta todo el proceso de login.
    // recibe el `authenticationmanager` para poder actualizar el estado global de la app si el login es exitoso.
    func login(with authManager: AuthenticationManager) async {
        isLoading = true
        errorMessage = nil
        
        // se crea el dto con las credenciales del formulario.
        let credentials = LoginRequestDTO(email: email, password: password)
        
        do {
            // 1. se llama al servicio de la api para intentar el login.
            let response = try await authAPIService.login(credentials: credentials)
            
            // 2. si tiene exito, se guardan los tokens de forma segura en el keychain.
            try KeychainService.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
            
            print("login exitoso para el usuario: \(response.user.name)")
            
            // 3. se le informa al `authenticationmanager` que el login fue exitoso,
            // pasandole los datos del usuario. esto actualizara el estado global de la app.
            authManager.login(user: response.user)
            
        } catch {
            // si algo falla durante el proceso, se establece un mensaje de error para mostrar en la ui.
            if let apiError = error as? APIError {
                switch apiError {
                case .serverError(let message): errorMessage = message
                case .invalidResponse(let code): errorMessage = "error del servidor (codigo: \(code))."
                case .decodingError: errorMessage = "la respuesta del servidor no es valida."
                default: errorMessage = "ocurrio un error. intentalo de nuevo."
                }
            } else {
                errorMessage = "no se pudo conectar. revisa tu conexion."
            }
        }
        
        isLoading = false
    }
}
