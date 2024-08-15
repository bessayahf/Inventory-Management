//
//  addProduct.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 15/08/2024.
//

import SwiftUI
import PhotosUI

struct addProduct: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var selectImageSource : Bool = false
    @State private var selectedPhoto : PhotosPickerItem?
    @State private var selectedPhotoData  : Data?
    @State private var newproduct = Product ()
    var body: some View {
        NavigationStack{
            List{
                
//                Section{
//                    Button(action: {
//                        selectImageSource.toggle()
//                    }, label: {
//                        Label("Add Image", systemImage: "photo")
//                    })
//                }
                Section{
                    if let selectedPhotoData,
                       let uiImage =  UIImage(data: selectedPhotoData){
                        Image(uiImage:uiImage)
                            .resizable()
                            .scaledToFit()
//                            .frame(width: 300 height: 100)
                    }
                    else {
                        Image("placeholder-image")
                            .resizable()
                            .scaledToFit()
//                            .frame(maxWidth: .infinity , maxHeight: 100)
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
//                Section {
//                    PhotosPicker(selection: $selectedPhoto,
//                                 matching: .images,
//                                 photoLibrary: .shared())
//                    {
//                        Label("Add Image", systemImage: "photo")
//                    }
//                }
      
                Section{
                    TextField("Name", text: $newproduct.name)
                    TextField("Code", text: $newproduct.code)
                }
            header: {
                Text("Product")
                    .font(.subheadline)
                    .bold()
            }
                Section{
                        TextField("Quantity", value: $newproduct.quantity, format: .number)
                    
                }
                header: {
                    Text("Quantity")
                        .font(.subheadline)
                        .bold()
                }
                Section{
                    TextField("Purchase Price", value: $newproduct.purchasePrice, format: .number)

                }
                header: {
                    Text("Purchase Price")
                        .font(.subheadline)
                        .bold()
                }
                
                Section{
                    TextField("Sale Price", value: $newproduct.salePrice, format: .number)

                }
                header: {
                    Text("Sale Price")
                        .font(.subheadline)
                        .bold()
                }
                
                    
                Section{
                    TextField("Internal Ref", text: $newproduct.internalRef)
                    TextField("Brand", text: $newproduct.brand)
                    TextField("Model", text: $newproduct.model)
                    TextField("Assignement", text: $newproduct.assignement)
                    TextField("Notes", text: $newproduct.notes)
                    TextField("Custom Field 1", text: $newproduct.customField1)
                    TextField("Custom Field 2", text: $newproduct.customField2)
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
                        
                    }, label: {
                        Text("Done")
                    })
                    .disabled(newproduct.name.isEmpty)

        
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
                        }
                  
                }
            })
        }
    }
}

