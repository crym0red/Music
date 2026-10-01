import SwiftUI
import UIKit

@main
struct FugaciousApp: App {
    @UIApplicationDelegateAdaptor(FugaciousAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
        }
    }
}

/// Keeps the app's root window edge-to-edge. The actual scene/window size is
/// still owned by iOS (or by a host/container when Fugacious is embedded).
final class FugaciousAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = FugaciousSceneDelegate.self
        return configuration
    }
}

final class FugaciousSceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // SwiftUI owns the root view controller. We only make sure the window
        // itself is using the complete scene bounds and has no opaque margins.
        for window in windowScene.windows {
            window.backgroundColor = .black
            window.rootViewController?.view.backgroundColor = .black
            window.rootViewController?.view.frame = window.bounds
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }
        for window in windowScene.windows {
            window.rootViewController?.view.frame = window.bounds
        }
    }
}
