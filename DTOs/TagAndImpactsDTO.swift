//
//  TagAndImpactsDTO.swift
//  RepNet
//
//  Created by Angel Bosquez on 20/10/25.
//

import Foundation

// Struct for GET /tags response
struct Tag: Decodable, Identifiable, Hashable, Nameable { // Conforms to Nameable
    let id: Int
    let tagName: String
    let tagScore: Int?
    let tagDescription: String?

    // Conformance to Nameable
    var name: String { tagName }
}

// Struct for GET /impacts response
struct Impact: Decodable, Identifiable, Hashable, Nameable { // Conforms to Nameable
    let id: Int
    let impactName: String
    let impactScore: Int?
    let impactDescription: String?

    // Conformance to Nameable
    var name: String { impactName }
}

// ✨ DEFINE Nameable ONLY HERE ✨
protocol Nameable {
    var name: String { get }
}
