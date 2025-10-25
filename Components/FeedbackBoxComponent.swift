//
//  FeedbackBoxComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 22/10/25.
//


import SwiftUI

// caja de texto simple
// se usa para mostrar el feedback que un administrador deja en un reporte
//

struct FeedbackBoxComponent: View {
    // el string de feedback que se va a mostrar
    let feedback: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // encabezado de la caja
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Feedback del Administrador")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            // el cuerpo del mensaje de feedback
            Text(feedback)
                .font(.body)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // asegura que ocupe todo el ancho
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// vista previa hecha con ia
struct FeedbackBoxComponent_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackBoxComponent(feedback: "Buen trabajo detectando este sitio. Sigue asi, tu reporte ayudo mucho.")
            .padding()
    }
}
