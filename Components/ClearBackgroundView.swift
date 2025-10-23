//
//  ClearBackgroundView.swift
//  RepNet
//
//  Created by Angel Bosquez on 22/10/25.
//


import SwiftUI

/// Permite que una 'fullScreenCover' tenga un fondo transparente.
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return TransparentUIView()
    }
    func updateUIView(_ uiView: UIView, context: Context) {}

    private class TransparentUIView: UIView {
        override func layoutSubviews() {
            super.layoutSubviews()
            superview?.superview?.backgroundColor = .clear
        }
    }
}
