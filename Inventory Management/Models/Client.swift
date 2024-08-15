//
//  Supplier.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 14/08/2024.
//

import Foundation
import SwiftData

@Model
class Client{
    var uuid : String
    var name : String 
    var address : String
    var city : String
    var zipcode : String
    var email : String
    var phone : String
    var isSupplier : Bool
    
    init(name: String = "", address: String = "", city : String = "", zipcode : String = "", email: String = "", phone: String = "", isSupplier : Bool = true) {
        self.uuid = UUID().uuidString
        self.name = name
        self.address = address
        self.email = email
        self.city = city
        self.zipcode = zipcode
        self.phone = phone
        self.isSupplier = isSupplier
    }
}
