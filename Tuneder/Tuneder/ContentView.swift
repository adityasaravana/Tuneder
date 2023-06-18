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

struct ContentView: View {
    @State private var searchText = ""
    @State private var searchResults: MusicItemCollection<Song> = []
    
    
    
    private func searchMusic() {
        Task {
            do {
                let request = MusicCatalogChartsRequest(genre: nil, types: [Song.self])
                let response = try await request.response()
                
                searchResults = response.songCharts.first?.items.reversed().reversed() ?? []
                
            } catch {
                print("Error searching for music: \(error.localizedDescription)")
            }
        }
    }
    
    private func getCardWidth(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        let offset: CGFloat = CGFloat(searchResults.count - 1 - id) * 10
        return geometry.size.width - offset
    }
    
    private func getCardOffset(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        return  CGFloat(searchResults.count - 1 - id) * 10
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                if searchResults.count != 0 {
                    ForEach(self.searchResults, id: \.self) { song in
//                        SongBackgroundView(song: song)
                        
                        
                        Group {
                            SongView(song: song, onRemove: { removedSong in
                                // Remove that song from our array
//                                self.searchResults.removeAll { $0.id == removedSong.id }
                                
                                searchResults = MusicItemCollection(searchResults.dropLast())
                            })
                            .padding()
                            .frame(height: 400)
                            .animation(.spring())
                            
                        }
                    }
                } else {
//                    Text("End Of List")
                    LoadingIndicator(animation: .text, size: .large).foregroundColor(.black)
                }
            }
            
        }
        .onAppear {
            SKCloudServiceController.requestAuthorization {(status: SKCloudServiceAuthorizationStatus) in
                //                switch status {
                //                case .denied, .restricted: disableAppleMusicBasedFeatures()
                //                case .authorized: enableAppleMusicBasedFeatures()
                //                default: break
                //                }
            }
            searchMusic()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

