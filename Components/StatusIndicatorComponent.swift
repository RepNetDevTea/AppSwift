//
//  StatusIndicatorComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
//indicador visual, circulo de color con texto descriptivo



import SwiftUI

struct StatusIndicatorComponent: View {
    //texto que describe estado
    let statusText: String
    //color del circulo
    let statusColor: Color

    var body: some View {
        //alineacion del ciruclo y texto con un pequeno espacio
        HStack(spacing: 5) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

//ejemplos creados con ia
#Preview {
    VStack(alignment: .leading, spacing: 10) {
        StatusIndicatorComponent(statusText: "Revisión", statusColor: .statusReview)
        StatusIndicatorComponent(statusText: "Aceptado", statusColor: .statusAccepted)
        StatusIndicatorComponent(statusText: "Rechazado", statusColor: .statusRejected)
    }
    .padding()
}
