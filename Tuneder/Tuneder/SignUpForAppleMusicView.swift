//
//  SignUpForAppleMusicView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/17/23.
//

import SwiftUI
import StoreKit

#warning("After significant downloads, switch to letting people sign up in-app, so you can earn commisions (search up apple affiliate program, you'll find it)")
struct SignUpForAppleMusicView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Sign Up For Apple Music")
                    .bold()
                    .font(.largeTitle)
                
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text("Tuneder relies on Apple Music for recommending songs you might like, playing previews of songs, and adding songs to your library. To access the Apple Music catalog, you need a subscription, so by extension Tuneder does too.").padding(.vertical).foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.horizontal)
            
            
            
            HStack {
                Button {
                    if let url = URL(string: "https://www.apple.com/apple-music/") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Sign Up For Apple Music")
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                        
                                    
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

struct SignUpForAppleMusicView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpForAppleMusicView()
    }
}

