//
//  SettingsView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/18/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageNames.explicitContentAllowed.name) var explicitContentAllowed: Bool = true
    @AppStorage(AppStorageNames.showExplicitContentWarning.name) var showExplicitContentWarning: Bool = true
    var body: some View {
        NavigationStack {
            Form {
                Toggle("Allow Explicit Content", isOn: $explicitContentAllowed)
                if explicitContentAllowed {
                    Toggle("Show Explicit Warning Text", isOn: $showExplicitContentWarning)
                }
            }
            .navigationBarTitle("Settings")
        }.onChange(of: explicitContentAllowed) { newValue in
            if !newValue {
                showExplicitContentWarning = false
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
