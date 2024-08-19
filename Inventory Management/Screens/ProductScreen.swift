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
    @State private var searchText = ""
    
    var filtredproducts: [Product] {
        guard !searchText.isEmpty else {return productdata}
        return productdata.filter {$0.name.localizedStandardContains(searchText)}
    }
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    ForEach(filtredproducts){product in
                        NavigationLink(destination: EditProduct(newproduct: product)){
                            
                            HStack{
                                if let imagedata = product.image {
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
                                VStack(alignment:.leading){
                                    Text(product.name)
                                        .bold()
                                    Text(product.code)
                                        .font(.caption)
                                }
                                Spacer()
                                if(product.quantity <= product.minquantity){
                                    Text("\(product.quantity)")
                                        .padding(.trailing)
                                        .foregroundStyle(Color.red)
                                    
                                }
                                else{
                                    Text("\(product.quantity)")
                                        .padding(.trailing)
                                }
                                
                            }
                        }
                    }
                    .onDelete(perform: {indexSet in
                        for index in indexSet {
                            let producttodelete = productdata[index]
                            modelContext.delete(producttodelete)
                        }
                    })
                    
                }
            }
            
            .navigationTitle("Inventory")
            .toolbar{
                Button(action: {
                    showAddProduct.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            }
            .searchable(text: $searchText)
            .sheet(isPresented: $showAddProduct, content: {
                NavigationStack{
                    addProduct()
                }
            })
            
        }
        
    }
    

    
}
