//
//  FieldValidationExtension.swift
//  RepNet
//
//  Created by Angel Bosquez on 01/10/25.
//

import Foundation



extension String {
    
    // MARK: - Validacion de Email
    //redundante tambien lo hace la api
    var esCorreoValido: Bool {
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailPredicate.evaluate(with: self)
    }
    
    // MARK: - Validaciones de contrasena
    
    var tieneLongitudMinima: Bool {
        return self.count >= 8
    }
    
    var tieneLongitudMaxima: Bool {
        return self.count <= 20
    }
    
    var tieneMayuscula: Bool {
        return self.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    var tieneNumero: Bool {
        return self.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    var tieneCaracterEspecial: Bool {
        return self.range(of: "[!@#$%^&*?]", options: .regularExpression) != nil
    }
}
