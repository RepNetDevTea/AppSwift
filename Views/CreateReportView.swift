//
//  CreateReportView.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//
// esta es la vista de swiftui para la pantalla de "crear reporte".
// obtiene todos sus datos del `createreportviewmodel`.

import SwiftUI

struct CreateReportView: View {

    @StateObject private var viewModel = CreateReportViewModel()
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Cuerpo Principal
    
    var body: some View {
        ZStack {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {

                    // --- mensaje de error ---
                   
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.errorRed)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.errorRed.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // --- seccion de datos  ---
                    VStack(spacing: 15) {
                        InputViewComponent(text: $viewModel.reportTitle, placeholder: "nombre del reporte")
                        InputViewComponent(text: $viewModel.reportUrl, placeholder: "url del sitio o evidencia", keyboardType: .URL, autocapitalization: .none)
                        
                        // selector multiple para tags
                        MultiSelectPickerComponent(
                            title: "categorias",
                            options: viewModel.tagOptions,
                            selections: $viewModel.selectedTags
                        )

                        // editor de texto para la descripcion
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $viewModel.reportDescription)
                                .frame(height: 150)
                                .padding(10)
                                .background(Color.textFieldBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))

                           
                            if viewModel.reportDescription.isEmpty {
                                Text("descripcion de la amenaza...")
                                    .foregroundColor(.textSecondary.opacity(0.5))
                                    .padding(15)
                                    .allowsHitTesting(false)
                            }
                        }
                    }

                    // selector  para impactos
                    MultiSelectPickerComponent(
                        title: "impactos potenciales",
                        options: viewModel.impactOptions,
                        selections: $viewModel.selectedImpacts
                    )

                    // componente para seleccionar y ver imagenes
                    EvidenceManagerView(evidenceItems: $viewModel.evidenceItems)

                    Text("maximo 5 fotos (1024x1024px)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.leading)

                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("crear reporte")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .disabled(viewModel.isLoading) // deshabilita el formulario mientras carga
            .toolbar {
               
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) { Image(systemName: "arrow.left") }
                }
                // boton de enviar
                ToolbarItem(placement: .navigationBarTrailing) {
                    PrimaryButtonComponent(
                        title: "enviar",
                        action: { Task { await viewModel.submitReport() } },
                        
                        isEnabled: viewModel.isFormValid
                    )
                }
            }
            // alerta de exito
            .alert("reporte enviado", isPresented: $viewModel.creationSuccessful) {
                Button("ok", role: .cancel) { presentationMode.wrappedValue.dismiss() }
            } message: {
                Text("tu reporte ha sido enviado para revision.")
            }

            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().scaleEffect(1.5).tint(.white)
            }
        }
        
    }
}

// MARK: - Preview
// preview hecha con ia
struct CreateReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateReportView()
            // .environmentObject(AuthenticationManager()) // anadir si se necesita
        }
    }
}
