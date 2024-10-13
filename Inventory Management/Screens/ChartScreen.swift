
import SwiftUI
import SwiftData
import Charts

struct ChartScreen: View {
    @Query var productdata: [Product]
//    @Query var transactiondata: [StockTransaction]
    @Query(sort: [SortDescriptor(\StockTransaction.date, order: .forward)]) var transactiondata: [StockTransaction]
    @EnvironmentObject var userinfo: userState

    
    @State private var selectedProduct: Product? = nil
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
//    @State private var startDate: Date = transactiondata.first?.date ?? Calendar.current.date(byAdding: .month, value: -1, to: Date())!
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
    
    var groupedTransactions: [(Date, String, [String: Int])] {

        // Group the transactions based on the selected grouping
        let grouped = Dictionary(grouping: filteredTransactions) { transaction -> Date in
            let calendar = Calendar.current
            switch groupBy {
            case .day:
                return calendar.startOfDay(for: transaction.date)
            case .week:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: transaction.date)?.start ?? transaction.date
                return startOfWeek
            case .month:
                let components = calendar.dateComponents([.year, .month], from: transaction.date)
                return calendar.date(from: components) ?? transaction.date
            }
        }

        // Convert the grouped dictionary into an array of tuples and calculate stock quantities
        let groupedArray = grouped.map { (date: Date, transactions: [StockTransaction]) in
            let stockIn = transactions.filter { $0.type == "IN" }.reduce(0) { $0 + $1.quantity }
            let stockOut = transactions.filter { $0.type == "OUT" }.reduce(0) { $0 + $1.quantity }

            // Format the date for display purposes based on the grouping
            let dateString: String
            switch groupBy {
            case .day:
                dateString = date.formatted(.dateTime.year().month().day())
            case .week:
                let weekOfYear = Calendar.current.component(.weekOfYear, from: date)
                let year = Calendar.current.component(.year, from: date)
                dateString = "Week \(weekOfYear), \(year)"
            case .month:
                dateString = date.formatted(.dateTime.year().month())
            }

            return (date, dateString, ["IN": stockIn, "OUT": stockOut])
        }

        // Sort the grouped array by the actual Date value
        return groupedArray.sorted { $0.0 < $1.0 }
    }
    
    
//    var groupedTransactions: [(String, [String: Int])] {
//
//        
//        // Group the sorted transactions based on the selected grouping
//        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
//            switch groupBy {
//            case .day:
//                return transaction.date.formatted(.dateTime.year().month().day()) // returns a string
//            case .week:
//                let weekOfYear = Calendar.current.component(.weekOfYear, from: transaction.date)
//                return "Week \(weekOfYear), \(Calendar.current.component(.year, from: transaction.date))"
//            case .month:
//                return transaction.date.formatted(.dateTime.year().month()) // returns a string
//            }
//        }
//        
//        // Convert the grouped dictionary into an array of tuples and calculate stock quantities
//        return grouped.map { (key: String, transactions: [StockTransaction]) in
//            let stockIn = transactions.filter { $0.type == "IN" }.reduce(0) { $0 + $1.quantity }
//            let stockOut = transactions.filter { $0.type == "OUT" }.reduce(0) { $0 + $1.quantity }
//            return (key, ["IN": stockIn, "OUT": stockOut])
//        }
//        // Transactions are already sorted by date, so no need to sort again
//    }
    
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
//        .sorted { (lhs, rhs) in
//            switch groupBy {
//            case .day:
//                // Convert string to date for proper sorting
//                let lhsDate = Date.fromString(lhs.0, format: "yyyy-MM-dd")
//                let rhsDate = Date.fromString(rhs.0, format: "yyyy-MM-dd")
//                return lhsDate < rhsDate
//            case .week:
//                // Parse the week and year from the string
//                let lhsComponents = lhs.0.components(separatedBy: ", ")
//                let rhsComponents = rhs.0.components(separatedBy: ", ")
//                if let lhsWeek = Int(lhsComponents[0].replacingOccurrences(of: "Week ", with: "")),
//                   let rhsWeek = Int(rhsComponents[0].replacingOccurrences(of: "Week ", with: "")),
//                   let lhsYear = Int(lhsComponents[1]),
//                   let rhsYear = Int(rhsComponents[1]) {
//                    return (lhsYear, lhsWeek) < (rhsYear, rhsWeek)
//                }
//                return false
//            case .month:
//                // Sort by year and month
//                let lhsDate = Date.fromString(lhs.0, format: "yyyy-MM")
//                let rhsDate = Date.fromString(rhs.0, format: "yyyy-MM")
//                return lhsDate < rhsDate
//            }
//        }
////        .sorted(by: {
////            $0.0 < $1.0
////
////        })
//    }
    

    
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
                        }

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
//                        Chart {
//                            ForEach(groupedTransactions, id: \.0) { (date, quantities) in
//                                BarMark(
//                                    x: .value("Date", date),
//                                    y: .value("IN Stock", quantities["IN"] ?? 0)
//                                )
//                                .foregroundStyle(Color.blue.gradient)
//                                .position(by: .value("Stock Type", "IN"))
//                                .annotation(position: .top) {
//                                    if showAnnotations, let quantityIn = quantities["IN"], quantityIn > 0 {
//                                        Text("\(quantityIn)")
//                                            .font(.caption)
//                                            .foregroundColor(.blue)
//                                    }
//                                }
//
//                                BarMark(
//                                    x: .value("Date", date),
//                                    y: .value("OUT Stock", quantities["OUT"] ?? 0)
//                                )
//                                .foregroundStyle(Color.red.gradient)
//                                .position(by: .value("Stock Type", "OUT"))
//                                .annotation(position: .top) {
//                                    if showAnnotations, let quantityOut = quantities["OUT"], quantityOut > 0 {
//                                        Text("\(quantityOut)")
//                                            .font(.caption)
//                                            .foregroundColor(.red)
//                                    }
//                                }
//                            }
//                        }
                        Chart {
                            ForEach(groupedTransactions, id: \.0) { (_, dateString, quantities) in
                                BarMark(
                                    x: .value("Date", dateString),
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
                                    x: .value("Date", dateString),
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
        .onAppear(){
            if !transactiondata.isEmpty  {
                startDate = transactiondata.first?.date ?? Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            }
            
        }
    }
}

enum GroupBy: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
}
