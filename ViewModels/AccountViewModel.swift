//
//  AccountViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AccountViewModel: ObservableObject {

    private let userAPIService = UserAPIService()
    private var originalProfile: UserProfileResponseDTO?
    private var cancellables = Set<AnyCancellable>()

    // --- Profile Data ---
    @Published var name = ""
    @Published var fathersLastName = ""
    @Published var mothersLastName = "" // Assuming non-optional
    @Published var email = ""
    @Published var username = ""

    // --- UI State ---
    @Published var isEditing = false
    @Published var showSuccessBanner = false
    @Published var showLogoutAlert = false
    @Published var showDeleteAlert = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // --- Change Password Fields ---
    @Published var currentPassword = "" // Mandatory for saving
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var passwordValidationStates: [PasswordRequirement: ValidationState] = PasswordValidator.validate(password: "")
    @Published var passwordsMatch: ValidationState = .neutral

    // For delete confirmation UI
    @Published var deleteConfirmationPassword = ""

    @Published var isFormValid: Bool = false

    init() {
        setupValidation()
    }

    // MARK: - Fetch user
    func fetchUserProfile() async {
        isLoading = true
        errorMessage = nil
        print("🚀 intentando obtener el perfil del usuario...")
        do {
            let userProfile = try await userAPIService.fetchUserProfile()
            self.name = userProfile.name
            self.fathersLastName = userProfile.fathersLastName
            self.mothersLastName = userProfile.mothersLastName
            self.email = userProfile.email
            self.username = userProfile.username
            self.originalProfile = userProfile
            print("✅ perfil de usuario obtenido exitosamente.")
        } catch {
            print("❌ error al obtener el perfil del usuario: \(error)")
            handle(error: error)
        }
        isLoading = false
        updateFormValidity() // Update validity after fetching
    }

    // MARK: - Save changes
    func saveChanges() async {
        // isFormValid already includes the non-empty currentPassword check
        guard isFormValid else {
            print("Formulario inválido, sin cambios, o falta contraseña actual.")
            if currentPassword.isEmpty && isEditing {
                 errorMessage = "Debes introducir tu contraseña actual para guardar cambios."
            }
            return
        }

        isLoading = true
        errorMessage = nil

        // Determine which password to send in the 'hashedPassword' field
        let passwordToSendInHashField = self.newPassword.isEmpty ? self.currentPassword : self.newPassword

        // Build the DTO with ALL fields
        let updateData = UpdateProfileRequestDTO(
            name: self.name,
            fathersLastName: self.fathersLastName,
            mothersLastName: self.mothersLastName,
            username: self.username,
            email: self.email,
            // Send ALWAYS a value here, using the logic above.
            hashedPassword: passwordToSendInHashField
        )

        do {
            try await userAPIService.updateUserProfile(data: updateData)
            isEditing = false
            showSuccessBanner = true
            // Clear ALL password fields on success
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            await fetchUserProfile() // Refresh original data

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showSuccessBanner = false
            }
        } catch {
            // handle(error:) will show messages (e.g., if currentPassword was wrong)
            handle(error: error)
        }
        isLoading = false
        // updateFormValidity() // Not strictly needed, @Published changes trigger it
    }


    // MARK: - Delete account
    func deleteAccount(with authManager: AuthenticationManager) async {
        isLoading = true
        errorMessage = nil
        do {
            // Adjust deleteUser call if backend requires password
            try await userAPIService.deleteUser()
            print("✅ Cuenta eliminada exitosamente en el backend.")
            authManager.logout()
        } catch {
            handle(error: error)
            showDeleteAlert = false
        }
        isLoading = false
    }

    // MARK: - Helpers
    private func handle(error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .serverError(let message):
                self.errorMessage = message
            case .invalidResponse(let statusCode):
                self.errorMessage = "Error del servidor: \(statusCode)"
            case .decodingError:
                self.errorMessage = "La respuesta del servidor no tiene el formato esperado."
            default:
                self.errorMessage = "Ocurrió un error de red."
            }
        } else {
            self.errorMessage = "No se pudo conectar. Revisa tu conexión."
        }
    }

    // Corrected password match validation
    private func validatePasswordsMatch() {
        if newPassword.isEmpty && confirmPassword.isEmpty {
            passwordsMatch = .neutral
        } else if newPassword.isEmpty || confirmPassword.isEmpty {
             passwordsMatch = .failure // Error if only one is empty
        } else if newPassword == confirmPassword {
            passwordsMatch = .success
        } else {
            passwordsMatch = .failure
        }
    }

    // Corrected overall form validity logic (requires currentPassword)
    private func updateFormValidity() {
        let basicFieldsFilled = !name.isEmpty &&
                                !fathersLastName.isEmpty &&
                                !mothersLastName.isEmpty && // Assuming non-optional
                                !email.isEmpty &&
                                !username.isEmpty

        let passwordSectionValid: Bool
        if newPassword.isEmpty && confirmPassword.isEmpty {
            passwordSectionValid = true // Valid if NOT changing password
        } else {
            let requirementsMet = passwordValidationStates.allSatisfy { $0.value == .success }
            passwordSectionValid = requirementsMet && passwordsMatch == .success
        }

        let changesMade = hasChanges
        // Current password must be provided
        let currentPasswordProvided = !currentPassword.isEmpty

        // Valid if basic fields filled AND password section valid AND changes made AND current password provided
        isFormValid = basicFieldsFilled && passwordSectionValid && changesMade && currentPasswordProvided
        // Optional: Add a print statement here to debug
        // print("Basic: \(basicFieldsFilled), PWSection: \(passwordSectionValid), Changes: \(changesMade), CurrentPW: \(currentPasswordProvided) -> Valid: \(isFormValid)")
    }

    // Corrected Combine setup (includes currentPassword)
    private func setupValidation() {
        // Validate newPassword requirements
        $newPassword
            .removeDuplicates()
            .sink { [weak self] pass in
                self?.passwordValidationStates = PasswordValidator.validate(password: pass)
                self?.validatePasswordsMatch()
                self?.updateFormValidity()
            }
            .store(in: &cancellables)

        // Validate password match
        $confirmPassword
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.validatePasswordsMatch()
                self?.updateFormValidity()
            }
            .store(in: &cancellables)

        // Observe currentPassword
        $currentPassword
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateFormValidity()
            }
            .store(in: &cancellables)

        // Validate form when basic profile fields change
        Publishers.MergeMany(
            $name.map { _ in () },
            $fathersLastName.map { _ in () },
            $mothersLastName.map { _ in () },
            $email.map { _ in () },
            $username.map { _ in () }
        )
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.updateFormValidity()
        }
        .store(in: &cancellables)
    }

    // Computed property to check if changes were made
    private var hasChanges: Bool {
        guard let user = originalProfile else { return false }
        let mothersLastNameChanged = mothersLastName != user.mothersLastName

        return name != user.name ||
               fathersLastName != user.fathersLastName ||
               mothersLastNameChanged ||
               username != user.username ||
               email != user.email ||
               !newPassword.isEmpty // Change detected if new password is being entered
    }
}
