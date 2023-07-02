//
//  ContentView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @State var musicAuthStatus: SKCloudServiceAuthorizationStatus = .notDetermined
    @State var showingErrorScreen = false
    @State var errorDescription = "I don't know how the hell you managed to get this error, but you did. This is awkward."
    var body: some View {
        VStack {
            if showingErrorScreen {
                ErrorView(debugDescription: errorDescription)
            } else {
                switch musicAuthStatus {
                case .notDetermined:
                    MusicAccessNotEnabledView()
                case .denied:
                    MusicAccessNotEnabledView()
                case .restricted:
                    MusicAccessNotEnabledView()
                case .authorized:
                    MainView(showingErrorScreen: $showingErrorScreen, errorDescription: $errorDescription)
                @unknown default:
                    MusicAccessNotEnabledView()
                }
            }
        }.onAppear {
            SKCloudServiceController.requestAuthorization { [self] status in
                switch status {
                    case .authorized:
                        self.musicAuthStatus = .authorized
                    case .restricted:
                        self.musicAuthStatus = .restricted
                    case .notDetermined:
                        self.musicAuthStatus = .notDetermined
                    case .denied:
                        self.musicAuthStatus = .denied
                    @unknown default:
                        self.musicAuthStatus = .notDetermined
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
