//
//  BindingExt.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 31/12/2023.
//

import SwiftUI

extension Binding where Value == Bool {
    // Define a function that takes a binding to an optional value
    // and returns a binding to a Bool.
    static func optionalBoolBinding<T>(_ bvalue: Binding<T?>) -> Binding<Value> {
        return Binding(
            get: {
                bvalue.wrappedValue != nil
            },
            set: { newValue in
                if newValue == false {
                    bvalue.wrappedValue = nil
                }
            }
        )
    }
}
