//
//  Inventory_ManagementApp.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 14/08/2024.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct Inventory_ManagementApp: App {
    @StateObject var userstate = userState()

    
    let modelContainer: ModelContainer
      
      init() {
          Purchases.logLevel = .debug
          Purchases.configure(withAPIKey: "appl_VjrSPYzmdEAlGBcTYsSrMtRsGIH")
          
          do {
              modelContainer = try ModelContainer(for: Product.self)
          } catch {
              fatalError("Could not initialize ModelContainer")
          }
      }
    
    
    var body: some Scene {
        WindowGroup {
            TabView{
                ProductScreen()
                    .environmentObject(userstate)
                    .tabItem{
                        Label("Inventory", systemImage: "shippingbox.fill")
                    }
                TransactionScreen()
                    .environmentObject(userstate)
                    .tabItem{
                        Label("IN/OUT", systemImage: "arrow.left.arrow.right.circle")
                    }
                ChartScreen()
                    .environmentObject(userstate)
                    .tabItem{
                        Label("Chart", systemImage: "chart.bar")
                    }
            }
        }
        .modelContainer(modelContainer)

    }

}
