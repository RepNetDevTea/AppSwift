//
//  LaunchView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//


import SwiftUI

struct LaunchView: View {
    
    /// --- NUEVA LÓGICA DE ANIMACIÓN ---
    /// 1. Creamos una variable de estado. Cuando cambie de 'false' a 'true',
    ///    SwiftUI animará cualquier vista que dependa de ella.
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                //cambiar el logo
                Image("RepNetLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 10)
                    /// 2. Aplicamos los modificadores de animación a la imagen.
                    ///    - scaleEffect: Controla el tamaño. Empieza en 0.8 si no está animando.
                    ///    - opacity: Controla la visibilidad. Empieza en 0 si no está animando.
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)

                Text("RepNet")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    /// 3. Aplicamos el modificador de opacidad al texto.
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            /// 4. Cuando la vista aparece, esperamos una fracción de segundo y luego
            ///    cambiamos 'isAnimating' a 'true' dentro de un bloque 'withAnimation'.
            ///    Esto le dice a SwiftUI que anime suavemente la transición
            ///    de los estados iniciales a los finales.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isAnimating = true
                }
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}


