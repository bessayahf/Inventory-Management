//
//  Inventory_ManagementApp.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 14/08/2024.
//

import SwiftUI
import SwiftData

@main
struct Inventory_ManagementApp: App {
    
    let modelContainer: ModelContainer
      
      init() {
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
                    .tabItem{
                        Label("Inventory", systemImage: "shippingbox.fill")
                    }
                TransactionScreen()
                    .tabItem{
                        Label("IN/OUT", systemImage: "arrow.left.arrow.right.circle")
                    }
                ChartScreen()
                    .tabItem{
                        Label("Chart", systemImage: "chart.bar")
                    }
            }
        }
        .modelContainer(modelContainer)

    }

}
