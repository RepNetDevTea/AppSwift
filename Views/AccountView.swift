

//
//  AccountView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import SwiftUI

// esta es la vista para la pantalla de "mi cuenta"
// se conecta a 'accountviewmodel' para toda su logica y datos
// y a 'authenticationmanager' para el logout
//

struct AccountView: View {

    // MARK: - Propiedades
    
    @StateObject private var viewModel = AccountViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @FocusState private var isPasswordEditing: Bool

    // MARK: - Cuerpo Principal
    
    var body: some View {
        // geometryreader ayuda a evitar algunos warnings de layout
        GeometryReader { _ in
            ZStack(alignment: .top) {
                // color de fondo
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // --- mensaje de error ---
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.errorRed)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.errorRed.opacity(0.1))
                                .cornerRadius(8)
                        }

                        // --- formulario de usuario ---
                        userForm
                        if viewModel.isEditing && isPasswordEditing {
                            passwordRequirements
                        }

                        
                        actionButtons
                    }
                    .padding()
                }
                .disabled(viewModel.isLoading) // deshabilita el scroll mientras carga

                // --- banner de exito ---
                if viewModel.showSuccessBanner {
                    SuccessBannerComponent(message: "cambios guardados exitosamente")
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

            
                if viewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView().scaleEffect(1.5).tint(.white)
                }
            }
            .navigationTitle("mi cuenta")
            .toolbar {
                // boton de editar/guardar en la barra de navegacion
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditing ? "guardar" : "editar") {
                        if viewModel.isEditing {
                            // si esta editando, guarda
                            Task { await viewModel.saveChanges() }
                        } else {
                            // si no, activa el modo de edicion
                            viewModel.isEditing.toggle()
                        }
                    }
                    .fontWeight(.bold)
                    // se deshabilita si (esta editando y el formulario no es valido)
                    .disabled(viewModel.isEditing && !viewModel.isFormValid)
                    .tint(.primaryBlue)
                }
            }
            .onAppear {
                // carga el perfil del usuario cada vez que la vista aparece
                Task { await viewModel.fetchUserProfile() }
            }
            // animaciones para los cambios de estado
            .animation(.easeInOut, value: viewModel.isEditing)
            .animation(.easeInOut, value: viewModel.showSuccessBanner)
            .animation(.easeInOut, value: isPasswordEditing)
            // alerta para cerrar sesion
            .alert("cerrar sesion", isPresented: $viewModel.showLogoutAlert) {
                Button("no", role: .cancel) {}
                Button("si", role: .destructive) { authManager.logout() }
            } message: { Text("¿seguro que quieres salir?") }
            // modal personalizado para eliminar cuenta
            .fullScreenCover(isPresented: $viewModel.showDeleteAlert) {
                DeleteAccountConfirmationComponent(
                    isPresented: $viewModel.showDeleteAlert,
                    password: $viewModel.deleteConfirmationPassword,
                    onDelete: {
                        Task { await viewModel.deleteAccount(with: authManager) }
                    }
                )
                .background(ClearBackgroundView())
            }
        }
    }

    // MARK: - Sub-vistas
    
    // formulario de usuario
    private var userForm: some View {
        VStack(spacing: 0) {
            InputViewComponent(text: $viewModel.name, placeholder: "nombre").disabled(!viewModel.isEditing)
            Divider().padding(.horizontal)
            InputViewComponent(text: $viewModel.fathersLastName, placeholder: "apellido paterno").disabled(!viewModel.isEditing)
            Divider().padding(.horizontal)
            InputViewComponent(text: $viewModel.mothersLastName, placeholder: "apellido materno").disabled(!viewModel.isEditing)
            Divider().padding(.horizontal)
            InputViewComponent(text: $viewModel.username, placeholder: "nombre de usuario").disabled(!viewModel.isEditing)
            Divider().padding(.horizontal)
            InputViewComponent(text: $viewModel.email, placeholder: "correo", keyboardType: .emailAddress, autocapitalization: .none).disabled(!viewModel.isEditing)

            // seccion de contrasenas, solo visible en modo edicion
            if viewModel.isEditing {
                VStack(spacing: 0) {
                    Divider().padding(.horizontal)
                    // campo para la contrasena actual (obligatorio para guardar)
                    SecureInputViewComponent(text: $viewModel.currentPassword, placeholder: "contrasena actual")
                        .focused($isPasswordEditing)

                    Divider().padding(.horizontal)
                    SecureInputViewComponent(text: $viewModel.newPassword, placeholder: "nueva contrasena (opcional)")
                        .focused($isPasswordEditing)

                    Divider().padding(.horizontal)
                    SecureInputViewComponent(
                        text: $viewModel.confirmPassword,
                        placeholder: "confirmar contrasena",
                        // se pone en rojo si el viewmodel dice que no coinciden
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

    // requisitos
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

    // botones de info, logout y eliminar
    private var actionButtons: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: AppInfoView()) {
                ListItem(title: "app info", icon: "info.circle")
            }
            Divider().padding(.horizontal)
            ListItem(title: "cerrar sesion", icon: "rectangle.portrait.and.arrow.right") {
                viewModel.showLogoutAlert = true
            }
             Divider().padding(.horizontal)
            ListItem(title: "eliminar mi cuenta", icon: "trash", color: .errorRed) {
                viewModel.showDeleteAlert = true
            }
        }
        .background(Color.textFieldBackground)
        .cornerRadius(16)
    }
}

// MARK: - Componente ListItem
struct ListItem: View {
    let title: String
    let icon: String
    var color: Color = .textPrimary
    var action: (() -> Void)? = nil // accion opcional

    var body: some View {
        // si tiene una accion, es un boton
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


// MARK: - Preview
// preview hecha con ia
#Preview {
    NavigationView {
        AccountView()
            .environmentObject(AuthenticationManager())
    }
}
