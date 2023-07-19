//
//  SettingsView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/18/23.
//

import SwiftUI
import Defaults

struct SettingsView: View {
    @Default(.explicitContentAllowed) var explicitContentAllowed
    @Default(.showExplicitContentWarning) var showExplicitContentWarning
    @Binding var showing: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Toggle("Allow Explicit Content", isOn: $explicitContentAllowed)
                if explicitContentAllowed {
                    Toggle("Show Explicit Warning Text", isOn: $showExplicitContentWarning)
                }
            }
            .navigationBarTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            showing = false
                        }
                    } label: {
                        Image(systemName: "xmark").font(.system(size: 20))
                    }
                }
            }
        }
        .onChange(of: explicitContentAllowed) { newValue in
            if !newValue {
                showExplicitContentWarning = false
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showing: .constant(true))
    }
}
