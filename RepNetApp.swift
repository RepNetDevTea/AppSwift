//
//  RepNetApp.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import SwiftUI

@main
struct RepNetApp: App {
    var body: some Scene {
        WindowGroup {
            // Usamos una vista contenedora para manejar todo el flujo de la aplicación.
            RootView()
        }
    }
}

/// Esta es la primera vista de la aplicación. Se encarga de decidir qué pantalla mostrar:
/// el Splash Screen, el Tutorial de Onboarding, o el flujo principal de la app.
struct RootView: View {
    
    /// --- ESTADOS ---
    /// 1. Controla si la pantalla de bienvenida (splash) está visible.
    @State private var showSplash = true
    
    /// 2. Lee de la memoria del dispositivo si el usuario ya ha visto el tutorial.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    /// 3. El gestor de autenticación que controla el estado de login.
    @StateObject private var authManager = AuthenticationManager()

    var body: some View {
        ZStack {
            if showSplash {
                /// --- ETAPA 1: PANTALLA DE BIENVENIDA (SPLASH) ---
                /// Muestra la LaunchView animada al inicio.
                LaunchView()
                    .onAppear {
                        // Después de 2.5 segundos, oculta el splash screen con una animación.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                /// --- ETAPA 2: DECISIÓN DE FLUJO ---
                /// Una vez que el splash se oculta, decidimos qué mostrar.
                if hasSeenOnboarding {
                    /// Si el usuario ya vio el tutorial, vamos al flujo principal de la app.
                    if authManager.isAuthenticated {
                        MainTabView()
                            .environmentObject(authManager)
                    } else {
                        NavigationView {
                            LoginView()
                                .environmentObject(authManager)
                        }
                    }
                } else {
                    /// Si es la primera vez que el usuario abre la app, mostramos el tutorial.
                    /// La OnboardingView se encargará de cambiar 'hasSeenOnboarding' a 'true'.
                    OnboardingView()
                }
            }
        }
    }
}
