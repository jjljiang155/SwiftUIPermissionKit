import Foundation

#if canImport(UIKit)
import UIKit
#endif

public enum PermissionSettings {
    /// Opens the current app's Settings page when the platform supports it.
    @MainActor
    public static func openAppSettings() {
        #if canImport(UIKit)
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url)
        #endif
    }
}
