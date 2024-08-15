//
//  ContentView.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 14/08/2024.
//

import SwiftUI
import SwiftData

struct ProductScreen: View {
    @Environment(\.modelContext) var modelContext
    @Query var productdata: [Product]
    
    @State private var showAddProduct : Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
            }
            .navigationTitle("Inventory")
            .toolbar{
                Button(action: {
                    showAddProduct.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            }
            .sheet(isPresented: $showAddProduct, content: {
                NavigationStack{
                    addProduct()
                }
            })
        }
    
    }
}

