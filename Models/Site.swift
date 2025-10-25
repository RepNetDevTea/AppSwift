//
//  Site.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//
// modelo que representa un sitio web en la ui de la aplicacion.
// agrupa toda la informacion relevante de un sitio, incluyendo sus reportes asociados.

import Foundation

struct Site: Identifiable {
    let id: Int
    let domain: String
    var reputationScore: Int // cambiado a var sugerido por ia
    var reports: [Report]
}
