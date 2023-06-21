//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import MusicKit
import AVFoundation
import MusadoraKit


/// This view is the tile for each song, with the song's details, album art, and an audio player that plays Apple Music's preview for it.

enum LikeDislike: Int {
    case like, dislike, none
}

struct SongView: View {
    //    @Binding var lastLikedSongID: String
    @Binding var queue: [Song]
    @State var player: AVPlayer?
    @State var isPlaying = false
    
    @State var translation: CGSize = .zero
    @State var swipeStatus: LikeDislike = .none
    
    var song: Song
    @State var lastLikedSong: Song? = nil
    
    var onRemove: (_ song: Song) -> Void
    
    var thresholdPercentage: CGFloat = 0.5 // when the song has draged 50% the width of the screen in either direction
    
    /// What percentage of our own width have we swipped
    /// - Parameters:
    ///   - geometry: The geometry
    ///   - gesture: The current gesture translation value
    func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    
    func updateRecommendations() {
        #warning("TODO: This is the recommendation system as of right now, and there are serious flaws. An actual recommendation system would be nice, or a way to get similar songs.")
        Task {
            let id = lastLikedSong!.id
            
            let song = try await MCatalog.song(id: id, fetch: [.artists])
            
            let artistID = song.artists!.first!.id
            
            let artist = try await MCatalog.artist(id: artistID, fetch: [.similarArtists, .topSongs])
            
            let relatedArtistID = artist.similarArtists!.first!.id
            
            let relatedArtist = try await MCatalog.artist(id: relatedArtistID, fetch: [.topSongs])
            
            var songsToQueue = artist.topSongs
            songsToQueue! += relatedArtist.topSongs!
            
            #warning("TODO: For some reason, the += operator on MusicItemCollection acts more like =. It just replaces the original array with the songs it was supposed to add.")
            queue += songsToQueue!
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
                                onRemove(song)
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

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(isPlaying: false)
        ButtonView(isPlaying: true)
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
