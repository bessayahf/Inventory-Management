//
//  Customer.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 14/08/2024.
//

import Foundation
import SwiftData

@Model
class Customer{
    var uuid : String
    var name : String
    var address : String
    var email : String
    var phone : String
    
    init(name: String = "", address: String = "", email: String = "", phone: String = "") {
        self.uuid = UUID().uuidString
        self.name = name
        self.address = address
        self.email = email
        self.phone = phone
    }
}
