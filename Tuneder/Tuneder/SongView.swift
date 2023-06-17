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
    @State var audioPlayer: AVAudioPlayer!
    @State var progress: CGFloat = 0.0
    @State var playing: Bool = false
    @State var duration: Double = 0.0
    @State var formattedDuration: String = ""
    @State var formattedProgress: String = "00:00"

    var url: URL {
        return song.previewAssets?.first?.url ?? URL(fileURLWithPath: Bundle.main.path(forResource: "audioTest", ofType: "m4a")!)
    }
    
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
                
                VStack {

                    HStack {
                        Text(formattedProgress)
                            .font(.caption.monospacedDigit())

                        // this is a dynamic length progress bar
                        GeometryReader { gr in
                            Capsule()
                                .stroke(Color.blue, lineWidth: 2)
                                .background(
                                    Capsule()
                                        .foregroundColor(Color.accentColor)
                                        .frame(width: gr.size.width * progress, height: 8), alignment: .leading)
                        }
                        .frame( height: 8)

                        Text(formattedDuration)
                            .font(.caption.monospacedDigit())
                    }
                    .padding()
                    .frame(height: 50, alignment: .center)
                    .accessibilityElement(children: .ignore)
                    .accessibility(identifier: "audio player")
                    .accessibilityLabel(playing ? Text("Playing at ") : Text("Duration"))
                    .accessibilityValue(Text("\(formattedProgress)"))

                    //             the control buttons
                    HStack(alignment: .center, spacing: 20) {
                        Spacer()
                        Button(action: {
                            let decrease = self.audioPlayer.currentTime - 15
                            if decrease < 0.0 {
                                self.audioPlayer.currentTime = 0.0
                            } else {
                                self.audioPlayer.currentTime -= 15
                            }
                        }) {
                            Image(systemName: "gobackward.15")
                                .font(.title)
                                .imageScale(.medium)
                        }

                        Button(action: {
                            if audioPlayer.isPlaying {
                                playing = false
                                self.audioPlayer.pause()
                            } else if !audioPlayer.isPlaying {
                                playing = true
                                self.audioPlayer.play()
                            }
                        }) {
                            Image(systemName: playing ?
                                  "pause.circle.fill" : "play.circle.fill")
                                .font(.title)
                                .imageScale(.large)
                        }

                        Button(action: {
                            let increase = self.audioPlayer.currentTime + 15
                            if increase < self.audioPlayer.duration {
                                self.audioPlayer.currentTime = increase
                            } else {
                                // give the user the chance to hear the end if he wishes
                                self.audioPlayer.currentTime = duration
                            }
                        }) {
                            Image(systemName: "goforward.15")
                                .font(.title)
                                .imageScale(.medium)
                        }
                        Spacer()
                    }
                }
                .foregroundColor(.accentColor)
                .onAppear {
                    initialiseAudioPlayer(url: url)
                    print("---------------------------------------------------------")
                    print("PREVIEW ASSETS ---")
                    print(song.previewAssets?.description ?? "nil")
                }
                
                
                
            }
            .modifier(SwipeableCard(translation: translation, geometry: geometry))
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
                            audioPlayer.stop()
                            onRemove(song)
                        } else {
                            translation = .zero
                        }
                    }
            )
        }
    }
}
