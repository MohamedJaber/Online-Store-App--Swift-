//
//  HelperFunction.swift
//  Online Store
//
//  Created by Mohamed Jaber on 01/01/2021.
//

import Foundation

public func convertToCurrency(_ number: Double) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    
    return currencyFormatter.string(from: NSNumber(value: number))!
}
