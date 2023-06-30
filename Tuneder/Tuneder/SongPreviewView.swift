//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/15/23.
//

import SwiftUI
import AVFoundation
import MusadoraKit
import ModernAVPlayer
import RxModernAVPlayer
import RxSwift

/// This view is the tile for each song, with the song's details, album art, and an audio player that plays Apple Music's preview for it.

enum LikeDislike: Int {
    case like, dislike, none
}

struct SongPreviewView: View {
    let musicManager = MusicManager.shared
    @Binding var queue: [Song]
    let player = ModernAVPlayer()
    
    @AppStorage(AppStorageNames.showExplicitContentWarning.name) var showExplicitContentWarning: Bool = true
    @State var translation: CGSize = .zero
    @State var swipeStatus: LikeDislike = .none
    
    var song: Song
    
    @State var lastLikedSong: Song? = nil
    
    func onRemove() {
        queue = Array(queue.dropFirst())
    }
    
    var thresholdPercentage: CGFloat = 0.5
    func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: swipeStatus == .like ? .topLeading : .topTrailing) {
                SongImageView(song: song, geometry: geometry)
                
                SwipeTextView(swipeStatus: swipeStatus)
                VStack(alignment: .leading) {
                    if queue.first == song {
                        if song.contentRating == .explicit {
                            if showExplicitContentWarning {
                                VStack {
                                    Text("This song is rated explicit. You can block explicit content in Settings.").padding(.bottom)
                                    Button("Hide this text") {
                                        showExplicitContentWarning = false
                                    }.bold()
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                .multilineTextAlignment(.center)
                                .font(.caption)
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(song.title)")
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                                
                                if song.contentRating == .explicit {
                                    Image(systemName: "e.square.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            Text(song.artistName)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .bold()
                            Text(song.genreNames.joined(separator: ", "))
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            
                            if player.state == .loaded {
                                player.play()
                            } else if player.state == .paused {
                                player.play()
                            } else if player.state == .playing {
                                player.pause()
                            }
                            print(player.state.rawValue)
                        }) {
                            PlayerButtonView(player: player).font(.system(size: 24))
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .onDisappear {
                player.stop()
            }
            .cornerRadius(20)
            .animation(.interactiveSpring(), value: UUID())
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(Double(translation.width / geometry.size.width) * 25), anchor: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation
                        
                        if (getGesturePercentage(geometry, from: value)) >= thresholdPercentage {
                            swipeStatus = .like
                        } else if getGesturePercentage(geometry, from: value) <= -thresholdPercentage {
                            swipeStatus = .dislike
                        } else {
                            swipeStatus = .none
                        }
                        
                    }.onEnded { value in
                        // determine snap distance > 0.5 aka half the width of the screen
                        if abs(getGesturePercentage(geometry, from: value)) > thresholdPercentage {
                            player.stop()
                            
                            translation = .zero
                            
                            if swipeStatus == .like {
                                lastLikedSong = song
                                
                                Task {
                                    let libraryHandler = MusicLibraryHandler()
                                    libraryHandler.addSong(song.id.rawValue)
                                }
                                
                                Task {
                                    await musicManager.addRelatedSongs(from: lastLikedSong!)
                                }
                            }
                            
                            swipeStatus = .none
                            
                            onRemove()
                        } else {
                            translation = .zero
                        }
                    }
            )
        }
        
        .onAppear {
            let url = song.previewAssets?.first?.url
            let playerItem = AVPlayerItem(url: url ?? URL(fileURLWithPath: Bundle.main.path(forResource: "audioTest", ofType: "m4a")!))
            
            let media = ModernAVPlayerMediaItem(item: playerItem, type: .clip, metadata: .none)
            if swipeStatus == .none {
                player.load(media: media!, autostart: false)
            }
        }
    }
}

struct ButtonView: View {
    var player: ModernAVPlayer
    
    var body: some View {
        VStack {
            switch player.state {
            case .buffering:
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            case .failed:
                Image(systemName: "xmark.diamond.fill")
            case .initialization:
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            case .loaded:
                Image(systemName: "play.fill")
            case .loading:
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            case .paused:
                Image(systemName: "play.fill")
            case .playing:
                Image(systemName: "pause.fill")
            case .stopped:
                Image(systemName: "xmark.diamond.fill")
            case .waitingForNetwork:
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(CGFloat(Int.max))
    }
}

struct SongImageView: View {
    var song: Song
    var geometry: GeometryProxy
    var body: some View {
        AsyncImage(url: song.artwork?.url(width: Int(geometry.size.width), height: Int(geometry.size.height))) { image in
            image
            
                .resizable()
                .overlay (
                    Rectangle()
                        .fill (
                            LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                           startPoint: .center, endPoint: .bottom)
                        )
                        .clipped()
                )
                .aspectRatio(contentMode: .fill)
            //                .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
            //                .clipped()
            
            
        } placeholder: {
            Color.gray
        }
    }
}

struct SwipeTextView: View {
    var swipeStatus: LikeDislike
    var body: some View {
        if swipeStatus == .like {
            Text("SAVE")
                .font(.headline)
                .padding()
                .cornerRadius(10)
                .foregroundColor(Color.green)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 3.0)
                ).padding(24)
                .rotationEffect(Angle.degrees(-45))
        } else if swipeStatus == .dislike {
            Text("SKIP")
                .font(.headline)
                .padding()
                .cornerRadius(10)
                .foregroundColor(Color.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 3.0)
                ).padding(.top, 45)
                .rotationEffect(Angle.degrees(45))
        }
    }
}

extension ModernAVPlayer.State {
    func sysItem() -> UIImage? {
        switch self {
        case .buffering, .loading:
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "icloud.and.arrow.down")
            }
        case .paused:
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "pause.circle")
            }
        case .playing:
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "play.circle")
            }
        case .failed:
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "xmark")
            }
        default:
            return UIImage(systemName: "xmark")
        }
    }
    
}

struct PlayerButtonView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PlayerButtonImage
    var player: ModernAVPlayer
    func makeUIViewController(context: Context) -> PlayerButtonImage {
        let vc = PlayerButtonImage(player: player)
        // Do some configurations here if needed.
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PlayerButtonImage, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}

class PlayerButtonImage: UIViewController {
    // Your player using modern AVPlayer
    var player: ModernAVPlayer
    let imageView = UIImageView()
    
    init(player: ModernAVPlayer) {
        self.player = player
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // Defining the dispose bag
    let disposeBag = DisposeBag()
    
    func set(state: ModernAVPlayer.State) {
        self.imageView.image = state.sysItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.center = self.view.center
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        //imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        // Defining player state reaction
        let state: Observable<ModernAVPlayer.State> = player.rx.state
        state
            .subscribe(onNext: { [weak self] currentState in
                self?.set(state: currentState)
            })
            .disposed(by: disposeBag)
        
        // And further setup of ModernAVPlayer after...
    }
}
