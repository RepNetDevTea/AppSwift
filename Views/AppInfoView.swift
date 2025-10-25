//
//  AppInfoView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//


import SwiftUI

// vista simple y estatica para mostrar informacion sobre la app.



struct AppInfoView: View {
    var body: some View {
        // el zstack se usa para establecer un color de fondo para toda la pantalla.
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("release notes")
                            .font(.title).bold()
                        
                        // seccion para la fecha y version.
                        VStack(alignment: .leading) {
                            Text("20 septiembre 2025")
                            Text("version: 1.2")
                        }
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        
                        // texto de relleno para las notas.
                        Text("lorem ipsum dolor sit amet, consectetur adipiscing elit. vestibulum a lacinia odio. sed luctus ut diam quis gravida. donec venenatis placerat malesuada. aliquet ac odio scelerisque, dignissim nulla et leo ornare venenatis. morbi at interdum quam, eu pharetra nunc.")
                            .font(.body)
                    }
                    .padding(30)
                    .background(Color.textFieldBackground)
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .navigationTitle("app info")
       
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AppInfoView()
    }
}
