//
//  ClearBackgroundView.swift
//  RepNet
//
//  Created by Angel Bosquez on 22/10/25.
//

import SwiftUI

// se pone como .background() de un .fullScreenCover
// para hacer que el fondo sea transparente y poder crear un modal customizado

struct ClearBackgroundView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        return TransparentUIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}

    private class TransparentUIView: UIView {
        
        // se llama cuando la vista se dibuja en la pantalla
        override func layoutSubviews() {
            super.layoutSubviews()
            
          //fuerza que la vista se haga transparejte
            superview?.superview?.backgroundColor = .clear
        }
    }
}
