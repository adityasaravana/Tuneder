//
//  SongBackgroundView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import SwiftUI
import MusicKit
import ColorKit

struct SongBackgroundView: View {
    var song: Song
    @State var colors: [Color] = []
//    func getColorsFromArtwork() -> [Color] {
//        Task {
//            let previewcolors: [Color] = [.red, .yellow, .cyan, .blue, .white]
//            do {
//                guard let artworkURL = song.artwork?.url(width: 640, height: 640) else { return previewcolors }
//
//                let (imageData, _) = try URLSession.shared.data(from: artworkURL)
//
//                guard let image = UIImage(data: imageData) else { return previewcolors }
//
//                return try image.dominantColors().map { Color(uiColor: $0) }
//            } catch {
//                print(error)
//                return previewcolors
//            }
//        }
//    }
//
    
    
    
    var body: some View {
//        FloatingCloudsView(colors: colors).onAppear {
//            Task {
//                do {
//                    guard let artworkURL = song.artwork?.url(width: 640, height: 640) else { return }
//
//                    let (imageData, _) = try await URLSession.shared.data(from: artworkURL)
//
//                    guard let image = UIImage(data: imageData) else { return }
//
//                    self.colors = try image.dominantColors().map { Color(uiColor: $0) }
//                } catch {
//                    print(error)
//                }
//            }
//        }
        AnimatedBackground(colors: colors).task {
            do {
                guard let artworkURL = song.artwork?.url(width: 640, height: 640) else { return }
                
                let (imageData, _) = try await URLSession.shared.data(from: artworkURL)
                
                guard let image = UIImage(data: imageData) else { return }

                self.colors = try image.dominantColors().map { Color(uiColor: $0) }
            } catch {
                print(error)
            }
        }
            
    }
}

struct AnimatedBackground: View {
    @State private var start = UnitPoint(x: 0, y: 0)
    @State private var end = UnitPoint(x: 0, y: 0)
    
    private let timer = Timer
        .publish(every: 1, on: .main, in: .default)
        .autoconnect()
    
    var colors: [Color]
    
    var body: some View {
        LinearGradient(colors: colors, startPoint: start, endPoint: end)
            .blur(radius: 200)
            .onReceive(timer) { _ in
                withAnimation(Animation.easeInOut(duration: 30).repeatForever()) {
                    start = randomPoint()
                    end = randomPoint()
                    start = randomPoint()
                    end = randomPoint()
                }
            }
    }
    
    private func randomPoint() -> UnitPoint {
        let x = CGFloat.random(in: -1...1)
        let y = CGFloat.random(in: -1...1)
        
        return UnitPoint(x: x, y: y)
    }
}
