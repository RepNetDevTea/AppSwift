//
//  FileUploadComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//esta madre esta mal hecha y es 100% ai, pequeno detalle que no hay hover en movil
//componente para seleccionar varios archivos
/// una vez seleccionados, muestra una vista previa horizontal de los archivos,
/// permitiendo al usuario eliminar cualquiera de ellos.

import SwiftUI
import UniformTypeIdentifiers

// --- NUEVO MODELO ---
// Creamos un pequeño 'struct' para representar una imagen seleccionada.
// Hacerlo 'Identifiable' y 'Equatable' facilita su manejo en listas y colecciones.
struct SelectedImage: Identifiable, Equatable {
    let id = UUID()
    let uiImage: UIImage
}

struct FileUploadComponent: View {
    
    // --- CAMBIO CLAVE AQUÍ ---
    // El componente ahora usa un '@Binding' para comunicarse con la vista padre.
    // Cuando el usuario añade o quita imágenes aquí, la lista en el ViewModel se actualiza.
    @Binding var selectedImages: [SelectedImage]
    @State private var showFileImporter = false

    var body: some View {
        VStack(spacing: 20) {
            // El botón de carga ahora añade las imágenes a nuestro 'binding'.
            Button(action: { showFileImporter = true }) {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up.doc")
                        .font(.largeTitle)
                    Text("Toca para cargar archivos")
                        .font(.bodyText)
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
            .disabled(selectedImages.count >= 5) // Deshabilita el botón si se alcanza el límite de 5 fotos.
            
            // --- VISTA PREVIA DE ARCHIVOS SELECCIONADOS ---
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
                                    // Botón para eliminar la imagen de la selección.
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
            allowedContentTypes: [UTType.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    // Nos aseguramos de no exceder el límite de 5 imágenes.
                    guard selectedImages.count < 5 else { break }
                    
                    // Intentamos acceder y cargar los datos de la imagen.
                    if url.startAccessingSecurityScopedResource(),
                       let imageData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imageData) {
                        
                        // Usamos nuestra extensión para redimensionar la imagen antes de añadirla.
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
