//
//  Report.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//



import Foundation
import SwiftUI

enum UserVoteStatus: String, Codable {
    case upvoted
    case downvoted
}

struct Report: Identifiable, Equatable {
    static func == (lhs: Report, rhs: Report) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let displayId: String
    let title: String
    let date: String
    let url: String
    let description: String
    let category: String
    let severity: String
    let user: UserInReportDTO
    let createdAt: Date
    let evidences: [EvidenceResponseDTO]
    let impacts: [String]
    let severityScore: Int
    let statusText: String?
    let statusColor: Color?
    let voteScore: Int?
    let userVoteStatus: UserVoteStatus?
    let adminFeedback: String?
    let userId: Int // Added userId
    

    init(
        id: UUID = UUID(),
        displayId: String,
        title: String,
        date: String,
        url: String,
        description: String,
        category: String,
        severity: String,
        user: UserInReportDTO,
        createdAt: Date,
        evidences: [EvidenceResponseDTO],
        impacts: [String],
        severityScore: Int,
        statusText: String? = nil,
        statusColor: Color? = nil,
        voteScore: Int? = nil,
        userVoteStatus: UserVoteStatus? = nil,
        userId: Int,
        adminFeedback: String? = nil
        
    ) {
        self.id = id
        self.displayId = displayId
        self.title = title
        self.date = date
        self.url = url
        self.description = description
        self.category = category
        self.severity = severity
        self.user = user
        self.createdAt = createdAt
        self.evidences = evidences
        self.impacts = impacts
        self.severityScore = severityScore
        self.statusText = statusText
        self.statusColor = statusColor
        self.voteScore = voteScore
        self.userVoteStatus = userVoteStatus
        self.userId = userId
        self.adminFeedback = adminFeedback
    }
}
