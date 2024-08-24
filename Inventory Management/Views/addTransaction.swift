//
//  addTransaction.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 18/08/2024.
//

import SwiftUI
import SwiftData

struct addTransaction: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query var productdata : [Product]
    @State private var newtransaction : StockTransaction = StockTransaction()
    @State private var selectedProduct : String = ""
    @State private var quantity : Int = 0
    @State private var selectedType = "IN"
    @State private var showingAlert = false
    let operationtype = ["IN", "OUT"]
    
    var body: some View {
        NavigationStack{
            List{
                
                DatePicker("Date", selection: $newtransaction.date, in: ...Date.now, displayedComponents: .date)
                Picker("Product", selection: $selectedProduct) {
                    ForEach(productdata, id: \.uuid){product in
                            Text(product.name)
                          
                    }
                }
                .pickerStyle(.menu)
                
                if let currentproduct = getProductByID(id: selectedProduct){
                    HStack{
                        Text("Available Quantity")
                            .foregroundStyle(Color.gray)
                        Spacer()
                        Text("\(currentproduct.quantity)")
                            .foregroundStyle(Color.gray)
                    }
                }
                
                Picker("Stock", selection: $selectedType) {
                    ForEach(operationtype, id: \.self){type in
                        Text(type)
                    }
                }
                .pickerStyle(.menu)
              
                
                
                
                HStack{
                    if(selectedType == "IN"){
                        Text("Quantity IN :")
                    }
                    else {
                        Text("Quantity OUT :")
                    }
                  
                    TextField("", value: $quantity, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        
                }
                
                
            }
            .navigationTitle("New Operation")
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        let currentproduct = getProductByID(id: selectedProduct)
                        if (selectedType == "IN"){
                            newtransaction.product = currentproduct
                            newtransaction.type = selectedType
                            newtransaction.quantity = quantity
                            newtransaction.product?.quantity += quantity
                            modelContext.insert(newtransaction)
                            dismiss()
                        }
                        else{
                            if let availablequantity = currentproduct?.quantity {
                                if(availablequantity < quantity) {
                                    showingAlert.toggle()
                                }
                                else
                                {
                                    newtransaction.product = currentproduct
                                    newtransaction.type = selectedType
                                    newtransaction.quantity = quantity
                                    newtransaction.product?.quantity -= quantity
                                    modelContext.insert(newtransaction)
                                    dismiss()
                                }
                            }
                           
                            
                        }
                      
                       
                    }
                    label: {
                        Text("Done")
                        }
                    .disabled(quantity == 0)
                    .alert(isPresented: $showingAlert) {
                                Alert(title: Text("Error"),
                                      message: Text("The available quantity is less than \(quantity)"),
                                      dismissButton: .default(Text("Got it!")))
                            }
                    
                }
            }
            
        }
        .onAppear(){
            if productdata.count >= 1 {
                selectedProduct = productdata.first!.uuid
            }
            
        }

 
    }
    
    func getProductByID(id: String) -> Product? {
        return productdata.first(where: {$0.uuid == id})
        
    }
}
