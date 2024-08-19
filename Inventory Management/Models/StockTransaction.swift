//
//  Transacrion.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 14/08/2024.
//

import Foundation
import SwiftData

@Model
class StockTransaction{
    var uuid : String
    var date : Date
    var quantity : Int
    var type : String
    var product : Product?
    var client : Client?
    var notes: String?
    
    init(date: Date = .now, quantity: Int = 0, type: String = "IN") {
        self.uuid = UUID().uuidString
        self.date = date
        self.quantity = quantity
        self.type = type
    }
}
