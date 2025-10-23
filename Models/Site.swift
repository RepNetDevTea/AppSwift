//
//  Site.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//
// este es el modelo que representa un sitio web en la ui de la aplicacion.
// agrupa toda la informacion relevante de un sitio, incluyendo sus reportes asociados.
// `identifiable` permite que swiftui lo use en listas de forma eficiente.

import Foundation

struct Site: Identifiable {
    let id: Int
    let domain: String
    var reputationScore: Int // Consider if this should also be 'var'
    
    // ✅ Corrected: Changed 'let' to 'var'
    var reports: [Report]
}
