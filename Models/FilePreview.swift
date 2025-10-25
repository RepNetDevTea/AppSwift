//
//  FilePreview.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//


//este archivo no se usa ya que no implementamos subir archivos aparte de imagenes 
// este es un modelo para la ui que representa un archivo seleccionado por el usuario.
// su trabajo es tomar la url de un archivo y prepararlo para ser mostrado en una vista previa,
// ya sea como una imagen o como un icono generico.

import SwiftUI
import UniformTypeIdentifiers

struct FilePreview: Identifiable {
    let id = UUID()
    let url: URL
    
    var fileName: String {
        url.lastPathComponent
    }
    
    var image: UIImage?
    
    var iconName: String
    var iconColor: Color

    init(url: URL) {
        self.url = url
        
        // Intenta cargar como imagen
        if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
            self.image = uiImage
            self.iconName = "" // No se necesita icono si es imagen
            self.iconColor = .clear
        } else {
            // Si no es imagen, determina el icono por el tipo de archivo
            self.image = nil
            switch UTType(filenameExtension: url.pathExtension) {
            case .pdf:
                self.iconName = "doc.text.fill"
                self.iconColor = .red
            case .spreadsheet, .commaSeparatedText: // .xlsx, .csv
                self.iconName = "tablecells.fill"
                self.iconColor = .green
            case .presentation: // .pptx
                self.iconName = "chart.bar.doc.horizontal.fill"
                self.iconColor = .orange
            default: // .docx y otros
                self.iconName = "doc.fill"
                self.iconColor = .blue
            }
        }
    }
}
