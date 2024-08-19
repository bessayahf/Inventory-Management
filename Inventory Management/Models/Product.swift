//
//  Product.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 14/08/2024.
//

import Foundation
import SwiftData

@Model
class Product {
    var uuid : String
    var openingdate : Date = Date.now
    var name : String
    var code : String
    var image : Data?
    var quantity : Int
    var minquantity : Int = 0
    var salePrice : Double
    var purchasePrice : Double
    var internalRef : String
    var brand : String
    var model : String
    var assignement : String
    var notes : String
    var customField1 : String
    var customField2 : String
    @Relationship(deleteRule: .noAction) var transactions = [StockTransaction]()
    
    init(name: String = "", code: String = "", image: Data? = nil, quantity: Int = 0,
         salePrice: Double  = 0, purchasePrice: Double = 0,
         internalRef: String  = "", brand: String  = "", model: String  = "", assignement: String  = "", notes: String  = "",
         customField1: String  = "", customField2: String  = "") {
        self.uuid = UUID().uuidString
        self.name = name
        self.code = code
        self.image = image
        self.quantity = quantity
        self.salePrice = salePrice
        self.purchasePrice = purchasePrice
        self.internalRef = internalRef
        self.brand = brand
        self.model = model
        self.assignement = assignement
        self.notes = notes
        self.customField1 = customField1
        self.customField2 = customField2
    }
    
    
}
