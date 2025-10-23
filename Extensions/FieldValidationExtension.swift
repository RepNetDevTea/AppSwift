//
//  FieldValidationExtension.swift
//  RepNet
//
//  Created by Angel Bosquez on 01/10/25.
//

import Foundation

// "Extendemos" el tipo String, dándole nuevas propiedades y "habilidades".
extension String {
    
    // Devuelve 'true' si el String tiene un formato de correo electrónico válido.
    //seguimos regex del profe
    var esCorreoValido: Bool {
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailPredicate.evaluate(with: self)
    }
    
    
    // Devuelve 'true' si el String cumple con la longitud mínima requerida.
    var tieneLongitudMinima: Bool {
        return self.count >= 8
    }
    
    // Devuelve 'true' si el String no excede la longitud máxima.
    var tieneLongitudMaxima: Bool {
        return self.count <= 20
    }
    
    // --- PROPIEDADES EXISTENTES (con mejora en CaracterEspecial) ---
    
    var tieneMayuscula: Bool {
        return self.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    var tieneNumero: Bool {
        return self.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    // devuelve `true` si el string contiene al menos uno de los caracteres especiales definidos.
    var tieneCaracterEspecial: Bool {
        return self.range(of: "[!@#$%^&*?]", options: .regularExpression) != nil
    }
    
}
