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
            RootView()
        }
    }
}


struct RootView: View {
    @State private var showSplash = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var authManager = AuthenticationManager()

    var body: some View {
        ZStack {
            if showSplash {
              
                LaunchView()
                    .onAppear {
                      
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
               
                if hasSeenOnboarding {
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
                   
                    OnboardingView()
                }
            }
        }
    }
}
