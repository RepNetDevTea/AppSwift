//
//  SiteCardComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//
// tarjeta expandible que muestra la informacion de un sitio web
// el encabezado muestra un resumen
// revela una lista de los reportes asociados a ese sitio.

import SwiftUI

struct SiteCardComponent: View {

    let site: Site
    let currentUserId: Int?

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Sitio Web")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Text(site.domain)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundColor(.textPrimary)
                    }

                    Spacer()

                    reputationRing

                    Image(systemName: "chevron.down")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .padding(.bottom, isExpanded ? 10 : 0)

            if isExpanded && !site.reports.isEmpty {
                VStack(alignment: .leading) {
                    Text("Reportes Asociados (\(site.reports.count))")
                        .font(.headline)
                        .padding(.top, 10)

                    ForEach(site.reports) { report in
                        // Pass currentUserId to ReportDetailView
                        NavigationLink(destination: ReportDetailView(report: report, currentUserId: currentUserId)) {
                            ReportCardComponent(report: report)
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(Color.textFieldBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var reputationRing: some View {
        ZStack {
            Circle()
                .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 5)
            Circle()
                .trim(from: 0, to: CGFloat(site.reputationScore) / 100.0)
                .stroke(Color.primaryBlue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(site.reputationScore)%")
                .font(.caption)
                .fontWeight(.bold)
        }
        .frame(width: 50, height: 50)
    }
}

