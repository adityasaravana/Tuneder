//
//  MusicAccessNotEnabledView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/17/23.
//

import SwiftUI

struct MusicAccessNotEnabledView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Enable Music Access")
                    .bold()
                    .font(.largeTitle)
                
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text("Tuneder relies on Apple Music for recommending songs you might like, playing previews of songs, and adding songs to your library.").padding(.vertical).foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.horizontal)
            
            
            
            HStack {
                Button {
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                } label: {
                    Text("Open Settings")
                        .fontWeight(.bold)
                        
                                    
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(25)
                
                Spacer()
            }.padding()
            Spacer()
            Text("Having issues? Email aditya.saravana@icloud.com")
        }
        .multilineTextAlignment(.leading)
        .padding(.vertical)
        .background(
            Color(uiColor: .secondarySystemBackground)
        )
    }
}

struct MusicAccessNotEnabledView_Previews: PreviewProvider {
    static var previews: some View {
        MusicAccessNotEnabledView()
    }
}
