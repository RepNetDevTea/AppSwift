//
//  OnboardingView.swift
//  RepNet
//
//  Created by Angel Bosquez on 20/10/25.
//


import SwiftUI

struct OnboardingView: View {
    
   
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    private let onboardingData = OnboardingData.screens

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(onboardingData) { screen in
                        OnboardingScreenView(data: screen)
                            .tag(onboardingData.firstIndex(where: { $0.id == screen.id }) ?? 0)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(onboardingData.indices, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.primaryBlue : Color.disabledGray)
                                .frame(width: currentPage == index ? 20 : 8, height: 8)
                        }
                    }
                    .animation(.easeInOut, value: currentPage)
                    
                    if currentPage == onboardingData.count - 1 {
                        PrimaryButtonComponent(title: "Comenzar", action: completeOnboarding)
                    } else {
                        PrimaryButtonComponent(title: "Siguiente", action: goToNextPage)
                    }
                }
                .padding()
            }
        }
    }
    
    private func goToNextPage() {
        withAnimation {
            if currentPage < onboardingData.count - 1 {
                currentPage += 1
            }
        }
    }
    
    private func completeOnboarding() {
        hasSeenOnboarding = true
    }
}


struct OnboardingScreenView: View {
    let data: OnboardingData
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: data.iconName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.primaryBlue)
            
            Text(data.title)
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            
            Text(data.description)
                .font(.bodyText)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
        .padding(40)
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
