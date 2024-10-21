//
//  MainView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/29/23.
//

import SwiftUI
import MusicKit
import SwiftfulLoadingIndicators
import Defaults

struct MainView: View {
    @Default(.explicitContentAllowed) var explicitContentAllowed
    @State private var showingHelp = false
    @State private var queue: [Song] = []
    @State private var genreSelection: GenreSelection = .none
    @State private var showingSettings = false
    @Binding var showingErrorScreen: Bool
    @Binding var errorDescription: String
    private let musicManager = MusicManager.shared
    
    fileprivate func reset() {
        withAnimation {
            queue = []
            musicManager.reserve = []
        }
    }
    
    func addRelatedSongs() async {
        var showingErrorScreen = self.showingErrorScreen
        var errorDescription = self.errorDescription
        await musicManager.addChartSongs(genre: genreSelection, failed: &showingErrorScreen, errorDescription: &errorDescription)
        self.showingErrorScreen = showingErrorScreen
        self.errorDescription = errorDescription
    }
    
    var body: some View {
        VStack {
            ZStack {
                if queue.count != 0 && queue.first != nil {
                    SongsView(queue: $queue, showingErrorScreen: $showingErrorScreen, errorDescription: $errorDescription)
                    VStack {
                        HStack {
                            Text("Tuneder".uppercased())
                                .bold()
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            Button("Reset") {
                                reset()
                            }
                        }.padding()
                        Spacer()
                        HStack {
                            VStack {
                                Spacer()
                                Button {
                                    showingHelp = true
                                } label: {
                                    Image(systemName: "questionmark.circle.fill").foregroundColor(.white).padding().background(.ultraThinMaterial, in: Circle())
                                }.alert(isPresented: $showingHelp) {
                                    Alert(title: Text("Instructions"), message: Text("Press the play button to preview a song, swipe right to like it and add it to a new playlist in your library, swipe left to skip it. That's it!"), dismissButton: .default(Text("Awesome")))
                                }
                            }
                            
                            Spacer()
                            VStack {
                                Spacer()
                                Text("Genre").foregroundColor(.white).bold()
                                Picker("Genre", selection: $genreSelection) {
                                    ForEach(GenreSelection.allCases) { genre in
                                        Text(genre.genreData.name)
                                    }
                                }.padding().background(.ultraThinMaterial).cornerRadius(25)
                            }
                            Spacer()
                            VStack {
                                Spacer()
                                Button {
                                    showingSettings = true
                                } label: {
                                    Image(systemName: "gear").foregroundColor(.white).padding().background(.ultraThinMaterial, in: Circle())
                                }
                            }
                        }.padding()
                    }
                } else {
                    VStack {
                        Spacer()
                        LoadingIndicator(animation: .text, size: .large)
                            .foregroundColor(.black)
                            .onAppear {
                                //                                musicManager.testErrorScreen(failed: &showingErrorScreen, errorDescription: &errorDescription)
                                if musicManager.reserve.isEmpty {
                                    Task {
                                        await self.addRelatedSongs()
                                        musicManager.removeDuplicates()
                                        withAnimation {
                                            queue = musicManager.fetch()
                                        }
                                    }
                                } else {
                                    Task {
                                        musicManager.removeDuplicates()
                                        withAnimation {
                                            queue = musicManager.fetch()
                                        }
                                    }
                                }
                            }
                        Spacer()
                        
                        Text("Having issues? Email aditya.saravana@icloud.com").padding(.bottom)
                    }
                }
            }
            
        }
        .sheet(isPresented: $showingSettings) { SettingsView(showing: $showingSettings) }
        .onAppear {
            
            //#if DEBUG
            /// Finding the IDs of genres to add to GenreSelection on debug launch. Replace the search term with a popular artist/name of the genre you want to see added, and add the ID and name in GenreSelection.
            //            Task {
            //                await musicManager.search("grunge")
            //            }
            //#endif
            
        }
        .onChange(of: genreSelection) { _ in
            reset()
        }
        .onChange(of: explicitContentAllowed) { _ in
            reset()
        }
    }
}
