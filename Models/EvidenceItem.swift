//
//  EvidenceItem.swift
//  RepNet
//
//  Created by Angel Bosquez on 16/10/25.
//


import SwiftUI

// Representa una pieza de evidencia en la pantalla de edición.
// Puede ser una evidencia que ya existe en el servidor o una nueva que el usuario ha seleccionado.
enum EvidenceItem: Identifiable, Equatable {
    case existing(id: Int, url: String)
    case new(image: SelectedImage)
    
    var id: String {
        switch self {
        case .existing(let id, _):
            return "existing_\(id)"
        case .new(let image):
            return "new_\(image.id)"
        }
    }
}
