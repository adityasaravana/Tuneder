//
//  ContentView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import MusicKit
import StoreKit

struct ContentView: View {
    @State private var searchText = ""
    @State private var searchResults: [Song] = []
    
    
    
    private func searchMusic() {
        Task {
            do {
                var request = MusicLibraryRequest<Song>()
                request.filter(text: "taylor swift")
                
                let response = try await request.response()
                                
                let reversedArray = response.items.reversed()
                searchResults = reversedArray.reversed()
                
                //                searchResults = try await request.response().items
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
//                        Rectangle()
//                            .fill(song.backgroundColorSwiftUI.gradient)
//                            .edgesIgnoringSafeArea(.all)
//
//                        Rectangle()
//                            .fill(.ultraThinMaterial)
//                            .edgesIgnoringSafeArea(.all)
                        SongBackgroundView(song: song)
                        
                        VStack {
//                            Text("TUNEDER").bold().font(.largeTitle).foregroundColor(.white).padding()
                            Spacer()
                        }
                        
                        Group {
                            // Range Operator
                            
                            
                            SongView(song: song, onRemove: { removedSong in
                                // Remove that song from our array
                                self.searchResults.removeAll { $0.id == removedSong.id }
                            })
                            .padding()
                            .frame(height: 400)
                            .animation(.spring())
                            
                        }
                    }
                } else {
                    Text("End Of List")
                }
            }
            
        }.onAppear {
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

