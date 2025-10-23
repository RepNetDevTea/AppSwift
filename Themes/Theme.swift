//
//  Theme.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import SwiftUI

// este archivo es el "theme" o sistema de diseno de la aplicacion.
// aqui se centralizan todos los colores y fuentes personalizadas.
// si se quiere cambiar un color en toda la app, solo se necesita cambiarlo aqui.

// anade todas las paletas de colores personalizadas de la app al tipo `color`.
extension Color {
    
    // -- colores principales de la app --
    
    static let appBackground = Color(UIColor.systemGray6)
    
    static let primaryBlue = Color(red: 0.22, green: 0.51, blue: 0.96)
    
    static let disabledGray = Color(UIColor.systemGray4)
    
    static let textFieldBackground = Color.white
    
    static let textPrimary = Color.black
    
    static let textSecondary = Color.gray
    
    static let textLink = Color(red: 0.22, green: 0.51, blue: 0.96)
    
    static let errorRed = Color.red

    // -- colores para los tags de severidad --
    // cada par (fondo y texto) se usa en `tagcomponent`.
    
    static let severitySevere = Color(red: 1.0, green: 0.9, blue: 0.9); static let severitySevereText = Color.red
    
    static let severityHigh = Color(red: 1.0, green: 0.95, blue: 0.85); static let severityHighText = Color.orange
    
    static let severityMedium = Color(red: 1.0, green: 1.0, blue: 0.85); static let severityMediumText = Color.yellow
    
    static let severityLow = Color(red: 0.9, green: 1.0, blue: 0.9); static let severityLowText = Color.green

    // -- colores para los tags de categoria --
    
    static let categoryMalware = Color(red: 0.9, green: 0.95, blue: 1.0); static let categoryMalwareText = Color.blue
    
    static let categoryPhishing = Color(red: 0.95, green: 0.9, blue: 1.0); static let categoryPhishingText = Color.purple
    
    static let categoryFraud = Color(red: 1.0, green: 0.98, blue: 0.85); static let categoryFraudText = Color(red: 0.8, green: 0.6, blue: 0.0)
    
    static let categorySpam = Color(red: 0.88, green: 0.98, blue: 0.98); static let categorySpamText = Color.teal
    
    static let categoryPrivacy = Color(red: 0.9, green: 0.95, blue: 1.0); static let categoryPrivacyText = Color.blue
    
    static let categoryIP = Color(red: 0.98, green: 0.95, blue: 0.92); static let categoryIPText = Color.brown
    
    // -- colores para los indicadores de estado de los reportes --
    
    static let statusReview = Color.orange
    
    static let statusAccepted = Color.green
    
    static let statusRejected = Color.red
    
    // -- colores para los tags de impacto de los reportes --
    
    static let impactFinancial = Color(red: 0.9, green: 1.0, blue: 0.9); static let impactFinancialText = Color.green
    
    static let impactPrivacy = Color(red: 0.9, green: 0.95, blue: 1.0); static let impactPrivacyText = Color.blue
    
    static let impactLegal = Color(red: 1.0, green: 0.95, blue: 0.85); static let impactLegalText = Color.orange
    
    static let impactIdentity = Color(red: 0.95, green: 0.9, blue: 1.0); static let impactIdentityText = Color.purple
    
    static let impactMalware = Color(red: 1.0, green: 0.9, blue: 0.9); static let impactMalwareText = Color.red
    
    static let impactDefault = Color(UIColor.systemGray5); static let impactDefaultText = Color(UIColor.systemGray)
}

// anade todos los estilos de texto estandar de la app al tipo `font`.
// usar estas fuentes asegura consistencia tipografica en toda la aplicacion.
extension Font {
    // para los titulos mas grandes y destacados.
    static let largeTitle = Font.system(size: 28, weight: .bold)
    // para el texto de parrafos normales.
    static let bodyText = Font.system(size: 16)
    // para el texto dentro de los botones principales.
    static let buttonFont = Font.system(size: 16, weight: .semibold)
    // para texto pequeno y secundario, como fechas o notas.
    static let caption = Font.system(size: 12)
}
