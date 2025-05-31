//
//  Item.swift
//  ZenAkku
//
//  Created by Denis Bitter on 31.05.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
