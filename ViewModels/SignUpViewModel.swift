//
//  SignUpViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import Foundation
import Combine

// este es el viewmodel para la pantalla de "registro" (signup).
// es complejo porque maneja un formulario grande con validacion en tiempo real
// para cada campo usando el framework combine.
@MainActor
class SignUpViewModel: ObservableObject {
    
    private let authAPIService = AuthAPIService()
    
    // -- campos del formulario --
    @Published var name = ""
    @Published var fathersLastName = ""
    @Published var mothersLastName = ""
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    
     /// --- NUEVAS PROPIEDADES AÑADIDAS ---
     /// Controla si el usuario ha abierto la pantalla de términos al menos una vez.
    @Published var hasOpenedTerms = false
     /// Se conecta al checkbox para saber si el usuario ha aceptado los términos.
     @Published var hasAgreedToTerms = false
    
    // -- estado de validacion --
    // estas propiedades guardan el resultado de las validaciones en tiempo real.
    @Published var passwordValidationStates: [PasswordRequirement: ValidationState] = [:]
    @Published var passwordsMatch: ValidationState = .neutral
    @Published var isEmailValid: ValidationState = .neutral
    @Published var emailErrorMessage: String? = nil
    @Published var passwordErrorMessage: String? = nil
    
    // -- estado general de la ui --
    @Published var isFormValid = false
    @Published var isLoading = false
    @Published var registrationSuccessful = false
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupValidation()
    }
    
    // aqui se construye toda la logica de validacion reactiva del formulario.
    private func setupValidation() {
        // se suscribe a los cambios en el campo de contrasena para validar los requisitos.
        $password.removeDuplicates().sink { [weak self] pass in
            self?.passwordValidationStates = PasswordValidator.validate(password: pass)
            self?.validatePasswordsMatch(pass1: pass, pass2: self?.confirmPassword ?? "")
        }.store(in: &cancellables)
            
        // se suscribe a los cambios en el campo de confirmacion para validar que coincidan.
        $confirmPassword.removeDuplicates().sink { [weak self] confirmPass in
            self?.validatePasswordsMatch(pass1: self?.password ?? "", pass2: confirmPass)
        }.store(in: &cancellables)
        
        // se suscribe a los cambios en el email, con un `debounce` para no validar en cada letra,
        // sino cuando el usuario hace una pausa.
        $email.debounce(for: 0.5, scheduler: RunLoop.main).removeDuplicates().sink { [weak self] email in
            self?.validateEmail(email)
        }.store(in: &cancellables)
            
        // --- logica para `isformvalid` ---
        
        // publisher 1: revisa si todos los campos de nombre/usuario estan llenos.
        let areNamesFilledPublisher = Publishers.CombineLatest4($name, $fathersLastName, $mothersLastName, $username)
            .map { !$0.isEmpty && !$1.isEmpty && !$2.isEmpty && !$3.isEmpty }

        // publisher 2: revisa si el email es valido y si la contrasena cumple todos los requisitos.
        let areCredentialsValidPublisher = Publishers.CombineLatest3($passwordValidationStates, $passwordsMatch, $isEmailValid)
            .map { states, match, emailState in
                let allReqsMet = states.allSatisfy { $0.value == .success }
                return allReqsMet && match == .success && emailState == .success
            }
            
        // publisher final: combina los dos publishers anteriores. el formulario es valido
        // solo si ambas condiciones (nombres y credenciales) son verdaderas.
        /// --- LÓGICA DE VALIDACIÓN ACTUALIZADA ---
        /// Ahora, combinamos todo con el nuevo requisito 'hasAgreedToTerms'.
        Publishers.CombineLatest3(areNamesFilledPublisher, areCredentialsValidPublisher, $hasAgreedToTerms)
            .map { areNamesFilled, areCredentialsValid, hasAgreed in
                // El formulario solo es válido si todos los campos están llenos,
                // las credenciales son correctas Y el usuario ha aceptado los términos.
                return areNamesFilled && areCredentialsValid && hasAgreed
            }
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }

    // funcion auxiliar para revisar si las contrasenas coinciden.
    private func validatePasswordsMatch(pass1: String, pass2: String) {
        if pass2.isEmpty { passwordsMatch = .neutral; passwordErrorMessage = nil; return }
        passwordsMatch = pass1 == pass2 ? .success : .failure
        passwordErrorMessage = pass1 == pass2 ? nil : "las contrasenas no coinciden."
    }
    
    // funcion auxiliar para validar el formato del correo.
    private func validateEmail(_ email: String) {
        if email.isEmpty { isEmailValid = .neutral; emailErrorMessage = nil; return }
        if !email.esCorreoValido {
            isEmailValid = .failure
            emailErrorMessage = "el formato del correo no es valido."
        } else {
            isEmailValid = .success
            emailErrorMessage = nil
        }
    }
    
    /// --- NUEVA FUNCIÓN AÑADIDA ---
     /// La vista llamará a esta función cuando el usuario cierre la pantalla de términos.
     func userDidOpenTerms() {
         hasOpenedTerms = true
     }
    
    
    // se llama cuando el usuario presiona el boton de registrarse.
    func signUp() async {
        isLoading = true
        emailErrorMessage = nil
        
        // se crea el dto con todos los datos del formulario.
        let userData = SignUpRequestDTO(
            name: name, fathersLastName: fathersLastName, mothersLastName: mothersLastName,
            username: username, email: email, password: password
        )
        
        do {
            // se llama al servicio de la api para intentar el registro.
            try await authAPIService.signUp(userData: userData)
            // si tiene exito, se actualiza el estado para que la vista pueda reaccionar.
            registrationSuccessful = true
            
        } catch {
            // si falla, se maneja el error y se muestra un mensaje en la ui.
            if let apiError = error as? APIError {
                switch apiError {
                case .serverError(let message):
                    // usualmente el error del servidor es por un email/usuario que ya existe.
                    emailErrorMessage = message
                default:
                    emailErrorMessage = "ocurrio un error. intenta de nuevo."
                }
            } else {
                emailErrorMessage = "no se pudo conectar. revisa tu conexion."
            }
        }
        
        isLoading = false
    }
}
