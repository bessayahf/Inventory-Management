//
//  addProduct.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 15/08/2024.
//

import SwiftUI
import PhotosUI
import CodeScanner

struct addProduct: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var selectImageSource : Bool = false
    @State private var selectedPhoto : PhotosPickerItem?
    @State private var selectedPhotoData  : Data?
    @State private var newproduct = Product ()
    @State private var isShowingScanner = false

    var body: some View {
        NavigationStack{
            List{
                Section{
                    if let selectedPhotoData,
                       let uiImage =  UIImage(data: selectedPhotoData){
                        Image(uiImage:uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500 , height: 200)
                    }
                    else {
                        Image("placeholder-image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500 , height: 200)
                    }
                }
               
                header : {
                    Text("Image")
                        .font(.subheadline)
                        .bold()
                }
                .onTapGesture {
                    selectImageSource.toggle()
                }
      
                Section{
                    TextField("Name", text: $newproduct.name)
                    HStack{
                        TextField("Code", text: $newproduct.code)
                        Button{
                            isShowingScanner.toggle()
                        }
                    label: {
                        Image(systemName: "barcode.viewfinder")
                    }
                    }
                }
            header: {
                Text("Product")
                    .font(.subheadline)
                    .bold()
            }
                Section{
                    HStack{
                        Text("Available:")
                            .foregroundStyle(Color.gray)
                        TextField("", value: $newproduct.quantity, format: .number)
                            .keyboardType(.numberPad)
                            
                    }
                    HStack{
                        Text("Min:")
                            .foregroundStyle(Color.gray)
                        TextField("", value: $newproduct.minquantity, format: .number)
                            .keyboardType(.numberPad)
                            
                    }
                    
                }
                header: {
                    Text("Quantity")
                        .font(.subheadline)
                        .bold()
                }
           
                Section{
                    
                    HStack{
                        Text("Unit Price:")
                            .foregroundStyle(Color.gray)
                        TextField("", value: $newproduct.purchasePrice, format: .number)
                            .keyboardType(.decimalPad)
                            
                    }
                    HStack{
                        Text("Total Price:")
                            .foregroundStyle(Color.gray)
                        let totalpurchaseprice = String(format: "%.2f", Double (newproduct.quantity) * newproduct.purchasePrice)
                        Text(totalpurchaseprice)
                            .foregroundStyle(Color.gray)

                    }

                }
                header: {
                    Text("Purchase")
                        .font(.subheadline)
                        .bold()
                }
                
                Section{
                    HStack{
                        Text("Unit Price:")
                            .foregroundStyle(Color.gray)
                        TextField("", value: $newproduct.salePrice, format: .number)
                            .keyboardType(.decimalPad)
                            
                    }
                    HStack{
                        Text("Total Price:")
                            .foregroundStyle(Color.gray)
                        let totalpurchaseprice = String(format: "%.2f", Double (newproduct.quantity) * newproduct.salePrice)
                        Text(totalpurchaseprice)
                            .foregroundStyle(Color.gray)

                    }

                }
                header: {
                    Text("Sale")
                        .font(.subheadline)
                        .bold()
                }
                
                    
                Section{
                    
                    HStack{
                        Text("Internal Ref:")
                            .foregroundStyle(Color.gray)
                        TextField("", text: $newproduct.internalRef)
                    }
                    HStack{
                        Text("Brand:")
                            .foregroundStyle(Color.gray)
                        TextField("", text: $newproduct.brand)
                    }
                    HStack{
                        Text("Model:")
                            .foregroundStyle(Color.gray)
                        TextField("", text: $newproduct.model)
                    }
                    HStack{
                        Text("Assignment:")
                            .foregroundStyle(Color.gray)
                        TextField("", text: $newproduct.assignement)
                    }
                    HStack{
                        Text("Notes:")
                            .foregroundStyle(Color.gray)
                        TextField("", text: $newproduct.notes)
                    }
                    HStack{
                        Text("Custom Field 1:")
                            .foregroundStyle(Color.gray)
                        TextField("", text: $newproduct.customField1)
                    }
                    HStack{
                        Text("Custom Field 2:")
                            .foregroundStyle(Color.gray)
                        TextField("", text: $newproduct.customField2)
                    }
                   
                    
                }
            header:{
                Text("Other Fields")
                    .font(.subheadline)
                    .bold()
            }
                
            }
            .navigationTitle("New Product")
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                  
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        newproduct.image = selectedPhotoData
                        modelContext.insert(newproduct)
                        let newtransaction = StockTransaction()
                        newtransaction.product=newproduct
                        newtransaction.quantity=newproduct.quantity
                        newtransaction.date=Date.now
                        newtransaction.type="IN"
                        modelContext.insert(newtransaction)
                        
                        dismiss()
                    }, label: {
                        Text("Done")
                    })
                    .disabled(newproduct.name.isEmpty)

        
                }


            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.code39,.codabar,.code128,.code39Mod43,.ean13,.ean8,.gs1DataBar,.gs1DataBarLimited,.gs1DataBarLimited], showViewfinder : true, shouldVibrateOnSuccess : true){ response in
                    switch response {
                       case .success(let result):
                        newproduct.code = result.string
                        isShowingScanner.toggle()
                       case .failure(let error):
                           print(error.localizedDescription)
                       }
                }
            }
            .sheet(isPresented: $selectImageSource, content: {
                NavigationStack{
                    List{
                        PhotosPicker("Open Gallery", selection: $selectedPhoto,
                                        matching: .images,
                                        photoLibrary: .shared())
                        .onChange(of: selectedPhoto) {
                                        
                                           Task {
                                               if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                                                   selectedPhotoData = data
                                               }
                                           }
                                        selectImageSource.toggle()
                                       }
                   
                        
                        Button{
                            showCamera.toggle()
                            
                        }
                        label: {
                        Text("Open Camera")
                        }
                        .fullScreenCover(isPresented: $showCamera) {
                                accessCameraView(selectedImage: $selectedPhotoData)
                                .onDisappear(){
                                    selectImageSource.toggle()
                                }
                            
                            }
                        Button{
                            selectedPhotoData = nil
                            selectImageSource.toggle()
                        }
                        label: {
                        Text("Delete Image")
                                .foregroundStyle(Color.red)
                        }
                }
                  
                }
                .presentationDetents([.medium])
            }
            )
            

        }
    }
}

