//
//  FilePreviewCardComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//
//tarjeta para vista previa de archivos, primero pensada para imagenes y documentos
//ahora solo es para documentos


import SwiftUI

struct FilePreviewCardComponent: View {
    //objeto con datos de archivo a mostrar
    let file: FilePreview
    //accion para eliminar archivo
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = file.image {
                // se comprueba si el archivo es imagen
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // vista para documentos (no se usara)
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
            
            //boton de borrado
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .font(.title2)
            }
            .offset(x: 8, y: -8)
        }
    }
}
