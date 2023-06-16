//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import MusicKit

struct SongView: View {
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: LikeDislike = .none
    
    private var song: Song
    
    private var onRemove: (_ song: Song) -> Void
    
    private var thresholdPercentage: CGFloat = 0.5 // when the song has draged 50% the width of the screen in either direction
    
    private enum LikeDislike: Int {
        case like, dislike, none
    }
    
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
                    AsyncImage(url: song.artwork?.url(width: 700, height: 700)) { image in
                        image
                        
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                            .clipped()
                        
                    } placeholder: {
                        Color.gray
                    }
                    
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
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
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

//struct SongView_Previews: PreviewProvider {
//    var song: Song {
//        do {
//            guard let url = URL(string: "https://api.music.apple.com/v1/me/history/heavy-rotation") else { return }
//              
//            let request = MusicDataRequest(urlRequest: URLRequest(url: url))
//            
//              let response = try await request.response()
//            
//        }
//    }
//    static var previews: some View {
//        SongView(song: song, onRemove: { removedSong in
//            
//        })
//    }
//}
