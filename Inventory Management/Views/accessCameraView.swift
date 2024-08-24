////
////  accessCameraView.swift
////  Inventory Management
////
////  Created by Faycal Bessayah on 15/08/2024.
////
//
//import Foundation
//import SwiftUI
//
//struct accessCameraView: UIViewControllerRepresentable {
//    
//    @Binding var selectedImage: Data?
//    @Environment(\.presentationMode) var isPresented
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .camera
//        imagePicker.allowsEditing = true
//        imagePicker.delegate = context.coordinator
//        return imagePicker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
//        
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(picker: self)
//    }
//}
//
//// Coordinator will help to preview the selected image in the View.
//class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//    var picker: accessCameraView
//    
//    init(picker: accessCameraView) {
//        self.picker = picker
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let selectedImage = info[.originalImage] as? UIImage else { return }
//        self.picker.selectedImage = selectedImage.pngData()
//        self.picker.isPresented.wrappedValue.dismiss()
//        
//    }
//}

import SwiftUI

struct accessCameraView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImageData: Data?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: accessCameraView

        init(_ parent: accessCameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Convert UIImage to Data
                parent.selectedImageData = image.jpegData(compressionQuality: 1.0)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

