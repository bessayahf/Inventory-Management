//
//  Date.swift
//  Inventory Management
//
//  Created by Faycal Bessayah on 13/10/2024.
//
import Foundation

extension Date {
    static func fromString(_ dateString: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString) ?? Date.distantPast
    }
}
