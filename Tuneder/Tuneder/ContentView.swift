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
        .onAppear {
            
#if DEBUG
            /// Finding the IDs of genres to add to GenreSelection.
            Task {
                await musicManager.search("grunge")
            }
#endif
            
        }

        .onChange(of: genreSelection) { newValue in
            queue = []
            musicManager.reserve = []
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
