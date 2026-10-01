import SwiftUI

@MainActor
final class AppContainer: ObservableObject {
    let player = AudioPlayer.shared
    let api = APIClient()
    let library = LibraryStore()

    func signOut() { KeychainStore.deleteToken() }
}
