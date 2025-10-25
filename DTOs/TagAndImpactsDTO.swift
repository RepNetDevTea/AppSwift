//
//  TagAndImpactsDTO.swift
//  RepNet
//
//  Created by Angel Bosquez on 20/10/25.
//
//dto para tags e impactow

import Foundation

struct Tag: Decodable, Identifiable, Hashable, Nameable {
    let id: Int
    let tagName: String
    let tagScore: Int?
    let tagDescription: String?
    var name: String { tagName }
}


struct Impact: Decodable, Identifiable, Hashable, Nameable { // Conforms to Nameable
    let id: Int
    let impactName: String
    let impactScore: Int?
    let impactDescription: String?
    var name: String { impactName }
}

// sugerido por ia
protocol Nameable {
    var name: String { get }
}
