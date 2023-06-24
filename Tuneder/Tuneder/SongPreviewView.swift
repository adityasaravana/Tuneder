//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import AVFoundation
import MusadoraKit


/// This view is the tile for each song, with the song's details, album art, and an audio player that plays Apple Music's preview for it.

enum LikeDislike: Int {
    case like, dislike, none
}

struct SongPreviewView: View {
    //    @Binding var lastLikedSongID: String
    //    @StateObject var bufferStatus: AVPlayerBufferStatusController
    @Binding var queue: [Song]
    @State var player: AVPlayer?
    @State var isPlaying = false
    
    @State var translation: CGSize = .zero
    @State var swipeStatus: LikeDislike = .none
    
    var song: Song
//    var playerIsBuffering: Bool {
//        if let currentItem = self.player?.currentItem {
//            if currentItem.isPlaybackLikelyToKeepUp {
//                return false
//            } else if currentItem.isPlaybackBufferEmpty {
//                return false
//            }  else if currentItem.isPlaybackBufferFull {
//                return true
//            } else {
//                return false
//            }
//        } else {
//            return false
//        }
//    }
    @State var lastLikedSong: Song? = nil
    
    
    
    func onRemove() {
        queue = Array(queue.dropLast())
    }
    
    var thresholdPercentage: CGFloat = 0.5 // when the song has draged 50% the width of the screen in either direction
    
    /// What percentage of our own width have we swipped
    /// - Parameters:
    ///   - geometry: The geometry
    ///   - gesture: The current gesture translation value
    func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    
    func updateRecommendations() {
        /// Right now, the recommendation system of Tuneder gets the last liked song's artist's top songs and top song of similar artists to the queue.
        Task {
            let id = lastLikedSong!.id
            
            var songsToQueue: [Song] = []
            let song = try await MCatalog.song(id: id, fetch: [.artists])
            let songArtistID = song.artists!.first!.id
            let songArtist = try await MCatalog.artist(id: songArtistID, fetch: [.similarArtists, .topSongs])
            
            for song in songArtist.topSongs! {
                print("Recommending Top Songs Of Artist")
                songsToQueue.append(song)
            }
            
            for relatedArtist in songArtist.similarArtists! {
                print("Recommending Top Song From Artist: \(relatedArtist.name)")
                let relatedArtistID = relatedArtist.id
                let relatedArtistData = try await MCatalog.artist(id: relatedArtistID, fetch: [.topSongs])
                if let relatedArtistTopSong = relatedArtistData.topSongs!.first {
                    songsToQueue.append(relatedArtistTopSong)
                }
            }
            
            print("Recommendations done!")
            for song in songsToQueue {
                queue.append(song)
            }
            print("Added recommendations to queue!")
        }
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
                            if isPlaying {
                                player?.pause()
                                
                                isPlaying = false
                            } else {
                                player?.play()
                                isPlaying = true
                            }
                        }) {
                            ButtonView(isPlaying: isPlaying).font(.system(size: 24))
                        }
                        .padding()
                    }
                }
                .padding()
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
                            player?.stop()
                            withAnimation {
                                onRemove()
                            }
                            
                            if swipeStatus == .like {
                                DispatchQueue.main.async {
                                    print("SONG LIKED SONG LIKED SONG LIKED SONG LIKED SONG LIKED SONG LIKED SONG LIKED SONG LIKED")
                                    
                                    let libraryHandler = MusicLibraryHandler()
                                    libraryHandler.addSong(song.id.rawValue)
                                    lastLikedSong = song
                                    updateRecommendations()
                                }
                            }
                        } else {
                            translation = .zero
                        }
                    }
            )
        }
        
        .onAppear {
            let url = song.previewAssets?.first?.url
            let playerItem = AVPlayerItem(url: url ?? URL(fileURLWithPath: Bundle.main.path(forResource: "audioTest", ofType: "m4a")!))
            
            player = AVPlayer(playerItem: playerItem)
            
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
    var isPlaying: Bool
    var body: some View {
        VStack {
            if isPlaying {
                Image(systemName: "pause.fill")
            } else {
                Image(systemName: "play.fill")
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
