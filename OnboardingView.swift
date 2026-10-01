import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedFugaciousOnboarding") private var hasCompletedOnboarding = false
    @State private var page = 0

    private let pages = [
        ("Fugacious", "Off the record.\nBy design.", "Your music, your way."),
        ("Organize", "Build a library\nthat feels like yours.", "Pin albums, playlists, and the tracks you never want to lose."),
        ("Listen", "Stay in the moment.", "A focused player designed around the music, not the noise.")
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                OnboardingBackdrop()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(page == pages.count - 1 ? "Done" : "Skip") {
                            finish()
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.68))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, max(proxy.safeAreaInsets.top, 12))

                    Spacer(minLength: 20)

                    Image("FugaciousMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(proxy.size.width * 0.30, 128))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .purple.opacity(0.30), radius: 30, y: 12)

                    Text(pages[page].0)
                        .font(.system(size: min(proxy.size.width * 0.105, 46), weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 24)

                    Text(pages[page].1)
                        .font(.system(size: 21, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 28)
                        .padding(.top, 12)

                    Text(pages[page].2)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.52))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 42)
                        .padding(.top, 14)

                    Spacer(minLength: 20)

                    HStack(spacing: 7) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == page ? .white : .white.opacity(0.22))
                                .frame(width: index == page ? 22 : 7, height: 7)
                        }
                    }
                    .padding(.bottom, 22)

                    Button {
                        if page < pages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                page += 1
                            }
                        } else {
                            finish()
                        }
                    } label: {
                        Text(page == pages.count - 1 ? "Enter Fugacious" : "Continue")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(proxy.safeAreaInsets.bottom, 14))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    private func finish() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
    }
}

private struct OnboardingBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.015, green: 0.025, blue: 0.09),
                        Color(red: 0.035, green: 0.02, blue: 0.13),
                        Color(red: 0.08, green: 0.035, blue: 0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(.purple.opacity(0.25))
                    .frame(width: proxy.size.width * 0.72)
                    .blur(radius: 80)
                    .offset(
                        x: proxy.size.width * 0.18,
                        y: -proxy.size.height * 0.22
                    )

                MountainShape(points: [
                    .init(x: 0, y: 0.63),
                    .init(x: 0.15, y: 0.50),
                    .init(x: 0.28, y: 0.58),
                    .init(x: 0.43, y: 0.38),
                    .init(x: 0.57, y: 0.54),
                    .init(x: 0.73, y: 0.44),
                    .init(x: 0.86, y: 0.56),
                    .init(x: 1, y: 0.47),
                    .init(x: 1, y: 1),
                    .init(x: 0, y: 1)
                ])
                .fill(
                    LinearGradient(
                        colors: [
                            .black.opacity(0.78),
                            Color(red: 0.02, green: 0.025, blue: 0.07)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                MountainShape(points: [
                    .init(x: 0, y: 0.78),
                    .init(x: 0.18, y: 0.64),
                    .init(x: 0.34, y: 0.72),
                    .init(x: 0.53, y: 0.57),
                    .init(x: 0.70, y: 0.70),
                    .init(x: 0.86, y: 0.61),
                    .init(x: 1, y: 0.70),
                    .init(x: 1, y: 1),
                    .init(x: 0, y: 1)
                ])
                .fill(.black.opacity(0.82))

                LinearGradient(
                    colors: [.clear, .black.opacity(0.45)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}

private struct MountainShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }

        path.move(to: CGPoint(x: first.x * rect.width, y: first.y * rect.height))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
        }
        path.closeSubpath()
        return path
    }
}
