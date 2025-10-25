//
//  NumberPlusFormatting.swift
//  RepNet
//
//  Created by Angel Bosquez on 10/10/25.
//extension para formato devotos

import Foundation

extension Int {
    var formattedK: String {
        if self < 1000 {
            return String(self)
        }
        
        let num = Double(self) / 1000.0
        return String(format: num.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fk" : "%.1fk", num)
    }
}
