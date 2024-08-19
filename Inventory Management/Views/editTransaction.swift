//
//  editTransaction.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 18/08/2024.
//

import SwiftUI
import SwiftData

struct editTransaction: View {
   
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Bindable var newtransaction : StockTransaction
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

