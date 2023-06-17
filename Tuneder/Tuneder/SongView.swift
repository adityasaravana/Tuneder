//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import MusicKit
import AVFoundation

enum LikeDislike: Int {
    case like, dislike, none
}

struct SongView: View {
    @State private var player: AVPlayer?
    @State var isPlaying = false
    
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: LikeDislike = .none
    
    var song: Song
    
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
            ZStack(alignment: swipeStatus == .like ? .topLeading : .topTrailing) {
                SongImageView(song: song, geometry: geometry)
                
                SwipeTextView(swipeStatus: swipeStatus)
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(song.title)")
                                .foregroundColor(.white)
                                .font(.title)
                                .bold()
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
                            ButtonView(isPlaying: isPlaying).font(.system(size: 30))
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .cornerRadius(20)
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
                            player?.stop()
                            withAnimation {
                                onRemove(song)
                            }
                            
                            if swipeStatus == .like {
                                DispatchQueue.main.async {
                                    print("SONG LIKED SONG LIKED SONG LIKED SONG LIKED SONG LIKED SONG LIKED SONG LIKED SONG LIKED")
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
