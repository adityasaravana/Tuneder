//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/23/23.
//

import SwiftUI
import MusadoraKit
import LazyViewSwiftUI

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
    
    private func getIndex(song: Song) -> String {
        return String(queue.firstIndex(of: song) ?? 0)
    }
    
    var body: some View {
        ForEach(self.queue.reversed(), id: \.self) { song in
            
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
