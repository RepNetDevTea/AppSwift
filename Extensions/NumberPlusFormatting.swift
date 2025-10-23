//
//  NumberPlusFormatting.swift
//  RepNet
//
//  Created by Angel Bosquez on 10/10/25.
//

import Foundation

extension Int {
    // Formatea un número entero a una cadena abreviada con 'k' para miles.
// Ejemplos: 999 -> "999", 1345 -> "1.3k", 12000 -> "12k"
    var formattedK: String {
        if self < 1000 {
            return String(self)
        }
        
        let num = Double(self) / 1000.0
        // Si el número tiene decimales (ej. 1.3), los muestra. Si no (ej. 12.0), los oculta.
        return String(format: num.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fk" : "%.1fk", num)
    }
}
