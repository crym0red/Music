import SwiftUI

struct ArtworkView: View {
    let style: ArtworkStyle
    var cornerRadius: CGFloat = 10

    var body: some View {
        ZStack {
            background
            decorativeShapes
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .blue:
            LinearGradient(colors: [.cyan.opacity(0.65), .blue.opacity(0.8), .indigo.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .orange:
            LinearGradient(colors: [.orange, .brown, .black], startPoint: .top, endPoint: .bottomTrailing)
        case .olive:
            LinearGradient(colors: [.green.opacity(0.7), .yellow.opacity(0.35), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .midnight:
            LinearGradient(colors: [.indigo.opacity(0.55), .black, .blue.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .violet:
            LinearGradient(colors: [.purple, .blue.opacity(0.7), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .portrait:
            LinearGradient(colors: [.brown.opacity(0.8), .pink.opacity(0.3), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sunset:
            LinearGradient(colors: [.orange, .red.opacity(0.6), .purple.opacity(0.8), .black], startPoint: .top, endPoint: .bottom)
        case .flower:
            LinearGradient(colors: [.indigo, .purple.opacity(0.8), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .smoke:
            LinearGradient(colors: [.gray.opacity(0.7), .black], startPoint: .top, endPoint: .bottom)
        case .mono:
            LinearGradient(colors: [.white.opacity(0.35), .gray.opacity(0.15), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var decorativeShapes: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: proxy.size.width * 0.9)
                    .blur(radius: 18)
                    .offset(x: proxy.size.width * 0.18, y: -proxy.size.height * 0.12)

                Circle()
                    .fill(.black.opacity(0.32))
                    .frame(width: proxy.size.width * 0.55)
                    .blur(radius: 12)
                    .offset(x: -proxy.size.width * 0.25, y: proxy.size.height * 0.28)

                Image(systemName: style == .portrait ? "person.crop.circle.fill" : "music.note")
                    .font(.system(size: proxy.size.width * 0.28, weight: .bold))
                    .foregroundStyle(.white.opacity(0.28))
            }
        }
    }
}
