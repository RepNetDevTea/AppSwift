//
//  OnboardingDataModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 20/10/25.
//

import Foundation

// este struct representa los datos para una sola pantalla del tutorial.
// hacerlo 'identifiable' nos permite usarlo facilmente en un 'foreach'.
struct OnboardingData: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
}

// definimos los datos para las 4 pantallas de nuestro tutorial.
// tenerlos en un solo lugar facilita su modificación en el futuro.
extension OnboardingData {
    static let screens: [OnboardingData] = [
        OnboardingData(
            iconName: "shield.lefthalf.filled",
            title: "Bienvenido a RepNet",
            description: "Tu centro de inteligencia colectiva para combatir las amenazas cibernéticas."
        ),
        OnboardingData(
            iconName: "arrow.up.doc.on.clipboard",
            title: "Identifica y Reporta Amenazas",
            description: "Sube evidencias de phishing, malware o fraude de forma rápida y sencilla para alertar a la comunidad."
        ),
        OnboardingData(
            iconName: "arrow.up.arrow.down.circle.fill",
            title: "Evalúa el Impacto Real",
            description: "Explora los reportes de otros usuarios, vota en ellos para darles visibilidad y mantente informado sobre los riesgos actuales."
        ),
        OnboardingData(
            iconName: "person.3.sequence.fill",
            title: "Juntos Creamos un Internet Más Seguro",
            description: "¿Listo para empezar a contribuir?"
        )
    ]
}
