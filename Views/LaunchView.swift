//
//  LaunchView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import SwiftUI

struct LaunchView: View {
        
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            
            Color.appBackground.ignoresSafeArea()
            
            VStack {
            
                Image("RepNetLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 10)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)

                Text("RepNet")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isAnimating = true
                }
            }
        }
    }
}

// preview hecha con ia
struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
