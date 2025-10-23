//
//  EvidenceManagerView.swift
//  RepNet
//
//  Created by Angel Bosquez on 19/10/25.
//


import SwiftUI
import PhotosUI // Para el selector de fotos

struct EvidenceManagerView: View {
    @Binding var evidenceItems: [EvidenceItem] // Recibirá la lista de evidencias del ViewModel
    
    @State private var showingImagePicker = false
    @State private var pickerItem: PhotosPickerItem? // Para seleccionar una sola imagen
    
    // Configuración de la cuadrícula
    private let gridColumns: [GridItem] = [
        .init(.flexible()),
        .init(.flexible()),
        .init(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Evidencias").font(.headline)
            
            LazyVGrid(columns: gridColumns, spacing: 10) {
                // 1. Mostrar evidencias existentes y nuevas
                ForEach(evidenceItems) { item in
                    EvidenceThumbnailView(item: item) { itemToDelete in
                        // Acción para eliminar una evidencia
                        evidenceItems.removeAll { $0.id == itemToDelete.id }
                    }
                }
                
                // 2. Botón para añadir nuevas evidencias (usando PhotosPicker)
                if evidenceItems.count < 5 { // Límite de 5 fotos
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 100)
                            .overlay(
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.primaryBlue)
                            )
                    }
                }
            }
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, newItem in // ✨ CORREGIDO
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    if let resizedImage = uiImage.resized(to: 1024) {
                        evidenceItems.append(.new(image: SelectedImage(uiImage: resizedImage)))
                    }
                }
                pickerItem = nil
            }
        }
    }
}

// --- Sub-Componente para mostrar cada miniatura de evidencia ---
struct EvidenceThumbnailView: View {
    let item: EvidenceItem
    let onDelete: (EvidenceItem) -> Void // Callback para cuando se elimina una imagen
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Mostrar la imagen (existente o nueva)
            if case .existing(_, let urlString) = item, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                .frame(height: 100)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .clipped()
            } else if case .new(let selectedImage) = item {
                Image(uiImage: selectedImage.uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .cornerRadius(12)
                    .clipped()
            } else {
                // Placeholder en caso de error o imagen no cargada
                Image(systemName: "photo").resizable().aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.textSecondary)
            }
            
            // Botón para eliminar
            Button(action: {
                onDelete(item)
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

// --- Vista Previa ---
struct EvidenceManagerView_Previews: PreviewProvider {
    // Definimos un State para simular la lista de evidencias en el ViewModel
    @State static var previewEvidences: [EvidenceItem] = [
        .existing(id: 1, url: "https://via.placeholder.com/150"),
        .existing(id: 2, url: "https://via.placeholder.com/150"),
        .new(image: SelectedImage(uiImage: UIImage(systemName: "photo")!))
    ]
    
    static var previews: some View {
        EvidenceManagerView(evidenceItems: $previewEvidences)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
