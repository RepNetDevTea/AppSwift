//
//  ReportDetailViewModel.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//

import Foundation

@MainActor
class ReportDetailViewModel: ObservableObject {
    
    // El reporte que se está mostrando. Lo marcamos como @Published
    // para que la vista se actualice cuando cambie (ej. al votar).
    @Published var report: Report
    
    private let votesAPIService = VotesAPIService()
    
    init(report: Report) {
        self.report = report
    }
    
    /// Maneja la lógica cuando el usuario presiona el botón de 'upvote'.
    func handleUpvote() {
        let originalStatus = report.userVoteStatus
        let originalScore = report.voteScore ?? 0
        var newStatus: UserVoteStatus? = nil
        var newScore = originalScore
        
        // Lógica de "interruptor" de Reddit
        if originalStatus == .upvoted {
            // Si ya tenías upvote, se cancela.
            newStatus = nil
            newScore -= 1
        } else if originalStatus == .downvoted {
            // Si tenías downvote, se cambia a upvote (suma 2).
            newStatus = .upvoted
            newScore += 2
        } else {
            // Si no habías votado, se añade un upvote.
            newStatus = .upvoted
            newScore += 1
        }
        
        // 1. Actualización Optimista de la UI: actualizamos la pantalla al instante.
        updateReportState(newScore: newScore, newStatus: newStatus)
        
        // 2. Llamada a la API en segundo plano
        Task {
            do {
                try await votesAPIService.castVote(reportId: Int(report.displayId) ?? 0, voteType: "upvote")
            } catch {
                // 3. Si la API falla, revertimos los cambios en la UI al estado original.
                print("❌ Error al enviar upvote: \(error)")
                updateReportState(newScore: originalScore, newStatus: originalStatus)
            }
        }
    }
    
    /// Maneja la lógica cuando el usuario presiona el botón de 'downvote'.
    func handleDownvote() {
        let originalStatus = report.userVoteStatus
        let originalScore = report.voteScore ?? 0
        var newStatus: UserVoteStatus? = nil
        var newScore = originalScore
        
        if originalStatus == .downvoted {
            // Si ya tenías downvote, se cancela.
            newStatus = nil
            newScore += 1
        } else if originalStatus == .upvoted {
            // Si tenías upvote, se cambia a downvote (resta 2).
            newStatus = .downvoted
            newScore -= 2
        } else {
            // Si no habías votado, se añade un downvote.
            newStatus = .downvoted
            newScore -= 1
        }
        
        // 1. Actualización Optimista de la UI
        updateReportState(newScore: newScore, newStatus: newStatus)

        // 2. Llamada a la API en segundo plano
        Task {
            do {
                try await votesAPIService.castVote(reportId: Int(report.displayId) ?? 0, voteType: "downvote")
            } catch {
                // 3. Si la API falla, revierte los cambios.
                print("❌ Error al enviar downvote: \(error)")
                updateReportState(newScore: originalScore, newStatus: originalStatus)
            }
        }
    }
    
    // Función auxiliar para actualizar el estado del reporte de forma segura.
    // En ReportDetailViewModel.swift

    private func updateReportState(newScore: Int, newStatus: UserVoteStatus?) {
        // ✨ CORREGIDO: Se actualizó el inicializador para que coincida con el nuevo modelo 'Report'.
        // Simplemente pasamos los nuevos valores que ya tenía el reporte.
        self.report = Report(
            id: report.id,
            displayId: report.displayId,
            title: report.title,
            date: report.date,
            url: report.url,
            description: report.description,
            category: report.category,
            severity: report.severity,
            user: report.user,
            createdAt: report.createdAt,
            evidences: report.evidences,     // Se pasa el valor existente
            impacts: report.impacts,         // Se pasa el valor existente
            severityScore: report.severityScore, // Se pasa el valor existente
            statusText: report.statusText,
            statusColor: report.statusColor,
            voteScore: newScore,             // Se actualiza con el nuevo valor
            userVoteStatus: newStatus,
            userId: report.userId,
            adminFeedback: report.adminFeedback
        )
    }
}
