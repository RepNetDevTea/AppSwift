//
//  EditReportView.swift
//  RepNet
//
//  Created by Angel Bosquez on 15/10/25.
//

import SwiftUI

struct EditReportView: View {
    
    @StateObject private var viewModel: EditReportViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(report: Report) {
        _viewModel = StateObject(wrappedValue: EditReportViewModel(report: report))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.errorRed)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.errorRed.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // --- Sección de Datos Básicos ---
                    VStack(spacing: 15) {
                        InputViewComponent(text: $viewModel.reportTitle, placeholder: "Nombre del reporte")
                        InputViewComponent(text: $viewModel.reportUrl, placeholder: "URL del sitio o evidencia")
                            .keyboardType(.URL)
                        
                        // ✨ CORREGIDO: Se usa el MultiSelectPicker genérico para las categorías (tags).
                        MultiSelectPickerComponent(
                            title: "Categorías",
                            options: viewModel.tagOptions,
                            selections: $viewModel.selectedTags
                        )
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $viewModel.reportDescription)
                                .frame(height: 150)
                                // ... (otros modificadores se mantienen)
                            
                            if viewModel.reportDescription.isEmpty {
                                Text("Descripción de la amenaza...")
                                    // ... (otros modificadores se mantienen)
                            }
                        }
                    }
                    
                    // ✨ CORREGIDO: Se usa el MultiSelectPicker genérico para los impactos.
                    MultiSelectPickerComponent(
                        title: "Impactos Potenciales",
                        options: viewModel.impactOptions,
                        selections: $viewModel.selectedImpacts
                    )
                    
                    // ✨ CORREGIDO: Se integra el gestor de evidencias.
                    EvidenceManagerView(evidenceItems: $viewModel.evidenceItems)
                    
                    Text("Máximo 5 fotos (1024x1024px)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.leading)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Editar Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .disabled(viewModel.isLoading)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) { Image(systemName: "arrow.left") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    PrimaryButtonComponent(
                        title: "Guardar Cambios",
                        action: { Task { await viewModel.saveChanges() } },
                        isEnabled: viewModel.isFormValid
                    )
                }
            }
            .alert("Reporte Actualizado", isPresented: $viewModel.updateSuccessful) {
                Button("OK", role: .cancel) { presentationMode.wrappedValue.dismiss() }
            } message: {
                Text("Tus cambios han sido guardados exitosamente.")
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().scaleEffect(1.5).tint(.white)
            }
        }
        .onAppear {
            // Cuando la vista aparece, le pedimos al ViewModel que cargue las evidencias existentes.
            Task {
                await viewModel.fetchInitialEvidences()
            }
        }
    }
}
