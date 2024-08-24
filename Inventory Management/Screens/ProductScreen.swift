

import SwiftUI
import SwiftData
import RevenueCat
import RevenueCatUI


struct ProductScreen: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.requestReview) var requestReview
    @Environment(\.dismiss) var dismiss


    @Query var productdata: [Product]
    @EnvironmentObject var userinfo: userState


    @State private var showAddProduct: Bool = false
    @State private var searchText = ""
    @State private var showDeleteConfirmation: Bool = false
    @State private var productToDelete: Product?
    @State private var showPaywall = false

    var filtredproducts: [Product] {
        guard !searchText.isEmpty else { return productdata }
        return productdata.filter { $0.name.localizedStandardContains(searchText) }
    }

    private var limitReached : Bool {((productdata.count >= userinfo.recordlimit ) && (!userinfo.ispro)) }
    
    var body: some View {
        NavigationStack {
            VStack {
                if productdata.count >= 1 {
                    List {
                        ForEach(filtredproducts) { product in
                            NavigationLink(destination: EditProduct(newproduct: product)) {
                                HStack {
                                    if let imagedata = product.image {
                                        if let uiImage = UIImage(data: imagedata) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                        }
                                    } else {
                                        Image("placeholder-image")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(product.name)
                                            .bold()
                                        Text(product.code)
                                            .font(.caption)
                                    }
                                    Spacer()
                                    Text("\(product.quantity)")
                                        .padding(.trailing)
                                        .foregroundStyle(product.quantity <= product.minquantity ? Color.red : Color.primary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                productToDelete = productdata[index]
                                showDeleteConfirmation = true
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search Products")
                } else {
                    Text("Get started by tapping the '+' button to add your first product to the inventory.")
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !productdata.isEmpty {
                        if(userinfo.ispro){
                            ShareLink("Export CSV", item: exportCSV())

                        }
                        else{
                            Button{
                                showPaywall.toggle()
                            }
                        label:{
                            Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    if(!userinfo.ispro){
                        Button(action: {
                            showPaywall.toggle()
                        }) {
                            HStack{
                                Image(systemName: "crown.fill")
                                    .foregroundColor(Color.yellow)
                                Text("Premium Access")
                                    .foregroundStyle(Color.yellow)
                            }
                        }
                    }
    
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if(limitReached){
                            showPaywall.toggle()

                        }
                        else{
                            showAddProduct.toggle()
                        }
                       
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddProduct) {
                NavigationStack {
                    addProduct()
                }
            }
            .confirmationDialog("Are you sure you want to delete this product?\n All its IN/OUT operations will also be deleted.", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let productToDelete = productToDelete {
                        modelContext.delete(productToDelete)
                        self.productToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    self.productToDelete = nil
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            NavigationStack{
                PaywallView()
                    .onPurchaseCompleted { customerInfo in
                        if customerInfo.entitlements["Premium"]?.isActive == true {
                          // Unlock that great "pro" content
                            userinfo.ispro = true
                        }
                        else {
                            userinfo.ispro = false
                        }
                    }
                    .toolbar{
                        Button{
                            showPaywall.toggle()
                        }
                    label:{
                            Image(systemName: "xmark")
                            .foregroundColor(Color.white)
                    }
                    }
            }
        }
        .onAppear(){
            checkCustomerInfo()

            if ((productdata.count == 1) || (productdata.count == 2) || (productdata.count >= 4) ){
                requestReview()
            }
        }
    }

    func createCSV() -> String {
        var csvString = "Product Name,Code,Available Quantity,Min Quantity,Purchase Price,Total Purchase,Sale Price,Total Sale,Internal Ref,Brand,Model,Assignment,Notes,Custom Field1,Custom Field2\n"
        for product in productdata {
            let totalpurchase = String(format: "%.2f", Double(product.quantity) * product.purchasePrice)
            let totalsale = String(format: "%.2f", Double(product.quantity) * product.salePrice)
            let row = "\(product.name),\(product.code),\(String(product.quantity)),\(String(product.minquantity)),\(product.purchasePrice),\(totalpurchase),\(product.salePrice),\(totalsale),\(product.internalRef),\(product.brand),\(product.model),\(product.assignement),\(product.notes),\(product.customField1),\(product.customField2)\n"
            csvString += row
        }
        return csvString
    }

    func exportCSV() -> URL {
        let csvString = createCSV()
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("Product-Inventory-\(Date.now.formatted(date: .abbreviated, time: .omitted)).csv")

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV file: \(error)")
            return fileURL
        }
    }
    
    func checkCustomerInfo(){
        // Check RevenueCat user info
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            // access latest customerInfo
            if customerInfo?.entitlements["Premium"]?.isActive == true {
            // Unlock that great "pro" content
                userinfo.ispro = true
                }
                else {
                userinfo.ispro = false
                }
     
            
            }
    }
    
}







////
////  ContentView.swift
////  Inventory Management
////
////  Created by Faycal Bessayah on 14/08/2024.
////
//
//import SwiftUI
//import SwiftData
//
//struct ProductScreen: View {
//    @Environment(\.modelContext) var modelContext
//    @Query var productdata: [Product]
//
//    @State private var showAddProduct : Bool = false
//    @State private var searchText = ""
//
//    var filtredproducts: [Product] {
//        guard !searchText.isEmpty else {return productdata}
//        return productdata.filter {$0.name.localizedStandardContains(searchText)}
//    }
//    var body: some View {
//        NavigationStack{
//            VStack{
//                if (productdata.count>=1){
//                    List{
//                        ForEach(filtredproducts){product in
//                            NavigationLink(destination: EditProduct(newproduct: product)){
//
//                                HStack{
//                                    if let imagedata = product.image {
//                                        if let uiImage =  UIImage(data: imagedata){
//                                            Image(uiImage:uiImage)
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 50 , height: 50)
//                                        }
//
//                                    }
//                                    else {
//                                        Image("placeholder-image")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 50 , height: 50)
//                                    }
//                                    VStack(alignment:.leading){
//                                        Text(product.name)
//                                            .bold()
//                                        Text(product.code)
//                                            .font(.caption)
//                                    }
//                                    Spacer()
//                                    if(product.quantity <= product.minquantity){
//                                        Text("\(product.quantity)")
//                                            .padding(.trailing)
//                                            .foregroundStyle(Color.red)
//
//                                    }
//                                    else{
//                                        Text("\(product.quantity)")
//                                            .padding(.trailing)
//                                    }
//
//                                }
//                            }
//                        }
//                        .onDelete(perform: {indexSet in
//                            for index in indexSet {
//                                let producttodelete = productdata[index]
//                                modelContext.delete(producttodelete)
//                            }
//                        })
//
//                    }
//                    .searchable(text: $searchText, prompt: "Search Products")
//
//                }
//                else {
//                    Text("Get started by tapping the '+' button to add your first product to the inventory.")
//                        .multilineTextAlignment(.center)
//                }
//
//            }
//
//            .navigationTitle("Inventory")
//            .toolbar{
//
//                ToolbarItem(placement: .topBarLeading) {
//                    if(!productdata.isEmpty){
//                        ShareLink("Export CSV", item: exportCSV())
//
//                    }
//                }
//
//
//                ToolbarItem(placement: .topBarTrailing) {
//
//                    Button(action: {
//                        showAddProduct.toggle()
//                    }, label: {
//                        Image(systemName: "plus")
//                    })
//                }
//
//            }
//            .sheet(isPresented: $showAddProduct, content: {
//                NavigationStack{
//                    addProduct()
//                }
//            })
//
//        }
//
//    }
//
//
//    // Create CSV String
//    func createCSV() -> String {
//        var csvString = "Product Name,Code,Available Quantity,Min Quantity,Purchase Price,Total Purchase,Sale Price,Total Sale,Internal Ref,Brand,Model,Assignment,Notes,Custom Field1,Custom Field2\n"
//        for product in productdata {
//
//            let totalpurchase = String(format: "%.2f", Double (product.quantity) * product.purchasePrice)
//            let totalsale = String(format: "%.2f", Double (product.quantity) * product.salePrice)
//
//            let row = "\(product.name),\(product.code),\(String(product.quantity)),\(String(product.minquantity)),\(product.purchasePrice),\(totalpurchase),\(product.salePrice),\(totalsale),\(product.internalRef),\(product.brand),\(product.model),\(product.assignement),\(product.notes),\(product.customField1),\(product.customField2)\n"
//                csvString += row
//
//        }
//        return csvString
//    }
//
//    // Export and Share CSV File
//    func exportCSV() -> URL {
//        let csvString = createCSV()
//
//        // Save CSV string to a temporary file
//        let fileManager = FileManager.default
//        let tempDirectory = fileManager.temporaryDirectory
//        let fileURL = tempDirectory.appendingPathComponent("Product-Inventory-\(Date.now.formatted(date: .abbreviated, time: .omitted)).csv")
//
//        do {
//            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
//            return fileURL
//        } catch {
//            print("Failed to write CSV file: \(error)")
//            return fileURL
//        }
//    }
//
//
//}
