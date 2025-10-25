//
//  AccountViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import Foundation
import Combine
import SwiftUI

// mainactor asegura que todas las actualizaciones de @published

@MainActor
class AccountViewModel: ObservableObject {

    // MARK: - Propiedades
    
    // servicios de api y keychain (usando las structs concretas)
    private let userAPIService = UserAPIService()
    
    // guarda el perfil original para comparar si hubo cambios
    private var originalProfile: UserProfileResponseDTO?
    
    // para manejar las suscripciones de combine
    private var cancellables = Set<AnyCancellable>()

    // --- datos del perfil ---
    @Published var name = ""
    @Published var fathersLastName = ""
    @Published var mothersLastName = ""
    @Published var email = ""
    @Published var username = ""

    // --- estado de la ui ---
    @Published var isEditing = false // controla si el formulario esta en modo edicion
    @Published var showSuccessBanner = false // para mostrar el banner verde
    @Published var showLogoutAlert = false // para mostrar alerta de logout
    @Published var showDeleteAlert = false // para mostrar alerta de borrar cuenta
    @Published var isLoading = false // para mostrar el spinner de carga
    @Published var errorMessage: String? = nil // para mostrar mensajes de error

    // --- campos para cambiar contrasena ---
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var passwordValidationStates: [PasswordRequirement: ValidationState] = PasswordValidator.validate(password: "")
    @Published var passwordsMatch: ValidationState = .neutral

    // para eliminar cuenta (solo para la ui del modal)
    @Published var deleteConfirmationPassword = ""

    // el estado final del formulario (habilita/deshabilita el boton 'guardar')
    @Published var isFormValid: Bool = false

    init() {
        // configura los listeners de combine al crear el viewmodel
        setupValidation()
    }

    // MARK: - Logica de API
    
    // obtiene los datos del perfil del usuario desde la api
    func fetchUserProfile() async {
        isLoading = true
        errorMessage = nil
        print("🚀 intentando obtener el perfil del usuario...")
        do {
            let userProfile = try await userAPIService.fetchUserProfile()
            // llena los campos del formulario con los datos recibidos
            self.name = userProfile.name
            self.fathersLastName = userProfile.fathersLastName
            self.mothersLastName = userProfile.mothersLastName
            self.email = userProfile.email
            self.username = userProfile.username
            // guarda una copia original para comparar cambios despues
            self.originalProfile = userProfile
            print("✅ perfil de usuario obtenido exitosamente.")
        } catch {
            print("❌ error al obtener el perfil del usuario: \(error)")
            handle(error: error)
        }
        isLoading = false
        updateFormValidity() // actualiza el estado del boton 'guardar'
    }

    // envia los cambios del formulario al backend
    func saveChanges() async {
        // doble chequeo, aunque el boton deberia estar deshabilitado
        guard isFormValid else {
            print("formulario invalido, sin cambios, o falta contrasena actual.")
            if currentPassword.isEmpty && isEditing {
                 errorMessage = "debes introducir tu contrasena actual para guardar cambios."
            }
            return
        }

        isLoading = true
        errorMessage = nil

        // decide que contrasena enviar en el campo 'hashedpassword'
        // si el usuario no escribio una nueva, envia la actual
        // si escribio una nueva, envia la nueva
        let passwordToSendInHashField = self.newPassword.isEmpty ? self.currentPassword : self.newPassword

        // construye el dto con todos los campos del formulario
        // (el backend espera el objeto completo)
        let updateData = UpdateProfileRequestDTO(
            name: self.name,
            fathersLastName: self.fathersLastName,
            mothersLastName: self.mothersLastName,
            username: self.username,
            email: self.email,
            hashedPassword: passwordToSendInHashField
        )

        do {
            // intenta actualizar el perfil
            try await userAPIService.updateUserProfile(data: updateData)
            // si tiene exito, resetea el estado
            isEditing = false
            showSuccessBanner = true
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            await fetchUserProfile() // vuelve a cargar el perfil para actualizar 'originalProfile'

            // oculta el banner de exito despues de 3 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showSuccessBanner = false
            }
        } catch {
            // si falla, muestra el error
            handle(error: error)
        }
        isLoading = false
    }

    // llama a la api para eliminar la cuenta
    func deleteAccount(with authManager: AuthenticationManager) async {
        isLoading = true
        errorMessage = nil
        do {
            // (asumimos que 'deleteuser' no necesita la contrasena en el body)
            try await userAPIService.deleteUser()
            print("✅ cuenta eliminada exitosamente en el backend.")
            // si tiene exito, llama al authmanager para hacer logout local
            authManager.logout()
        } catch {
            handle(error: error)
            showDeleteAlert = false // oculta el modal si hay error
        }
        isLoading = false
    }

    // MARK: - Logica de Validacion
    
    // funcion helper para manejar errores de api y convertirlos en mensajes
    private func handle(error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .serverError(let message):
                self.errorMessage = message
            case .invalidResponse(let statusCode):
                self.errorMessage = "error del servidor: \(statusCode)"
            case .decodingError:
                self.errorMessage = "la respuesta del servidor no tiene el formato esperado."
            default:
                self.errorMessage = "ocurrio un error de red."
            }
        } else {
            self.errorMessage = "no se pudo conectar. revisa tu conexion."
        }
    }

    // valida si la nueva contrasena y la confirmacion coinciden
    private func validatePasswordsMatch() {
        if newPassword.isEmpty && confirmPassword.isEmpty {
            passwordsMatch = .neutral
        } else if newPassword.isEmpty || confirmPassword.isEmpty {
             passwordsMatch = .failure // error si solo uno esta lleno
        } else if newPassword == confirmPassword {
            passwordsMatch = .success
        } else {
            passwordsMatch = .failure
        }
    }

    // la funcion principal que decide si el boton 'guardar' debe estar habilitado
    private func updateFormValidity() {
        // 1. ¿estan llenos los campos basicos?
        let basicFieldsFilled = !name.isEmpty &&
                                !fathersLastName.isEmpty &&
                                !mothersLastName.isEmpty &&
                                !email.isEmpty &&
                                !username.isEmpty

        // 2. es valida la seccion de contrasena?
        let passwordSectionValid: Bool
        if newPassword.isEmpty && confirmPassword.isEmpty {
            passwordSectionValid = true // es valida si no se esta cambiando
        } else {
            // si se esta cambiando, los requisitos deben cumplirse y deben coincidir
            let requirementsMet = passwordValidationStates.allSatisfy { $0.value == .success }
            passwordSectionValid = requirementsMet && passwordsMatch == .success
        }

        // 3. ¿se hizo algun cambio?
        let changesMade = hasChanges
        
        // 4. ¿se proporciono la contrasena actual para autorizar?
        let currentPasswordProvided = !currentPassword.isEmpty

        // el formulario es valido solo si se cumplen las 4 condiciones
        isFormValid = basicFieldsFilled && passwordSectionValid && changesMade && currentPasswordProvided
    }

    // configura los "listeners" de combine
    // esto hace que la validacion se ejecute en tiempo real mientras el usuario escribe
    private func setupValidation() {
        // observa 'newpassword'
        $newPassword
            .removeDuplicates()
            .sink { [weak self] pass in
                self?.passwordValidationStates = PasswordValidator.validate(password: pass)
                self?.validatePasswordsMatch()
                self?.updateFormValidity()
            }
            .store(in: &cancellables)

        // observa 'confirmpassword'
        $confirmPassword
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.validatePasswordsMatch()
                self?.updateFormValidity()
            }
            .store(in: &cancellables)

        // observa 'currentpassword'
        $currentPassword
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateFormValidity()
            }
            .store(in: &cancellables)

        // observa todos los campos de texto del perfil
        Publishers.CombineLatest4($name, $fathersLastName, $mothersLastName, $username)
            .combineLatest($email) // combina los 5
            .map { _ in () } // no nos importa el valor, solo que hubo un cambio
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main) // espera un poco
            .sink { [weak self] _ in
                self?.updateFormValidity() // recalcula la validez
            }
            .store(in: &cancellables)
    }

    // propiedad computada que revisa si algo en el formulario ha cambiado
    private var hasChanges: Bool {
        guard let user = originalProfile else { return false } // si no hay original, no hay cambios
        
        let mothersLastNameChanged = mothersLastName != user.mothersLastName

        return name != user.name ||
               fathersLastName != user.fathersLastName ||
               mothersLastNameChanged ||
               username != user.username ||
               email != user.email ||
               !newPassword.isEmpty // si se empieza a escribir una nueva contrasena, ya es un cambio
    }
}
