import SwiftUI
import SwiftData

@MainActor
final class AppContainer: ObservableObject {
    let player = AudioPlayer.shared
    let api = APIClient()

    func signOut() {
        KeychainStore.deleteToken()
    }
}
