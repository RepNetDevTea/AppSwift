//
//  Report.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
// una vista que representa una "tarjeta" o un item en una lista de reportes.
// muestra la informacion mas importante de un reporte de forma resumida.
// reutiliza otros componentes como `tagcomponent` y `statusindicatorcomponent`.

import SwiftUI

struct ReportCardComponent: View {
    // el objeto `report` que contiene toda la informacion a mostrar.
    let report: Report

    var body: some View {
        // estructura principal: contenido a la izquierda, indicador y flecha a la derecha.
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // muestra la categoria y severidad como tags
                    TagComponent(text: report.category)
                    TagComponent(text: report.severity)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.title).font(.body).fontWeight(.semibold)
                    Text(report.date).font(.caption).foregroundColor(.textSecondary)
                }
            }
            Spacer()
            
            // logica condicional: muestra el estado o la puntuacion, pero no ambos.
            // esto permite que la tarjeta se adapte a diferentes contextos (ej. reportes publicos vs. mis reportes).
            
            // si el reporte tiene un estado (ej. "en revision"), se muestra aqui.
            
            if let statusText = report.statusText, let statusColor = report.statusColor {
                StatusIndicatorComponent(statusText: statusText, statusColor: statusColor)
            } else if let score = report.voteScore {
                
            // si el reporte no tiene estado pero si puntuacion, se muestra la puntuacion.
                
                HStack(spacing: 4) {
                    // Usamos un icono más neutral de "puntuación".
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .foregroundColor(.textSecondary)
                    // Usamos nuestra extensión para formatear el número. Puede mostrar negativos.
                    Text(score.formattedK)
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            Image(systemName: "chevron.right").foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.textFieldBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

