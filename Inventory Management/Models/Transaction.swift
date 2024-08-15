//
//  Transacrion.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 14/08/2024.
//

import Foundation
import SwiftData

@Model
class Transaction{
    var uuid : String
    var date : Date
    var quantity : Int
    var isOrder : Bool
    @Relationship(deleteRule : .noAction) var product = Product ()
    @Relationship(deleteRule : .noAction) var client = Client ()
    
    init(date: Date, quantity: Int = 0, isOrder: Bool = true) {
        self.uuid = UUID().uuidString
        self.date = date
        self.quantity = quantity
        self.isOrder = isOrder
    }
}
