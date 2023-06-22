//
//  ContentView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import MusicKit
import MusadoraKit
import StoreKit
import SwiftfulLoadingIndicators
import Defaults




struct ContentView: View {
    @State private var queue: MusicItemCollection<Song> = []
    //    @State var lastLikedSongID = ""
    @State var genreSelection: GenreSelection = .none
    
    
    @State var musicAccessEnabled = false {
        didSet {
            Defaults[.musicAccessEnabled] = self.musicAccessEnabled
        }
    }
    
    @State var settingsPresented = false
    
    
    
    private func getMusic() {
        Task {
            do {
                let request = await MusicCatalogChartsRequest(genre: genreSelection.genreData.catalogData(), types: [Song.self])

                let response = try await request.response()

                queue = response.songCharts.first?.items.reversed().reversed() ?? []
                
                /// This code fetches the genres and ids of songs that that you enter in searchTerm, useful for adding more genres (See GenreSelection)
                
//                let searchTerm = "Taylor Swift"
//
//                let songSearch = try await MCatalog.search(for: searchTerm, types: [.songs], limit: 3)
//                for song in songSearch.songs {
//                    let songDetailed = try await MCatalog.song(id: song.id, fetch: [.genres])
//
//                    for genre in songDetailed.genres! {
//                        print("⚠️⚠️⚠️⚠️⚠️⚠️ GENRE NAME: \(genre.name), ID: \(genre.id) ⚠️⚠️⚠️⚠️⚠️⚠️")
//                    }
//                }
                
            } catch {
                print("Error searching for music: \(error.localizedDescription)")
            }
        }
    }
    
    private func getCardWidth(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        let offset: CGFloat = CGFloat(queue.count - 1 - id) * 10
        return geometry.size.width - offset
    }
    
    private func getCardOffset(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        return  CGFloat(queue.count - 1 - id) * 10
    }
    
    func checkAuthStatus() {
        SKCloudServiceController.requestAuthorization {(status: SKCloudServiceAuthorizationStatus) in
            if status == .authorized {
                musicAccessEnabled = true
            } else {
                musicAccessEnabled = false
            }
        }
    }
    
    var body: some View {
        VStack {
            if musicAccessEnabled {
                ZStack {
                    if queue.count != 0 {
                        ForEach(self.queue, id: \.self) { song in
                            SongBackgroundView(song: song)
                            
                            VStack {
                                HStack {
                                    Text("Tuneder".uppercased())
                                        .bold()
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        
                                    Spacer()
                                    Button("Reset") {
                                        withAnimation {
                                            genreSelection = .none
                                            getMusic()
                                        }
                                    }
                                }.padding(.horizontal)
                                Spacer()
                               
                                
                                
#warning("TODO: These commented-out views are buttons that open a Settings view and a tutorial. As of right now, the settings view stores its values just fine (see Defaults.swift), but I haven't implemented anything to actually not show explicit songs and content when you flip the switch in settings, and haven't got any idea how to make a tutorial. Help would be greatly appreciated.")
                                //                                HStack {
                                //                                    Button {
                                //
                                //                                    } label: {
                                //                                        Image(systemName: "questionmark.circle.fill").foregroundColor(.white).padding().background(.ultraThinMaterial, in: Circle())
                                //                                    }
                                //                                    Spacer()
                                //                                    Button {
                                //                                        settingsPresented = true
                                //                                    } label: {
                                //                                        Image(systemName: "gear").foregroundColor(.white).padding().background(.ultraThinMaterial, in: Circle())
                                //                                    }
                                //                                }.padding(.horizontal)
                                
                                
                                
                                
                                
                            }.padding()
                            
                            
                            //                            Group {
                            SongView(queue: $queue, song: song, onRemove: { removedSong in
                                queue = MusicItemCollection(queue.dropLast())
                            })
                            .padding()
                            .frame(width: 380, height: 380)
                            .animation(.spring(), value: UUID())
                            
                            //                            }
                        }
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
                        LoadingIndicator(animation: .text, size: .large).foregroundColor(.black).onAppear {
                            checkAuthStatus()
                            //
                        }
                    }
                }
            } else {
                MusicAccessNotEnabledView()
            }
        }
        .onChange(of: genreSelection) { newValue in
            queue = []
            getMusic()
        }
        .onAppear {
            self.musicAccessEnabled = Defaults[.musicAccessEnabled]
            checkAuthStatus()
            getMusic()
        }
        .sheet(isPresented: $settingsPresented) {
            SettingsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(musicAccessEnabled: true)
    }
}

