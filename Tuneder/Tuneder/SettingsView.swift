//
//  SettingsView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/18/23.
//

import SwiftUI
import Defaults

/// This view isn't in use yet, but will be. I'd like to add settings to block explicit content, and this is where it'll go. Data is stored using Defaults (see Defaults.swift).
struct SettingsView: View {
    @State var explicitContentAllowed = true {
        didSet {
            Defaults[.explicitAllowed] = self.explicitContentAllowed
            if !self.explicitContentAllowed {
                self.showExplicitWarningText = false
            }
        }
    }
    @State var showExplicitWarningText = true {
        didSet {
            Defaults[.showBlockExplicitText] = self.showExplicitWarningText
        }
    }
    var body: some View {
        NavigationStack {
            Form {
                Toggle("Allow Explicit Content", isOn: $explicitContentAllowed)
                if explicitContentAllowed {
                    Toggle("Show Explicit Warning Text", isOn: $showExplicitWarningText)
                }
            }
            .navigationBarTitle("Settings")
        }.onAppear {
            explicitContentAllowed = Defaults[.explicitAllowed]
            if !explicitContentAllowed {
                showExplicitWarningText = false
            } else {
                showExplicitWarningText = Defaults[.showBlockExplicitText]
            }
            
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
