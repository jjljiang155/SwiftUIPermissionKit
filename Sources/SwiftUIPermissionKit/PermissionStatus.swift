import Foundation

/// A normalized authorization status across supported system permissions.
public enum PermissionStatus: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case limited
    case provisional
    case unavailable
}

public extension PermissionStatus {
    /// `true` when the app can use at least a scoped version of the requested capability.
    var isUsable: Bool {
        switch self {
        case .authorized, .limited, .provisional:
            return true
        case .notDetermined, .denied, .restricted, .unavailable:
            return false
        }
    }

    /// `true` when the system can still show its first authorization prompt.
    var canRequest: Bool {
        self == .notDetermined
    }

    /// `true` when the app should direct the user to Settings instead of showing another prompt.
    var needsSettings: Bool {
        switch self {
        case .denied, .restricted:
            return true
        case .notDetermined, .authorized, .limited, .provisional, .unavailable:
            return false
        }
    }

    var displayName: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .limited:
            return "Limited"
        case .provisional:
            return "Provisional"
        case .unavailable:
            return "Unavailable"
        }
    }
}
