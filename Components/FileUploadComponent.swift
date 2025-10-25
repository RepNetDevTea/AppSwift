
//
//  FileUploadComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.

import SwiftUI
import UniformTypeIdentifiers

// este componente fue hecho con ia
//es el selector de archivos original
// usa .fileImporter, que abre el navegador de "archivos" del sistema
//
// nota: este componente ya no se usa en CreateReportView
// fue reemplazado por EvidenceManagerView, que usa PhotosPicker
//
// tambien define 'SelectedImage' aqui, que es una dependencia de 'EvidenceItem'

// MARK: - Modelo de Imagen Seleccionada

// struct simple para guardar una imagen seleccionada de la galeria
// 'evidenceitem' depende de esta struct
struct SelectedImage: Identifiable, Equatable {
    let id = UUID()
    let uiImage: UIImage
}

// MARK: - Componente de Subida de Archivos

struct FileUploadComponent: View {
    
    // binding al viewmodel
    @Binding var selectedImages: [SelectedImage]
    @State private var showFileImporter = false

    var body: some View {
        VStack(spacing: 20) {
            // el boton principal para abrir el selector de archivos
            Button(action: { showFileImporter = true }) {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up.doc")
                        .font(.largeTitle)
                    Text("Toca para cargar archivos")
                        .font(.bodyText) // asumo que .bodyText existe
                        .fontWeight(.semibold)
                }
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                        .foregroundColor(.gray.opacity(0.5))
                )
            }
            .disabled(selectedImages.count >= 5) // se deshabilita al llegar a 5
            
            // --- vista previa de imagenes seleccionadas ---
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(selectedImages) { imageItem in
                            Image(uiImage: imageItem.uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(alignment: .topTrailing) {
                                    // boton 'x' para eliminar
                                    Button(action: {
                                        selectedImages.removeAll { $0.id == imageItem.id }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                            .font(.title2)
                                    }
                                    .offset(x: 8, y: -8)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 110)
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [UTType.image], // solo permite imagenes
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    // aseguramos el limite de 5
                    guard selectedImages.count < 5 else { break }
                    
                    // cargamos los datos de la imagen desde la url
                    if url.startAccessingSecurityScopedResource(),
                       let imageData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imageData) {
                        
                        // usamos la extension para redimensionar la imagen
                        if let resizedImage = uiImage.resized(to: 1024) {
                            selectedImages.append(SelectedImage(uiImage: resizedImage))
                        }
                    }
                    url.stopAccessingSecurityScopedResource()
                }
            case .failure(let error):
                print("Error al seleccionar archivos: \(error.localizedDescription)")
            }
        }
        .animation(.easeInOut, value: selectedImages.count)
    }
}
