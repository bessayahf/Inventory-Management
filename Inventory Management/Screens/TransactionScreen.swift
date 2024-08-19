//
//  TransactionScreen.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 17/08/2024.
//

import SwiftUI
import SwiftData

struct TransactionScreen: View {
    @Environment(\.modelContext) var modelContext
    @Query var transactiondata: [StockTransaction]
    @Query var productdata : [Product]
    @State private var showAddTransaction : Bool = false
   // var newtransaction : StockTransaction = StockTransaction()
    
    @State private var searchText = ""

    var filtredtransactions: [StockTransaction] {
        guard !searchText.isEmpty else {return transactiondata}
        return transactiondata.filter {$0.product?.name.localizedStandardContains(searchText) ?? true}
    }
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(filtredtransactions) { transaction in
                        HStack{
                            
                            if let imagedata = transaction.product?.image {
                                if let uiImage =  UIImage(data: imagedata){
                                    Image(uiImage:uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50 , height: 50)
                                }
                                
                            }
                            else {
                                Image("placeholder-image")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50 , height: 50)
                            }
                            
                            if let product = transaction.product{
                                VStack(alignment: .leading){
                                    Text(product.name)
                                        .font(.headline)
                                 //   Text(product.code)
                                  //      .font(.caption)
                                    Text(transaction.date.formatted(date:.numeric, time: .omitted))
                                        .foregroundStyle(Color.purple)
                                        .font(.caption)
                                }
                                
                            }
                                   
                          
                              
                            
                            Spacer()
                            if(transaction.type == "IN"){
                                Text("+ \(transaction.quantity)")
                                    .foregroundStyle(Color.green)
                            }
                            else{
                                Text("- \(transaction.quantity)")
                                    .foregroundStyle(Color.red)

                            }
                        }
                
                    
                }
                .onDelete(perform: {indexSet in
                    for index in indexSet {
                        let transtodelete = transactiondata[index]
                        modelContext.delete(transtodelete)
                    }
                })
            }
            .sheet(isPresented: $showAddTransaction){
                NavigationStack{
                    addTransaction()
                }
                .presentationDetents([.medium])
            }
            .navigationTitle("Operations")
            .toolbar{
                Button {
                    showAddTransaction.toggle()
                    
                }
                label: {
                        Image(systemName: "plus")
                }
                .disabled(productdata.count == 0)
            }
            .searchable(text: $searchText)
            
        }
    }
}

