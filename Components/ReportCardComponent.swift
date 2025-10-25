//
//  Report.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//

import SwiftUI

// componente de tarjeta que muestra el resumen de un reporte
// se usa en las listas de "mis reportes" y "reportes publicos"
// muestra tags, titulo, fecha y un indicador de estado o de votos


struct ReportCardComponent: View {
    let report: Report

    var body: some View {
        // hstack principal: contenido a la izquierda, indicador/flecha a la derecha
        HStack(alignment: .top) {
            // vstack para el contenido principal (tags, titulo, fecha)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // muestra categoria y severidad como tags
                    TagComponent(text: report.category)
                    TagComponent(text: report.severity)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.title)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(report.date)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
                        
            // si el reporte tiene texto de estado
            if let statusText = report.statusText, let statusColor = report.statusColor {
                StatusIndicatorComponent(statusText: statusText, statusColor: statusColor)
                
            // si no tiene estado, pero si puntuacion (ej. reportes publicos)
            } else if let score = report.voteScore {
                // muestra la puntuacion
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .foregroundColor(.textSecondary)
                    // usa la extension para formatear el numero
                    Text(score.formattedK)
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            
            // flecha que indica que se puede tocar
            Image(systemName: "chevron.right").foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.textFieldBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}
