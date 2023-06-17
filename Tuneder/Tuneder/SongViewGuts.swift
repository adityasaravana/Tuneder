//
//  SongViewGuts.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import SwiftUI
import MusicKit
import AVFoundation

struct SongImageView: View {
    var song: Song
    var geometry: GeometryProxy
    var body: some View {
        AsyncImage(url: song.artwork?.url(width: 700, height: 700)) { image in
            image
            
                .resizable()
                .overlay (
                    Rectangle()
                        .fill (
                            LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                           startPoint: .center, endPoint: .bottom)
                        )
                        .clipped()
                )
                .aspectRatio(contentMode: .fill)
            //                .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
            //                .clipped()
            
            
        } placeholder: {
            Color.gray
        }
    }
}

struct SwipeTextView: View {
    var swipeStatus: LikeDislike
    var body: some View {
        if swipeStatus == .like {
            Text("SAVE")
                .font(.headline)
                .padding()
                .cornerRadius(10)
                .foregroundColor(Color.green)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 3.0)
                ).padding(24)
                .rotationEffect(Angle.degrees(-45))
        } else if swipeStatus == .dislike {
            Text("SKIP")
                .font(.headline)
                .padding()
                .cornerRadius(10)
                .foregroundColor(Color.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 3.0)
                ).padding(.top, 45)
                .rotationEffect(Angle.degrees(45))
        }
    }
}
