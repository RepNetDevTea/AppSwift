//
//  CreateReportView.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//
// esta es la vista de swiftui para la pantalla de "crear reporte".
// obtiene todos sus datos del `createreportviewmodel`.

// -- componentes utilizados --
// - inputviewcomponent
// - dropdownpickercomponent
// - multiselectpickercomponent
// - fileuploadcomponent
// - primarybuttoncomponent

import SwiftUI

struct CreateReportView: View {

    @StateObject private var viewModel = CreateReportViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {

                    // Error Message Display
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.errorRed)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.errorRed.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // --- Basic Data Form Section ---
                    VStack(spacing: 15) {
                        InputViewComponent(text: $viewModel.reportTitle, placeholder: "Nombre del reporte")
                        InputViewComponent(text: $viewModel.reportUrl, placeholder: "URL del sitio o evidencia")
                            .keyboardType(.URL)

                        // Uses MultiSelectPickerComponent for categories (tags)
                        MultiSelectPickerComponent(
                            title: "Categorías",
                            options: viewModel.tagOptions, // Fetched Tag objects
                            selections: $viewModel.selectedTags // Binds to Set<Tag>
                        )

                        // Description Text Editor
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $viewModel.reportDescription)
                                .frame(height: 150)
                                .padding(10)
                                .background(Color.textFieldBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))

                            if viewModel.reportDescription.isEmpty {
                                Text("Descripción de la amenaza...")
                                    .foregroundColor(.textSecondary.opacity(0.5))
                                    .padding(15)
                                    .allowsHitTesting(false) // Let taps pass through to TextEditor
                            }
                        }
                    }

                    // Uses MultiSelectPickerComponent for impacts
                    MultiSelectPickerComponent(
                        title: "Impactos Potenciales",
                        options: viewModel.impactOptions, // Fetched Impact objects
                        selections: $viewModel.selectedImpacts // Binds to Set<Impact>
                    )

                    // ✅ Uses EvidenceManagerView for image picking and preview
                    EvidenceManagerView(evidenceItems: $viewModel.evidenceItems)

                    // Image upload instructions
                    Text("Máximo 5 fotos (1024x1024px)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.leading)

                } // End Main VStack
                .padding()
            } // End ScrollView
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Crear Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .disabled(viewModel.isLoading) // Disable form while loading
            .toolbar {
                // Back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) { Image(systemName: "arrow.left") }
                }
                // Submit button
                ToolbarItem(placement: .navigationBarTrailing) {
                    PrimaryButtonComponent(
                        title: "Enviar",
                        action: { Task { await viewModel.submitReport() } },
                        isEnabled: viewModel.isFormValid // Enables button based on ViewModel logic
                    )
                }
            }
            // Success alert
            .alert("Reporte Enviado", isPresented: $viewModel.creationSuccessful) {
                Button("OK", role: .cancel) { presentationMode.wrappedValue.dismiss() } // Dismiss view on OK
            } message: {
                Text("Tu reporte ha sido enviado para revisión.")
            }

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().scaleEffect(1.5).tint(.white)
            }
        } // End ZStack
        // No .onAppear needed here as ViewModel handles its own data loading in init
    } // End body
} // End Struct

// --- Preview ---
struct CreateReportView_Previews: PreviewProvider {
    static var previews: some View {
        // Need NavigationView for the title display
        NavigationView {
            CreateReportView()
                // If CreateReportView relies on EnvironmentObjects (like AuthManager),
                // provide mock versions here for the preview to work.
                // .environmentObject(AuthenticationManager())
        }
    }
}

// --- Assumed Components (Ensure these exist) ---
// struct InputViewComponent: View { ... }
// struct MultiSelectPickerComponent<Item: Hashable & Nameable>: View { ... }
// struct EvidenceManagerView: View { ... } // And its dependencies like EvidenceItem, SelectedImage
// struct PrimaryButtonComponent: View { ... }
// struct Tag: Decodable, Identifiable, Hashable, Nameable { ... }
// struct Impact: Decodable, Identifiable, Hashable, Nameable { ... }
