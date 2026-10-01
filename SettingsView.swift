import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var baseURL = "https://api.example.com"

    var body: some View {
        NavigationStack {
            Form {
                Section("Playback") {
                    Toggle("Background audio", isOn: .constant(true))
                    Toggle("Crossfade", isOn: .constant(false))
                }

                Section("Backend") {
                    TextField("API base URL", text: $baseURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        KeychainStore.deleteToken()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
