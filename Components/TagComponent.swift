//
//  TagComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
//Dropdown picker component depende de este componente

import SwiftUI

// un componente de "tag" o "etiqueta" inteligente.
// su color de fondo y de texto cambian automaticamente segun el contenido del texto.
// esto permite mantener un estilo consistente para valores especificos en toda la app
// (ej. severidades, categorias, etc.).
struct TagComponent: View {
    
    // el texto que se muestra en el tag y que tambien determina su estilo.
    let text: String
    
    // propiedades privadas para guardar el estilo, determinadas en el `init`.
    private let backgroundColor: Color
    private let textColor: Color

    // el inicializador solo necesita el texto.
    // la logica para elegir los colores se delega a la funcion `getstyle`.
    init(text: String) {
        self.text = text
        let style = Self.getStyle(for: text)
        self.backgroundColor = style.backgroundColor
        self.textColor = style.textColor
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(20)
    }
    
    // actua como un diccionario de estilos: recibe un texto y devuelve los colores correctos.
    // esto centraliza toda la logica de estilo en un solo lugar para facil mantenimiento.
    // se asume que los colores (ej. `.severitysevere`) estan definidos en un `theme`.
    private static func getStyle(for text: String) -> (backgroundColor: Color, textColor: Color) {
        switch text {
        // severidades
        case "severa": return (.severitySevere, .severitySevereText)
        case "alta", "high": return (.severityHigh, .severityHighText)
        case "media", "medium": return (.severityMedium, .severityMediumText)
        case "baja", "low": return (.severityLow, .severityLowText)
            
        // categorias
        case "phishing": return (.categoryPhishing, .categoryPhishingText)
        case "malware": return (.categoryMalware, .categoryMalwareText)
        case "fraude": return (.categoryFraud, .categoryFraudText)
        case "spam": return (.categorySpam, .categorySpamText)
        case "violacion de privacidad": return (.categoryPrivacy, .categoryPrivacyText)
        case "falsificacion/propiedad intelectual": return (.categoryIP, .categoryIPText)
            
        // impactos
        case "robo de credenciales", "robo de identidad":
            return (.impactIdentity, .impactIdentityText)
        case "perdida financiera":
            return (.impactFinancial, .impactFinancialText)
        case "perdida de la privacidad":
            return (.impactPrivacy, .impactPrivacyText)
        case "infeccion de malware":
            return (.impactMalware, .impactMalwareText)
        case "riesgo legal":
            return (.impactLegal, .impactLegalText)
            
        // valor por defecto para cualquier otro texto que no coincida.
        default: return (.impactDefault, .impactDefaultText)
        }
    }
}

//preview ia

struct TagComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            TagComponent(text: "severa")
            TagComponent(text: "malware")
            TagComponent(text: "fraude")
            TagComponent(text: "perdida financiera")
            TagComponent(text: "otro texto") // ejemplo del caso por defecto.
        }
        .padding()
    }
}
