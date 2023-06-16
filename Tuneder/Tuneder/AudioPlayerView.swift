////
////  AudioPlayerView.swift
////  Tuneder
////
////  Created by Aditya Saravana on 6/16/23.
////
//
//import SwiftUI
//import AVKit
//import MusicKit
//
//struct AudioPlayerView: View {
//    @State var audioPlayer: AVAudioPlayer!
//    @State var progress: CGFloat = 0.0
//    @State private var playing: Bool = false
//    @State var duration: Double = 0.0
//    @State var formattedDuration: String = ""
//    @State var formattedProgress: String = "00:00"
//
//    var url: URL
//    var body: some View {
//        VStack {
//
//            HStack {
//                Text(formattedProgress)
//                    .font(.caption.monospacedDigit())
//
//                // this is a dynamic length progress bar
//                GeometryReader { gr in
//                    Capsule()
//                        .stroke(Color.blue, lineWidth: 2)
//                        .background(
//                            Capsule()
//                                .foregroundColor(Color.accentColor)
//                                .frame(width: gr.size.width * progress, height: 8), alignment: .leading)
//                }
//                .frame( height: 8)
//
//                Text(formattedDuration)
//                    .font(.caption.monospacedDigit())
//            }
//            .padding()
//            .frame(height: 50, alignment: .center)
//            .accessibilityElement(children: .ignore)
//            .accessibility(identifier: "audio player")
//            .accessibilityLabel(playing ? Text("Playing at ") : Text("Duration"))
//            .accessibilityValue(Text("\(formattedProgress)"))
//
//            //             the control buttons
//            HStack(alignment: .center, spacing: 20) {
//                Spacer()
//                Button(action: {
//                    let decrease = self.audioPlayer.currentTime - 15
//                    if decrease < 0.0 {
//                        self.audioPlayer.currentTime = 0.0
//                    } else {
//                        self.audioPlayer.currentTime -= 15
//                    }
//                }) {
//                    Image(systemName: "gobackward.15")
//                        .font(.title)
//                        .imageScale(.medium)
//                }
//
//                Button(action: {
//                    if audioPlayer.isPlaying {
//                        playing = false
//                        self.audioPlayer.pause()
//                    } else if !audioPlayer.isPlaying {
//                        playing = true
//                        self.audioPlayer.play()
//                    }
//                }) {
//                    Image(systemName: playing ?
//                          "pause.circle.fill" : "play.circle.fill")
//                        .font(.title)
//                        .imageScale(.large)
//                }
//
//                Button(action: {
//                    let increase = self.audioPlayer.currentTime + 15
//                    if increase < self.audioPlayer.duration {
//                        self.audioPlayer.currentTime = increase
//                    } else {
//                        // give the user the chance to hear the end if he wishes
//                        self.audioPlayer.currentTime = duration
//                    }
//                }) {
//                    Image(systemName: "goforward.15")
//                        .font(.title)
//                        .imageScale(.medium)
//                }
//                Spacer()
//            }
//        }
//        .foregroundColor(.accentColor)
//        .onAppear {
//            initialiseAudioPlayer(url: url)
//        }
//    }
//
//    func initialiseAudioPlayer(url: URL) {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior = [ .pad ]
//
//        // init audioPlayer
//        self.audioPlayer = try! AVAudioPlayer(contentsOf: url)
//        self.audioPlayer.prepareToPlay()
//
//        //I need both! The formattedDuration is the string to display and duration is used when forwarding
//        formattedDuration = formatter.string(from: TimeInterval(self.audioPlayer.duration))!
//        duration = self.audioPlayer.duration
//
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            if !audioPlayer.isPlaying {
//                playing = false
//            }
//            progress = CGFloat(audioPlayer.currentTime / audioPlayer.duration)
//            formattedProgress = formatter.string(from: TimeInterval(self.audioPlayer.currentTime))!
//        }
//    }
//}
//
//struct AudioPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioPlayerView(url: URL(fileURLWithPath: Bundle.main.path(forResource: "audioTest", ofType: "m4a")!))
//            .previewLayout(PreviewLayout.fixed(width: 500, height: 300))
//            .previewDisplayName("Default preview")
//        AudioPlayerView(url: URL(fileURLWithPath: Bundle.main.path(forResource: "audioTest", ofType: "m4a")!))
//            .previewLayout(PreviewLayout.fixed(width: 500, height: 300))
//            .environment(\.sizeCategory, .accessibilityExtraLarge)
//    }
//}
