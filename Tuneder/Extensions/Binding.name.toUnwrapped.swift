//
//  Binding.name.toUnwrapped.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import Foundation
import SwiftUI

extension Binding {
     func toUnwrapped<T>() -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue! }, set: { self.wrappedValue = $0 })
    }
}
