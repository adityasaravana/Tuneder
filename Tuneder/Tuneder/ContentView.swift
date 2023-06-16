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
                
                print("RESPONSE FROM MUSICKIT: \(response.description)")
                print(response.debugDescription)
                print(response.items.randomElement()!.artistName)
                
                
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
        ZStack {
            ForEach(self.searchResults, id: \.self) { song in
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

//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("Hello, World!")
//        }
//    }
//}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
