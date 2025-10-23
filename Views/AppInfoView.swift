//
//  AppInfoView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//


import SwiftUI

// esta es una vista simple y estatica para mostrar informacion sobre la app.
// actualmente muestra notas de la version, pero podria usarse para terminos y condiciones, etc.


struct AppInfoView: View {
    var body: some View {
        // el zstack se usa para establecer un color de fondo para toda la pantalla.
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                // el scrollview asegura que el contenido se pueda desplazar si es muy largo.
                ScrollView {
                    // el vstack interior agrupa todo el texto y se le da un estilo de tarjeta.
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
        // se establece el titulo de la barra de navegacion.
        .navigationTitle("app info")
        // `.inline` muestra el titulo pequeno en el centro, en lugar de grande a la izquierda.
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AppInfoView()
    }
}
