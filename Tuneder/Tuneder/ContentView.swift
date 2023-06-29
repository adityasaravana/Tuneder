//
//  ContentView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import SwiftfulLoadingIndicators
import Defaults
import MusicKit

struct ContentView: View {
    @State private var queue: [Song] = []
    @State var genreSelection: GenreSelection = .none
    
    let musicManager = MusicManager.shared
    
    //    private func getCardWidth(_ geometry: GeometryProxy, id: Int) -> CGFloat {
    //        let offset: CGFloat = CGFloat(queue.count - 1 - id) * 10
    //        return geometry.size.width - offset
    //    }
    //
    //    private func getCardOffset(_ geometry: GeometryProxy, id: Int) -> CGFloat {
    //        return  CGFloat(queue.count - 1 - id) * 10
    //    }
    
    var body: some View {
        VStack {
            
            ZStack {
                if queue.count != 0 {
                    SongsView(queue: $queue, genreSelection: $genreSelection)
                    VStack {
                        Spacer()
                        VStack {
                            Text("Genre Preference").foregroundColor(.white).bold()
                            Picker("Genre", selection: $genreSelection) {
                                ForEach(GenreSelection.allCases) { genre in
                                    Text(genre.genreData.name)
                                }
                            }.padding().background(.ultraThinMaterial).cornerRadius(25)
                        }
                    }
                } else {
                    LoadingIndicator(animation: .text, size: .large)
                        .foregroundColor(.black)
                        .onAppear {
                            if musicManager.reserve.isEmpty {
                                Task {
                                    await musicManager.addChartSongs(genre: genreSelection)
                                    musicManager.removeDuplicates()
                                    withAnimation {
                                        queue = musicManager.fetch()
                                    }
                                }
                            } else {
                                musicManager.removeDuplicates()
                                withAnimation {
                                    queue = musicManager.fetch()
                                }
                            }
                        }
                }
            }
        }
    }
//    .onChange(of: genreSelection) { newValue in
//        queue = []
//    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
