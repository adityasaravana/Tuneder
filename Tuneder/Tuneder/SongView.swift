//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import MusicKit

enum LikeDislike: Int {
    case like, dislike, none
}

struct SongView: View {
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: LikeDislike = .none
    
    private var song: Song
    
    private var onRemove: (_ song: Song) -> Void
    
    private var thresholdPercentage: CGFloat = 0.5 // when the song has draged 50% the width of the screen in either direction
    
    init(song: Song, onRemove: @escaping (_ song: Song) -> Void) {
        self.song = song
        self.onRemove = onRemove
    }
    
    /// What percentage of our own width have we swipped
    /// - Parameters:
    ///   - geometry: The geometry
    ///   - gesture: The current gesture translation value
    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                ZStack(alignment: swipeStatus == .like ? .topLeading : .topTrailing) {
                    SongImageView(song: song, geometry: geometry)
                    
                    SwipeTextView(swipeStatus: swipeStatus)
                }
                
                SongInfoView(song: song)
            }
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            //            .shadow(radius: 12)
            .animation(.interactiveSpring())
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(Double(translation.width / geometry.size.width) * 25), anchor: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation
                        
                        if (getGesturePercentage(geometry, from: value)) >= thresholdPercentage {
                            swipeStatus = .like
                        } else if getGesturePercentage(geometry, from: value) <= -thresholdPercentage {
                            swipeStatus = .dislike
                        } else {
                            swipeStatus = .none
                        }
                        
                    }.onEnded { value in
                        // determine snap distance > 0.5 aka half the width of the screen
                        if abs(getGesturePercentage(geometry, from: value)) > thresholdPercentage {
                            
                            onRemove(song)
                        } else {
                            translation = .zero
                        }
                    }
            )
        }
    }
}

struct SongInfoView: View {
    var song: Song
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(song.title)")
                    .font(.title)
                    .bold()
                Text(song.artistName)
                    .font(.subheadline)
                    .bold()
                Text("text")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct SongImageView: View {
    var song: Song
    var geometry: GeometryProxy
    var body: some View {
        AsyncImage(url: song.artwork?.url(width: 700, height: 700)) { image in
            image
            
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                .clipped()
            
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
