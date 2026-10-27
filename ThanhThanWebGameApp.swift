import SwiftUI

@main
struct ThanhThanWebGameApp: App {
    var body: some Scene {
        WindowGroup {
            GameScreen()
                .preferredColorScheme(.dark)
        }
    }
}
