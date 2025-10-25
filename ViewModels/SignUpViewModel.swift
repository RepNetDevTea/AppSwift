//
//  SignUpViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import Foundation
import Combine

// este es el viewmodel para la pantalla de "registro" (signup)
// maneja un formulario grande con validacion en tiempo real
// para cada campo usando el framework combine
//

@MainActor
class SignUpViewModel: ObservableObject {
    
    // MARK: - Propiedades y Servicios
    
    private let authAPIService = AuthAPIService()
    // 'cancellables' guarda todas las suscripciones de combine
    private var cancellables = Set<AnyCancellable>()
    
    // --- campos del formulario ---
    @Published var name = ""
    @Published var fathersLastName = ""
    @Published var mothersLastName = ""
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    // --- terminos y condiciones ---
    // controla si el usuario ha abierto la pantalla de terminos
    @Published var hasOpenedTerms = false
    // se conecta al checkbox para saber si el usuario acepto
    @Published var hasAgreedToTerms = false
    
    // --- estado de validacion ---
    // guardan el resultado de las validaciones en tiempo real
    @Published var passwordValidationStates: [PasswordRequirement: ValidationState] = [:]
    @Published var passwordsMatch: ValidationState = .neutral
    @Published var isEmailValid: ValidationState = .neutral
    @Published var emailErrorMessage: String? = nil
    @Published var passwordErrorMessage: String? = nil
    
    // --- estado general de la ui ---
    @Published var isFormValid = false
    @Published var isLoading = false
    @Published var registrationSuccessful = false
    

    // MARK: - Inicializador
    
    init() {
        // configura toda la logica de validacion reactiva
        setupValidation()
    }
    
    // MARK: - Logica de API
    
    // se llama cuando el usuario presiona el boton de registrarse
    func signUp() async {
        isLoading = true
        emailErrorMessage = nil
        
        // se crea el dto con todos los datos del formulario
        let userData = SignUpRequestDTO(
            name: name, fathersLastName: fathersLastName, mothersLastName: mothersLastName,
            username: username, email: email, password: password
        )
        
        do {
            // se llama al servicio de la api para intentar el registro
            try await authAPIService.signUp(userData: userData)
            // si tiene exito, se actualiza el estado
            registrationSuccessful = true
            
        } catch {
            // si falla, se maneja el error y se muestra un mensaje
            if let apiError = error as? APIError {
                switch apiError {
                case .serverError(let message):
                
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
    
    // la vista llama a esta funcion cuando el usuario cierra la pantalla de terminos
    func userDidOpenTerms() {
        hasOpenedTerms = true
    }
    
    // MARK: - Logica de Validacion
    
   
    private func setupValidation() {
        
        // se suscribe a los cambios en 'password' para validar requisitos
        $password.removeDuplicates().sink { [weak self] pass in
            self?.passwordValidationStates = PasswordValidator.validate(password: pass)
            self?.validatePasswordsMatch(pass1: pass, pass2: self?.confirmPassword ?? "")
        }.store(in: &cancellables)
            
        $confirmPassword.removeDuplicates().sink { [weak self] confirmPass in
            self?.validatePasswordsMatch(pass1: self?.password ?? "", pass2: confirmPass)
        }.store(in: &cancellables)
        
        // se suscribe a los cambios en 'email', con un 'debounce'
        // para no validar con cada letra que escribe
        $email.debounce(for: 0.5, scheduler: RunLoop.main).removeDuplicates().sink { [weak self] email in
            self?.validateEmail(email)
        }.store(in: &cancellables)
            
        // --- logica para 'isformvalid' ---
        
        // publisher 1: revisa si los campos de texto estan llenos
        let areNamesFilledPublisher = Publishers.CombineLatest4($name, $fathersLastName, $mothersLastName, $username)
            .map { !$0.isEmpty && !$1.isEmpty && !$2.isEmpty && !$3.isEmpty }

        // publisher 2: revisa si el email es valido y la contrasena es valida
        let areCredentialsValidPublisher = Publishers.CombineLatest3($passwordValidationStates, $passwordsMatch, $isEmailValid)
            .map { states, match, emailState in
                let allReqsMet = states.allSatisfy { $0.value == .success }
                return allReqsMet && match == .success && emailState == .success
            }
            
        // publisher final: combina los publishers anteriores y el de terminos
        Publishers.CombineLatest3(areNamesFilledPublisher, areCredentialsValidPublisher, $hasAgreedToTerms)
            .map { areNamesFilled, areCredentialsValid, hasAgreed in
                // el formulario es valido solo si todo es verdadero
                return areNamesFilled && areCredentialsValid && hasAgreed
            }
            .assign(to: \.isFormValid, on: self) // asigna el resultado a 'isformvalid'
            .store(in: &cancellables)
    }

    // funcion auxiliar para revisar si las contrasenas coinciden
    private func validatePasswordsMatch(pass1: String, pass2: String) {
        if pass2.isEmpty {
            passwordsMatch = .neutral
            passwordErrorMessage = nil
            return
        }
        passwordsMatch = pass1 == pass2 ? .success : .failure
        passwordErrorMessage = pass1 == pass2 ? nil : "las contrasenas no coinciden."
    }
    
    // funcion auxiliar para validar el formato del correo
    private func validateEmail(_ email: String) {
        if email.isEmpty {
            isEmailValid = .neutral
            emailErrorMessage = nil
            return
        }
        // usa la extension 'escorreovalido'
        if !email.esCorreoValido {
            isEmailValid = .failure
            emailErrorMessage = "el formato del correo no es valido."
        } else {
            isEmailValid = .success
            emailErrorMessage = nil
        }
    }
}
