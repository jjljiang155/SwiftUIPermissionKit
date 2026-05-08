import Foundation

/// A system permission supported by SwiftUIPermissionKit.
public enum Permission: String, CaseIterable, Identifiable, Hashable, Sendable {
    case camera
    case microphone
    case photoLibrary
    case addOnlyPhotoLibrary
    case notifications
    case locationWhenInUse

    public var id: String { rawValue }
}

public extension Permission {
    /// A stable, user-facing name that can be shown in your own settings UI.
    var displayName: String {
        switch self {
        case .camera:
            return "Camera"
        case .microphone:
            return "Microphone"
        case .photoLibrary:
            return "Photo Library"
        case .addOnlyPhotoLibrary:
            return "Add Photos"
        case .notifications:
            return "Notifications"
        case .locationWhenInUse:
            return "Location"
        }
    }

    var defaultRequestTitle: String {
        "\(displayName) Access"
    }

    var defaultRequestMessage: String {
        switch self {
        case .camera:
            return "Allow camera access to capture photos and video."
        case .microphone:
            return "Allow microphone access to record audio."
        case .photoLibrary:
            return "Allow photo library access to choose photos and videos."
        case .addOnlyPhotoLibrary:
            return "Allow access to save new items to the photo library."
        case .notifications:
            return "Allow notifications to receive timely updates."
        case .locationWhenInUse:
            return "Allow location access while using the app."
        }
    }

    var systemImageName: String {
        switch self {
        case .camera:
            return "camera"
        case .microphone:
            return "mic"
        case .photoLibrary, .addOnlyPhotoLibrary:
            return "photo.on.rectangle"
        case .notifications:
            return "bell"
        case .locationWhenInUse:
            return "location"
        }
    }
}
