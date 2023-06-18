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
    @State private var searchText = ""
    @State private var queue: MusicItemCollection<Song> = []
    //    @State var lastLikedSongID = ""
    
    @State var musicAccessEnabled = false {
        didSet {
            Defaults[.musicAccessEnabled] = self.musicAccessEnabled
        }
    }
    
    private func getMusic() {
        Task {
            do {
                let request = MusicCatalogChartsRequest(genre: nil, types: [Song.self])
                let response = try await request.response()
                
                queue = response.songCharts.first?.items.reversed().reversed() ?? []
                
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
                                        .padding(.leading)
                                    Spacer()
                                    
                                }
                                Spacer()
                                HStack {
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "questionmark.circle.fill").foregroundColor(.white).padding().background(.ultraThinMaterial, in: Circle())
                                    }
                                    Spacer()
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "gear").foregroundColor(.white).padding().background(.ultraThinMaterial, in: Circle())
                                    }
                                }.padding(.horizontal)
                            }.padding()
                            
                            
//                            Group {
                                SongView(queue: $queue, song: song, onRemove: { removedSong in
                                    
                                    queue = MusicItemCollection(queue.dropLast())
                                })
                                .padding()
                                .frame(width: 380, height: 380)
                                .animation(.spring())
                                
//                            }
                        }
                    } else {
                        LoadingIndicator(animation: .text, size: .large).foregroundColor(.black).onAppear {
                            checkAuthStatus()
                            getMusic()
                        }
                    }
                }
            } else {
                MusicAccessNotEnabledView()
            }
        }
        .onAppear {
            self.musicAccessEnabled = Defaults[.musicAccessEnabled]
            checkAuthStatus()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(musicAccessEnabled: true)
    }
}

