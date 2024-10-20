
import SwiftUI
import SwiftData
import RevenueCat
import RevenueCatUI

struct TransactionScreen: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var userinfo: userState

    @Query var transactiondata: [StockTransaction]
    @Query var productdata: [Product]
    @State private var showAddTransaction: Bool = false
    @State private var searchText = ""
    @State private var showPaywall = false
    @State private var isAscending: Bool = true // State for sorting order


    
    var filtredtransactions: [StockTransaction] {
//        guard !searchText.isEmpty else { return isAscending ? transactiondata : transactiondata.reversed() }
        guard !searchText.isEmpty else { return transactiondata}
        return transactiondata.filter { $0.product?.name.localizedStandardContains(searchText) ?? false }
    }

    var body: some View {
        NavigationStack {
            VStack{
                if(!productdata.isEmpty)
                {
                    List {
                        ForEach(filtredtransactions) { transaction in
                            HStack {
                                if let imagedata = transaction.product?.image, let uiImage = UIImage(data: imagedata) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                } else {
                                    Image("placeholder-image")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                }

                                if let product = transaction.product {
                                    VStack(alignment: .leading) {
                                        Text(product.name)
                                            .font(.headline)
                                        Text(transaction.date.formatted(date: .abbreviated , time: .omitted))
                                            .foregroundStyle(Color.purple)
                                            .font(.caption)
                                    }
                                }

                                Spacer()
                                if transaction.type == "IN" {
                                    Text("+ \(transaction.quantity)")
                                        .foregroundStyle(Color.green)
                                } else {
                                    Text("- \(transaction.quantity)")
                                        .foregroundStyle(Color.red)
                                }
                            }
                        }
//                        .onDelete(perform: { index in
//                            // get the item from the reversed list
//                            let theItem = filtredtransactions[index.first!]
//                            // get the index of the item from the viewModel, and remove it
//                            if let ndx = transactiondata.firstIndex(of: theItem) {
//                                modelContext.delete(transactiondata[ndx])
//                            }
//                        })
                        .onDelete { indexSet in
                            for index in indexSet {
                                let transtodelete = transactiondata[index]
                                modelContext.delete(transtodelete)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search Products")

                    
                }
                else{
                    Text("Your inventory is empty!\nBegin by adding products to get started.")
                         .multilineTextAlignment(.center)
                         .padding()

                }
            }
            .navigationTitle("Stock IN/OUT")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if(!productdata.isEmpty){
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

                ToolbarItem(placement: .topBarTrailing) {
                    HStack{
                        Button {
                            showAddTransaction.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .disabled(productdata.count == 0)
                        
//                        Button(action: {
//                            isAscending.toggle() // Toggle sorting direction
//                        }) {
//                            // Conditional Image based on isAscending
//                           
//                                isAscending ?
//                            AnyView(Image(systemName: "arrow.up.arrow.down.circle") )
//                                :
//                            AnyView( Image(systemName: "arrow.up.arrow.down.circle")
//                                    .rotationEffect(.degrees(180))
//                                    .scaleEffect(x: -1, y: 1))
//                            
//                        }
                    }

                }
            }
            .sheet(isPresented: $showAddTransaction) {
                NavigationStack {
                    addTransaction()
                }
                .presentationDetents([.medium])
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
        }
    }

    // Create CSV String
    func createCSV() -> String {
        var csvString = "Date,Product Name,Product Code, Stock IN/OUT,Quantity\n"
        for transaction in transactiondata {
            if let productName = transaction.product?.name {
                let productCode = transaction.product?.code ?? ""
                let dateString = transaction.date.formatted(date: .numeric, time: .omitted)
                let typeString = transaction.type
                let quantityString = String(transaction.quantity)
                let row = "\(dateString),\(productName),\(productCode),\(typeString),\(quantityString)\n"
                csvString += row
            }
        }
        return csvString
    }

    // Export and Share CSV File
    func exportCSV() -> URL {
        let csvString = createCSV()

        // Save CSV string to a temporary file
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("IN-OUT-Operations-\(Date.now.formatted(date: .abbreviated, time: .omitted)).csv")

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

