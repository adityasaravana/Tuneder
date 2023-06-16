//
//  FloatingClouds.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import SwiftUI

func withOptionalAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    if UIAccessibility.isReduceMotionEnabled {
        return try body()
    } else {
        return try withAnimation(animation, body)
    }
}

struct FloatingCloudsView: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.colorScheme) var scheme
    var testReduceTransparency = false
    var testDifferentiateWithoutColor = false
    
    var colors: [Color]
    
    var body: some View {
        if differentiateWithoutColor || testDifferentiateWithoutColor {
            Theme.differentiateWithoutColorBackground(forScheme: scheme)
                .edgesIgnoringSafeArea(.all)
        } else {
            if reduceTransparency || testReduceTransparency {
                LinearNonTransparency(colors: colors).edgesIgnoringSafeArea(.all)
            } else {
                FloatingClouds(colors: colors).edgesIgnoringSafeArea(.all)
            }
        }
    }
}

class CloudProvider: ObservableObject {
    let offset: CGSize
    let frameHeightRatio: CGFloat
    
    init() {
        frameHeightRatio = CGFloat.random(in: 0.7 ..< 1.4)
        offset = CGSize(width: CGFloat.random(in: -150 ..< 150),
                        height: CGFloat.random(in: -150 ..< 150))
    }
}

struct LinearNonTransparency: View {
    @Environment(\.colorScheme) var scheme
    var colors: [Color]
    var gradient: Gradient {
        Gradient(colors: [Theme(colors: colors).ellipsesTopLeading(forScheme: scheme), Theme(colors: colors).ellipsesTopTrailing(forScheme: scheme)])
    }
    
    var body: some View {
        LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct Cloud: View {
    @StateObject var provider = CloudProvider()
    @State var move = false
    let proxy: GeometryProxy
    let color: Color
    let rotationStart: Double
    let duration: Double
    let alignment: Alignment
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(height: proxy.size.height /  provider.frameHeightRatio)
            .offset(provider.offset)
            .rotationEffect(.init(degrees: move ? rotationStart : rotationStart + 360) )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .opacity(0.8)
            .onAppear {
                withOptionalAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    move.toggle()
                }
            }
    }
}

struct FloatingClouds: View {
    @Environment(\.colorScheme) var scheme
    let blur: CGFloat = 60
    var colors: [Color]
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Theme(colors: colors).generalBackground
                ZStack {
                    Cloud(proxy: proxy,
                          color: Theme(colors: colors).ellipsesBottomTrailing(forScheme: scheme),
                          rotationStart: 0,
                          duration: 60,
                          alignment: .bottomTrailing)
                    Cloud(proxy: proxy,
                          color: Theme(colors: colors).ellipsesTopTrailing(forScheme: scheme),
                          rotationStart: 240,
                          duration: 50,
                          alignment: .topTrailing)
                    Cloud(proxy: proxy,
                          color: Theme(colors: colors).ellipsesBottomLeading(forScheme: scheme),
                          rotationStart: 120,
                          duration: 80,
                          alignment: .bottomLeading)
                    Cloud(proxy: proxy,
                          color: Theme(colors: colors).ellipsesTopLeading(forScheme: scheme),
                          rotationStart: 180,
                          duration: 70,
                          alignment: .topLeading)
                    Cloud(proxy: proxy,
                          color: colors[4],
                          rotationStart: 180,
                          duration: 70,
                          alignment: .bottomLeading)
                }
                .blur(radius: blur)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct Theme {
    var colors: [Color]
    
    static func differentiateWithoutColorBackground(forScheme scheme: ColorScheme) -> Color {
        let any = Color(white: 0.95)
        let dark = Color(white: 0.2)
        switch scheme {
        case .light:
            return any
        case .dark:
            return dark
        @unknown default:
            return any
        }
    }
    
    
    var generalBackground: Color {
        let c = colors[0]
        return c
    }
    
    func ellipsesTopLeading(forScheme scheme: ColorScheme) -> Color {
//        let any = Color(red: 0.039, green: 0.388, blue: 0.502, opacity: 0.81)
//        let dark = Color(red: 0.000, green: 0.176, blue: 0.216, opacity: 80.0)
//        switch scheme {
//        case .light:
//            return any
//        case .dark:
//            return dark
//        @unknown default:
//            return any
//        }
        return colors[1]
    }
    
    func ellipsesTopTrailing(forScheme scheme: ColorScheme) -> Color {
//        let any = Color(red: 0.196, green: 0.796, blue: 0.329, opacity: 0.5)
//        let dark = Color(red: 0.408, green: 0.698, blue: 0.420, opacity: 0.61)
//        switch scheme {
//        case .light:
//            return any
//        case .dark:
//            return dark
//        @unknown default:
//            return any
//        }
        return colors[2]
    }
    
    func ellipsesBottomTrailing(forScheme scheme: ColorScheme) -> Color {
//        Color(red: 0.541, green: 0.733, blue: 0.812, opacity: 0.7)
        return colors[3]
    }
    
    func ellipsesBottomLeading(forScheme scheme: ColorScheme) -> Color {
//        let any = Color(red: 0.196, green: 0.749, blue: 0.486, opacity: 0.55)
//        let dark = Color(red: 0.525, green: 0.859, blue: 0.655, opacity: 0.45)
//        switch scheme {
//        case .light:
//            return any
//        case .dark:
//            return dark
//        @unknown default:
//            return any
//        }
        return colors[4]
    }
}

fileprivate var previewcolors: [Color] = [.red, .yellow, .cyan, .blue, .white]

struct Previews: PreviewProvider {
    static var previews: some View {
        FloatingCloudsView(colors: previewcolors)
        
        FloatingCloudsView(testReduceTransparency: true, colors: previewcolors)
        
        FloatingCloudsView(testDifferentiateWithoutColor: true, colors: previewcolors)
            .environment(\.colorScheme, .dark)
        
        FloatingCloudsView(testDifferentiateWithoutColor: true, colors: previewcolors)
            .environment(\.colorScheme, .light)
    }
}
