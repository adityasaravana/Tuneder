//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/23/23.
//

import SwiftUI
import MusadoraKit

struct SongsView: View {
    @Binding var queue: [Song]
    @Binding var genreSelection: GenreSelection
    
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
    
    var body: some View {
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
            
            
            SongPreviewView(queue: $queue, song: song)
            .padding()
            .frame(width: 380, height: 380)
            .animation(.spring(), value: UUID())
        }
    }
}
