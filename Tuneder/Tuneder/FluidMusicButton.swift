//
//  FluidMusicButton.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import SwiftUI

struct FluidMusicButton: View {
    @Binding var isPlaying: Bool
    @State private var transparency: Double = 0.0
    
    var body: some View {
        Button {
            isPlaying.toggle()
            transparency = 0.6
            withAnimation(.easeOut(duration: 0.2)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    transparency = 0.0
                }
            }
        } label: {
            ZStack {
                Circle()
                    .frame(width: 90, height: 90)
                    .opacity(transparency)
                Image(systemName: "pause.fill")
                    .font(.system(size: 64))
                    .scaleEffect(isPlaying ? 1 : 0)
                    .opacity(isPlaying ? 1 : 0)
                    .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isPlaying)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 64))
                    .scaleEffect(isPlaying ? 0 : 1)
                    .opacity(isPlaying ? 0 : 1)
                    .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isPlaying)
            }
        }
    }
}

