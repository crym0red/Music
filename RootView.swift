import SwiftUI

struct RootView: View {
    @StateObject private var app = AppContainer()
    @State private var selection = 0
    @State private var showSearch = false
    @State private var showAdd = false
    @State private var showProfile = false
    @AppStorage("hasCompletedFugaciousOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else {
            mainInterface
        }
    }

    private var mainInterface: some View {
        ZStack {
            Color.fugaciousBackground.ignoresSafeArea()

            Group {
                switch selection {
                case 0:
                    LibraryView(showSearch: $showSearch, showAdd: $showAdd, showProfile: $showProfile)
                case 1:
                    SearchView()
                case 2:
                    Text("Your playlists")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                case 3:
                    Text("Now Playing")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                default:
                    LibraryView(showSearch: $showSearch, showAdd: $showAdd, showProfile: $showProfile)
                }
            }

            VStack(spacing: 0) {
                Spacer()
                MiniPlayer(player: app.player)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 7)
                TabBar(selection: $selection)
            }
        }
        .sheet(isPresented: $showSearch) { SearchView() }
        .sheet(isPresented: $showAdd) { AddMenuView() }
        .sheet(isPresented: $showProfile) { ProfileView() }
        .environmentObject(app)
    }
}

struct TabBar: View {
    @Binding var selection: Int

    var body: some View {
        HStack {
            tab("house.fill", "Home", 0)
            tab("magnifyingglass", "Search", 1)
            tab("rectangle.stack.fill", "Library", 2)
            tab("play.circle.fill", "Player", 3)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(.white.opacity(0.07)).frame(height: 1)
        }
    }

    private func tab(_ icon: String, _ title: String, _ value: Int) -> some View {
        Button {
            selection = value
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(selection == value ? .white : .white.opacity(0.42))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

extension Color {
    static let fugaciousBackground = Color(red: 0.018, green: 0.008, blue: 0.07)
    static let fugaciousCard = Color(red: 0.045, green: 0.025, blue: 0.105)
}
