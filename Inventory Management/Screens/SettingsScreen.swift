//
//  SettingsScreen.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 23/08/2024.
//

import SwiftUI
import SwiftData

struct SettingsScreen: View {

    @Query var transactiondata: [StockTransaction]

    
    // State for CSV export
    @State private var csvURL: URL? = nil
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    ShareLink("Export CSV", item: exportCSV())

                    }
            header: {
                Text("Export IN/OUT History")
                    .font(.subheadline)
                    .bold()
                }
                
                
            }
            
        }
    }
    
    // Create CSV String
    func createCSV() -> String {
        var csvString = "Date,Product Name,Transaction Type,Transaction Quantity\n"
        for transaction in transactiondata {
            if let productName = transaction.product?.name {
                let dateString = transaction.date.formatted(date: .abbreviated, time: .omitted)
                let typeString = transaction.type
                let quantityString = String(transaction.quantity)
                let row = "\(dateString),\(productName),\(typeString),\(quantityString)\n"
                csvString += row
            }
        }
        return csvString
    }

    // Export and Share CSV File
    func exportCSV()-> URL {
        let csvString = createCSV()

        // Save CSV string to a temporary file
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("transactions.csv")

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV file: \(error)")
            return fileURL
        }
    }
    
}

