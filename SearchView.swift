import SwiftUI

struct SearchView: View {
    @State private var query = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Search")
                    .font(.system(size: 34, weight: .black, design: .rounded))

                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Artists, albums, songs", text: $query)
                        .textInputAutocapitalization(.never)
                }
                .padding(13)
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 13))

                Text(query.isEmpty ? "Start searching your library" : "Results")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))

                Spacer()
            }
            .padding(18)
            .foregroundStyle(.white)
            .background(Color.fugaciousBackground)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct AddMenuView: View {
    var body: some View {
        NavigationStack {
            List {
                Label("New playlist", systemImage: "music.note.list")
                Label("Import music", systemImage: "square.and.arrow.down")
                Label("Create folder", systemImage: "folder.badge.plus")
            }
            .navigationTitle("Add")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Fugacious")
                    .font(.title.bold())
                Text("Account & Settings")
                    .foregroundStyle(.secondary)

                NavigationLink("Settings") {
                    SettingsView()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.fugaciousBackground)
            .foregroundStyle(.white)
            .navigationTitle("Profile")
        }
    }
}
