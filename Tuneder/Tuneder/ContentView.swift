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
    
    var body: some View {
        VStack {
            switch musicAuthStatus {
            case .notDetermined:
                MusicAccessNotEnabledView()
            case .denied:
                MusicAccessNotEnabledView()
            case .restricted:
                MusicAccessNotEnabledView()
            case .authorized:
                MainView()
            @unknown default:
                MusicAccessNotEnabledView()
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
