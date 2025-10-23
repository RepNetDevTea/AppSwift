

//
//  AccountView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import SwiftUI

struct AccountView: View {

    @StateObject private var viewModel = AccountViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @FocusState private var isPasswordEditing: Bool // To show/hide requirements

    var body: some View {
        // Use GeometryReader to avoid CoreGraphics warnings
        GeometryReader { _ in
            ZStack(alignment: .top) {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.errorRed)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.errorRed.opacity(0.1))
                                .cornerRadius(8)
                        }

                        // User Form
                        userForm

                        // Password Requirements (only if editing password)
                        if viewModel.isEditing && isPasswordEditing {
                            passwordRequirements
                        }

                        // Action Buttons
                        actionButtons
                    }
                    .padding()
                }
                .disabled(viewModel.isLoading)

                // Success Banner
                if viewModel.showSuccessBanner {
                    SuccessBannerComponent(message: "Cambios guardados exitosamente")
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Loading Indicator
                if viewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView().scaleEffect(1.5).tint(.white)
                }
            }
            .navigationTitle("Mi cuenta")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditing ? "Guardar" : "Editar") {
                        if viewModel.isEditing {
                            Task { await viewModel.saveChanges() }
                        } else {
                            viewModel.isEditing.toggle()
                        }
                    }
                    .fontWeight(.bold)
                    // Button disabled if editing AND form is invalid
                    .disabled(viewModel.isEditing && !viewModel.isFormValid)
                    .tint(.primaryBlue)
                }
            }
            .onAppear {
                Task { await viewModel.fetchUserProfile() }
            }
            .animation(.easeInOut, value: viewModel.isEditing)
            .animation(.easeInOut, value: viewModel.showSuccessBanner)
            .animation(.easeInOut, value: isPasswordEditing)
            .alert("Cerrar sesión", isPresented: $viewModel.showLogoutAlert) {
                Button("No", role: .cancel) {}
                Button("Sí", role: .destructive) { authManager.logout() }
            } message: { Text("¿Seguro que quieres salir?") }
            .fullScreenCover(isPresented: $viewModel.showDeleteAlert) {
                DeleteAccountConfirmationComponent( // Assuming this component exists
                    isPresented: $viewModel.showDeleteAlert,
                    password: $viewModel.deleteConfirmationPassword,
                    onDelete: {
                        Task { await viewModel.deleteAccount(with: authManager) }
                    }
                )
                .background(ClearBackgroundView()) // Assuming this exists
            }
        } // End GeometryReader
    }

    // MARK: - Formulario
    private var userForm: some View {
        VStack(spacing: 0) {
            InputViewComponent(text: $viewModel.name, placeholder: "Nombre").disabled(!viewModel.isEditing)
            Divider().padding(.horizontal)
            InputViewComponent(text: $viewModel.fathersLastName, placeholder: "Apellido Paterno").disabled(!viewModel.isEditing)
            Divider().padding(.horizontal)
            InputViewComponent(text: $viewModel.mothersLastName, placeholder: "Apellido Materno").disabled(!viewModel.isEditing)
            Divider().padding(.horizontal)
            InputViewComponent(text: $viewModel.username, placeholder: "Nombre de Usuario").disabled(!viewModel.isEditing)
            Divider().padding(.horizontal)
            InputViewComponent(text: $viewModel.email, placeholder: "Correo").disabled(!viewModel.isEditing)

            if viewModel.isEditing {
                VStack(spacing: 0) {
                    Divider().padding(.horizontal)
                    // ✨ Field for currentPassword included ✨
                    SecureInputViewComponent(text: $viewModel.currentPassword, placeholder: "Contraseña actual")
                        .focused($isPasswordEditing)

                    Divider().padding(.horizontal)
                    SecureInputViewComponent(text: $viewModel.newPassword, placeholder: "Nueva contraseña (opcional)")
                        .focused($isPasswordEditing)

                    Divider().padding(.horizontal)
                    SecureInputViewComponent(
                        text: $viewModel.confirmPassword,
                        placeholder: "Confirmar contraseña",
                        isError: viewModel.passwordsMatch == .failure
                    )
                    .focused($isPasswordEditing)
                }
                .transition(.opacity)
            }
        }
        .background(Color.textFieldBackground)
        .cornerRadius(16)
    }

    // MARK: - Requisitos de contraseña
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(PasswordRequirement.allCases, id: \.self) { requirement in
                PasswordRequirementComponent(
                    requirement: requirement.rawValue,
                    state: viewModel.passwordValidationStates[requirement] ?? .neutral
                )
            }
        }
        .padding(.horizontal)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Botones de acción
    private var actionButtons: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: AppInfoView()) { // Assuming AppInfoView exists
                ListItem(title: "App info", icon: "info.circle")
            }
            Divider().padding(.horizontal)
            ListItem(title: "Cerrar sesión", icon: "rectangle.portrait.and.arrow.right") {
                viewModel.showLogoutAlert = true
            }
             Divider().padding(.horizontal)
            ListItem(title: "Eliminar mi cuenta", icon: "trash", color: .errorRed) {
                viewModel.showDeleteAlert = true
            }
        }
        .background(Color.textFieldBackground)
        .cornerRadius(16)
    }
}

// MARK: - Componente ListItem (Remains the same)
struct ListItem: View {
    let title: String
    let icon: String
    var color: Color = .textPrimary
    var action: (() -> Void)? = nil
    var body: some View {
        if let action = action {
            Button(action: action) {
                HStack {
                    Text(title).foregroundColor(color)
                    Spacer()
                    Image(systemName: icon).foregroundColor(color)
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            HStack {
                Text(title).foregroundColor(color)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.textSecondary)
            }
            .padding()
        }
    }
}


// MARK: - Preview (Remains the same)
#Preview {
    NavigationView {
        AccountView()
            .environmentObject(AuthenticationManager()) // Ensure mock is provided
    }
}

// --- Assumed Components ---
// struct DeleteAccountConfirmationComponent: View { ... }
// struct ClearBackgroundView: UIViewRepresentable { ... }
// struct AppInfoView: View { ... }
// struct InputViewComponent: View { ... }
// struct SecureInputViewComponent: View { ... }
// struct PasswordRequirementComponent: View { ... }
// struct SuccessBannerComponent: View { ... }
// enum PasswordRequirement: String, CaseIterable { ... }
// enum ValidationState { case neutral, success, failure }
// struct PasswordValidator { static func validate(...) -> ... }
// class AuthenticationManager: ObservableObject { ... } // Ensure mock exists for preview
