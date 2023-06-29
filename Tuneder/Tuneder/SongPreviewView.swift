//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import AVFoundation
import MusadoraKit
import ModernAVPlayer
import AudioKit

/// This view is the tile for each song, with the song's details, album art, and an audio player that plays Apple Music's preview for it.

enum LikeDislike: Int {
    case like, dislike, none
}

struct SongPreviewView: View {
    @State var recommendationRequests = 0
    
    @Binding var queue: [Song]
    @State var player = ModernAVPlayer()
    
    @State var translation: CGSize = .zero
    @State var swipeStatus: LikeDislike = .none
    
    var song: Song
    
    @State var lastLikedSong: Song? = nil
    
    
    func onRemove() {
        queue = Array(queue.dropFirst())
    }
    
    var thresholdPercentage: CGFloat = 0.5
    func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    
    func updateRecommendations() {
        /// Right now, the recommendation system of Tuneder gets the last liked song's artist's top songs and top song of similar artists to the queue.
        
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: swipeStatus == .like ? .topLeading : .topTrailing) {
                SongImageView(song: song, geometry: geometry)
                
                SwipeTextView(swipeStatus: swipeStatus)
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(song.title)")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                                
                                if song.contentRating == .explicit {
                                    Image(systemName: "e.square.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            Text(song.artistName)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .bold()
                            Text(song.genreNames.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        Button(action: {
                            
                            if player.state == .loaded {
                                player.play()
                            } else if player.state == .paused {
                                player.play()
                            } else if player.state == .playing {
                                player.pause()
                            }
                            print(player.state.rawValue)
                        }) {
                            ButtonView(player: player).font(.system(size: 24))
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .onDisappear {
                player.stop()
            }
            .cornerRadius(20)
            .animation(.interactiveSpring(), value: UUID())
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
                            player.stop()
                            
                            
                            if swipeStatus == .like {
                                lastLikedSong = song
                                
                                Task {
                                    let libraryHandler = MusicLibraryHandler()
                                    libraryHandler.addSong(song.id.rawValue)
                                }
                                
                                if recommendationRequests <= 2 {
                                    updateRecommendations()
                                }
                            }
                            
                            onRemove()
                        } else {
                            translation = .zero
                        }
                    }
            )
        }
        
        .onAppear {
            let url = song.previewAssets?.first?.url
            let playerItem = AVPlayerItem(url: url ?? URL(fileURLWithPath: Bundle.main.path(forResource: "audioTest", ofType: "m4a")!))
            
//            player = AVPlayer(playerItem: playerItem)
            let media = ModernAVPlayerMediaItem(item: playerItem, type: .clip, metadata: .none)
            if swipeStatus == .none {
                player.load(media: media!, autostart: false)
            }
        }
    }
}

struct PlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let playerLayer = AVPlayerLayer(player: player)
        let view = UIView(frame: .zero)
        view.layer.addSublayer(playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer else { return }
        playerLayer.player = player
    }
}

struct ButtonView: View {
    var player: ModernAVPlayer
    
    var body: some View {
        VStack {
            switch player.state {
                case .buffering:
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                case .failed:
                    Image(systemName: "xmark.diamond.fill")
                case .initialization:
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                case .loaded:
                    Image(systemName: "play.fill")
                case .loading:
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                case .paused:
                    Image(systemName: "play.fill")
                case .playing:
                    Image(systemName: "pause.fill")
                case .stopped:
                    Image(systemName: "xmark.diamond.fill")
                case .waitingForNetwork:
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(CGFloat(Int.max))
    }
}

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
