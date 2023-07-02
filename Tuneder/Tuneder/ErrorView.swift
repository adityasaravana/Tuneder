//
//  ErrorView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 7/1/23.
//

import SwiftUI

struct ErrorView: View {
    var debugDescription: String
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)

            VStack(alignment: .center) {
                Image("vader")
                    .resizable()
                    .frame(width: 139, height: 250)
                    .shadow(color: .red, radius: 100)
                
                Text("Fatal Error")
                    .bold()
                    .font(.title)
                    .padding(.top)
                    .foregroundColor(.red)
                    .padding(.bottom, 30)
                Text("You underestimate the power of the Dark Side.")
                    .bold()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("Email aditya.saravana@icloud.com")
                
                Spacer()
                
                Text("⚠️ ERROR DESCRIPTION: ⚠️")
                    .bold()
                
                Text(debugDescription)
                
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .padding()
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(debugDescription: "DEBUGERRORCONTENT")
    }
}
