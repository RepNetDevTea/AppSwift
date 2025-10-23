//
//  FeedbackBoxComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 22/10/25.
//


import SwiftUI

struct FeedbackBoxComponent: View {
    let feedback: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue) // Or your app's info color
                Text("Feedback del Administrador")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            Text(feedback)
                .font(.body)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes full width
        .background(Color.blue.opacity(0.1)) // Light blue background
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1) // Subtle border
        )
    }
}

// Preview
struct FeedbackBoxComponent_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackBoxComponent(feedback: "Buen trabajo detectando este sitio. Sigue así, tu reporte ayudó mucho.")
            .padding()
    }
}