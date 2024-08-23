//
//  chart.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 20/08/2024.
//

//import SwiftUI
//import SwiftData
//import Charts
//
//struct chart: View {
//    @Query var productdata : [Product]
//    @Query var transactiondata : [StockTransaction]
//    
//    var stockIndata : [StockTransaction] {
//        return transactiondata.filter{
//            $0.type == "IN"
//        }
//    }
//    var stockOutdata : [StockTransaction] {
//        return transactiondata.filter{
//            $0.type == "OUT"
//        }
//    }
//    
//    var body: some View {
//        NavigationStack{
//            VStack{
//                Chart{
//                    ForEach(transactiondata){ transaction in
//                        BarMark(x: .value("Date", transaction.date.formatted(date: .abbreviated, time: .omitted)),
//                                y: .value("Stock", transaction.quantity))
//                        .foregroundStyle(by: .value("Stock IN/OUT", transaction.type))
//                        .position(by: .value("Type", transaction.type))
//                        
//                    }
//                }
//                .frame(height: 180)
//                .padding()
//                .chartForegroundStyleScale([
//                    "IN" : Color.blue.gradient,
//                    "OUT": Color.red.gradient
//                    ])
//            }
//            .navigationTitle("Charts")
//        }
//    }
//}



//import SwiftUI
//import SwiftData
//import Charts
//
//struct ChartScreen: View { // Updated struct name to follow Swift naming conventions
//    @Query var productdata: [Product]
//    @Query var transactiondata: [StockTransaction]
//    
//    @State private var selectedProduct: Product? = nil
//    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
//    @State private var endDate: Date = Date()
//    @State private var groupBy: GroupBy = .day
//    
//    // New state variables to track selected bar
//    @State private var selectedDate: String? = nil
//    @State private var selectedType: String? = nil
//    
//    var filteredTransactions: [StockTransaction] {
//        let calendar = Calendar.current
//        
//        // Normalize start date to the start of the day
//        let normalizedStartDate = calendar.startOfDay(for: startDate)
//        
//        // Normalize end date to the end of the day
//        var components = DateComponents()
//        components.day = 1
//        components.second = -1
//        let normalizedEndDate = calendar.date(byAdding: components, to: calendar.startOfDay(for: endDate))!
//        
//        return transactiondata.filter { transaction in
//            let transactionDate = transaction.date
//            let matchesProduct = selectedProduct == nil || transaction.product == selectedProduct
//            let withinDateRange = transactionDate >= normalizedStartDate && transactionDate <= normalizedEndDate
//            return matchesProduct && withinDateRange
//        }
//    }
//    
//    var groupedTransactions: [(String, [String: Int])] {
//        Dictionary(grouping: filteredTransactions) { transaction in
//            switch groupBy {
//            case .day:
//                return transaction.date.formatted(.dateTime.year().month().day())
//            case .week:
//                let weekOfYear = Calendar.current.component(.weekOfYear, from: transaction.date)
//                return "Week \(weekOfYear), \(Calendar.current.component(.year, from: transaction.date))"
//            case .month:
//                return transaction.date.formatted(.dateTime.year().month())
//            }
//        }
//        .mapValues { transactions in
//            let stockIn = transactions.filter { $0.type == "IN" }.reduce(0) { $0 + $1.quantity }
//            let stockOut = transactions.filter { $0.type == "OUT" }.reduce(0) { $0 + $1.quantity }
//            return ["IN": stockIn, "OUT": stockOut]
//        }
//        .sorted(by: { $0.0 < $1.0 })
//    }
//    
//    var body: some View {
//        NavigationStack {
//            if(!transactiondata.isEmpty){
//                VStack {
//                    
//                    VStack{
//                        // Grouping options
//                        Picker("Group By", selection: $groupBy) {
//                            ForEach(GroupBy.allCases, id: \.self) { group in
//                                Text(group.rawValue.capitalized).tag(group)
//                            }
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                        .padding()
//                        // Chart
//                        Chart {
//                            ForEach(groupedTransactions, id: \.0) { (date, quantities) in
//                                BarMark(
//                                    x: .value("Date", date),
//                                    y: .value("IN Stock", quantities["IN"] ?? 0)
//                                )
//                                .foregroundStyle(Color.blue.gradient)
//                                .position(by: .value("Stock Type", "IN"))
//                                
//
//                                BarMark(
//                                    x: .value("Date", date),
//                                    y: .value("OUT Stock", quantities["OUT"] ?? 0)
//                                )
//                                .foregroundStyle(Color.red.gradient)
//                                .position(by: .value("Stock Type", "OUT"))
//                           
//                            }
//                        }
//                        .frame(height: 300)
//                        .padding()
//                        .chartForegroundStyleScale([
//                                          "IN" : Color.blue.gradient,
//                                          "OUT": Color.red.gradient
//                                          ])
//           
//                    }
//
//                    
//                    // Filter options
//                    VStack {
//
//
//                            Picker("Product: ", selection: $selectedProduct) {
//                                Text("All Products").tag(Product?.none)
//                                ForEach(productdata) { product in
//                                    Text(product.name).tag(product as Product?)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//           
//                    
//                        
//                            DatePicker("Start Date: ", selection: $startDate, displayedComponents: .date)
//                                .datePickerStyle(CompactDatePickerStyle())
//          
//                            DatePicker("End Date: ", selection: $endDate, displayedComponents: .date)
//                                .datePickerStyle(CompactDatePickerStyle())
//
//                    }
//                    .padding()
//                    
//
//
//                }
//                .padding()
//                .navigationTitle("Stock Evolution")
//
//            }
//            else{
//                VStack{
//
//                    
//                   Text("Your inventory is empty!\nBegin by adding products to get started.")
//                        .multilineTextAlignment(.center)
//
//                }
//                .navigationTitle("Stock Evolution")
//
//            }
//        }
//    }
//}
//
//enum GroupBy: String, CaseIterable {
//    case day = "day"
//    case week = "week"
//    case month = "month"
//}

import SwiftUI
import SwiftData
import Charts

struct ChartScreen: View {
    @Query var productdata: [Product]
    @Query var transactiondata: [StockTransaction]
    
    @State private var selectedProduct: Product? = nil
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var groupBy: GroupBy = .day
    @State private var showAnnotations: Bool = true // State variable to control annotation visibility
    
    var filteredTransactions: [StockTransaction] {
        let calendar = Calendar.current
        let normalizedStartDate = calendar.startOfDay(for: startDate)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let normalizedEndDate = calendar.date(byAdding: components, to: calendar.startOfDay(for: endDate))!
        
        return transactiondata.filter { transaction in
            let transactionDate = transaction.date
            let matchesProduct = selectedProduct == nil || transaction.product == selectedProduct
            let withinDateRange = transactionDate >= normalizedStartDate && transactionDate <= normalizedEndDate
            return matchesProduct && withinDateRange
        }
    }
    
    var groupedTransactions: [(String, [String: Int])] {
        Dictionary(grouping: filteredTransactions) { transaction in
            switch groupBy {
            case .day:
                return transaction.date.formatted(.dateTime.year().month().day())
            case .week:
                let weekOfYear = Calendar.current.component(.weekOfYear, from: transaction.date)
                return "Week \(weekOfYear), \(Calendar.current.component(.year, from: transaction.date))"
            case .month:
                return transaction.date.formatted(.dateTime.year().month())
            }
        }
        .mapValues { transactions in
            let stockIn = transactions.filter { $0.type == "IN" }.reduce(0) { $0 + $1.quantity }
            let stockOut = transactions.filter { $0.type == "OUT" }.reduce(0) { $0 + $1.quantity }
            return ["IN": stockIn, "OUT": stockOut]
        }
        .sorted(by: { $0.0 < $1.0 })
    }
    
    var body: some View {
        NavigationStack {
            if !transactiondata.isEmpty {
                VStack {
                 
                    HStack{
                        Spacer()
                        // Button to toggle annotations
                        Button(action: {
                            showAnnotations.toggle()
                        }) {
                            Text(showAnnotations ? "Hide Annotations" : "Show Annotations")
//                                .font(.caption)
//                                    .padding()
//
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(8)
                        }
//                        .padding()
                    }
                    VStack {
                        Picker("Group By", selection: $groupBy) {
                            ForEach(GroupBy.allCases, id: \.self) { group in
                                Text(group.rawValue.capitalized).tag(group)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                     
                        // Chart with conditional annotations
                        Chart {
                            ForEach(groupedTransactions, id: \.0) { (date, quantities) in
                                BarMark(
                                    x: .value("Date", date),
                                    y: .value("IN Stock", quantities["IN"] ?? 0)
                                )
                                .foregroundStyle(Color.blue.gradient)
                                .position(by: .value("Stock Type", "IN"))
                                .annotation(position: .top) {
                                    if showAnnotations, let quantityIn = quantities["IN"], quantityIn > 0 {
                                        Text("\(quantityIn)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }

                                BarMark(
                                    x: .value("Date", date),
                                    y: .value("OUT Stock", quantities["OUT"] ?? 0)
                                )
                                .foregroundStyle(Color.red.gradient)
                                .position(by: .value("Stock Type", "OUT"))
                                .annotation(position: .top) {
                                    if showAnnotations, let quantityOut = quantities["OUT"], quantityOut > 0 {
                                        Text("\(quantityOut)")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .frame(height: 300)
                        .padding()
                        .chartForegroundStyleScale([
                            "IN" : Color.blue.gradient,
                            "OUT": Color.red.gradient
                        ])

 
                    }

                    VStack {
                        Picker("Product: ", selection: $selectedProduct) {
                            Text("All Products").tag(Product?.none)
                            ForEach(productdata) { product in
                                Text(product.name).tag(product as Product?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())

                        DatePicker("Start Date: ", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())

                        DatePicker("End Date: ", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                    .padding()
                }
                .padding()
                .navigationTitle("Stock Evolution")
            } else {
                VStack {
                    Text("Your inventory is empty!\nBegin by adding products to get started.")
                        .multilineTextAlignment(.center)
                }
                .navigationTitle("Stock Evolution")
            }
        }
    }
}

enum GroupBy: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
}
