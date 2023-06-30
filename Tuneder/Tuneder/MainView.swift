//
//  MainView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/29/23.
//

import SwiftUI
import MusicKit
import SwiftfulLoadingIndicators

struct MainView: View {
    @AppStorage(AppStorageNames.explicitContentAllowed.name) var explicitContentAllowed = true
    @State private var queue: [Song] = []
    @State private var genreSelection: GenreSelection = .none
    @State private var showingSettings = false
    private let musicManager = MusicManager.shared
    
    fileprivate func reset() {
        withAnimation {
            queue = []
            musicManager.reserve = []
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                if queue.count != 0 && queue.first != nil {
                    SongsView(queue: $queue)
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
                            Button {
                                
                            } label: {
                                Image(systemName: "questionmark.circle.fill").foregroundColor(.white).padding().background(.ultraThinMaterial, in: Circle())
                            }
                            Spacer()
                            VStack {
                                Text("Genre Preference").foregroundColor(.white).bold()
                                Picker("Genre", selection: $genreSelection) {
                                    ForEach(GenreSelection.allCases) { genre in
                                        Text(genre.genreData.name)
                                    }
                                }.padding().background(.ultraThinMaterial).cornerRadius(25)
                            }
                            Spacer()
                            Button {
                                showingSettings = true
                            } label: {
                                Image(systemName: "gear").foregroundColor(.white).padding().background(.ultraThinMaterial, in: Circle())
                            }
                        }.padding()
                        
                    }
                } else {
                    VStack {
                        Spacer()
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
                        Spacer()
                        Text("Having issues? Email aditya.saravana@icloud.com").padding(.bottom)
                    }
                }
            }
            
        }
        .sheet(isPresented: $showingSettings) { SettingsView() }
        .onAppear {
            
#if DEBUG
            /// Finding the IDs of genres to add to GenreSelection.
            Task {
                await musicManager.search("grunge")
            }
#endif
            
        }
        .onChange(of: genreSelection) { _ in
            reset()
        }
        .onChange(of: explicitContentAllowed) { _ in
            reset()
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
