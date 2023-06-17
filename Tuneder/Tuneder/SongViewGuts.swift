//
//  SongViewGuts.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import SwiftUI
import MusicKit
import AVFoundation

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
                Text(song.genreNames.joined(separator: ", "))
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

struct SwipeableCard: ViewModifier {
    var translation: CGSize
    var geometry: GeometryProxy
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            //            .shadow(radius: 12)
            .animation(.interactiveSpring())
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(Double(translation.width / geometry.size.width) * 25), anchor: .bottom)
    }
}

extension SongView {
    func initialiseAudioPlayer(url: URL) {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]

        // init audioPlayer
        self.audioPlayer = try! AVAudioPlayer(contentsOf: url)
        self.audioPlayer.prepareToPlay()

        //I need both! The formattedDuration is the string to display and duration is used when forwarding
        formattedDuration = formatter.string(from: TimeInterval(self.audioPlayer.duration))!
        duration = self.audioPlayer.duration

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if !audioPlayer.isPlaying {
                playing = false
            }
            progress = CGFloat(audioPlayer.currentTime / audioPlayer.duration)
            formattedProgress = formatter.string(from: TimeInterval(self.audioPlayer.currentTime))!
        }
    }
}
