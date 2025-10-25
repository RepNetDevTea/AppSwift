//
//  FilePreviewCardComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 25/10/25.
//


import SwiftUI

//este componente ya no se usa
// este componente es una tarjeta de vista previa para un archivo
// disenado originalmente para mostrar imagenes o un icono de documento

struct FilePreviewCardComponent: View {
    let file: FilePreview
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = file.image {
                // si es imagen, la muestra
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // si no es imagen, muestra un icono y nombre de archivo
                // (segun el comentario, esta parte no se usaria)
                VStack(spacing: 8) {
                    Image(systemName: file.iconName)
                        .font(.largeTitle)
                        .foregroundColor(file.iconColor)
                    Text(file.fileName)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 100, height: 100)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            // boton de borrado
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .font(.title2)
            }
            .offset(x: 8, y: -8) // lo saca un poco de la esquina
        }
    }
}
