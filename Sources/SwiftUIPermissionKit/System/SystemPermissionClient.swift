import AVFoundation
import CoreLocation
import Photos
import UserNotifications

enum SystemPermissionClient {
    @MainActor
    static func status(for permission: Permission) async -> PermissionStatus {
        switch permission {
        case .camera:
            return avStatus(for: .video)
        case .microphone:
            return avStatus(for: .audio)
        case .photoLibrary:
            return photoStatus(for: .readWrite)
        case .addOnlyPhotoLibrary:
            return photoStatus(for: .addOnly)
        case .notifications:
            return await notificationStatus()
        case .locationWhenInUse:
            return locationStatus(from: CLLocationManager().authorizationStatus)
        }
    }

    @MainActor
    static func request(_ permission: Permission) async -> PermissionStatus {
        switch permission {
        case .camera:
            return await requestAVAuthorization(for: .video)
        case .microphone:
            return await requestAVAuthorization(for: .audio)
        case .photoLibrary:
            return await requestPhotoAuthorization(for: .readWrite)
        case .addOnlyPhotoLibrary:
            return await requestPhotoAuthorization(for: .addOnly)
        case .notifications:
            return await requestNotificationAuthorization()
        case .locationWhenInUse:
            return await LocationAuthorizationRequester().requestWhenInUse()
        }
    }

    private static func avStatus(for mediaType: AVMediaType) -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .unavailable
        }
    }

    private static func requestAVAuthorization(for mediaType: AVMediaType) async -> PermissionStatus {
        let current = avStatus(for: mediaType)
        guard current == .notDetermined else {
            return current
        }

        let granted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                continuation.resume(returning: granted)
            }
        }

        return granted ? .authorized : avStatus(for: mediaType)
    }

    private static func photoStatus(for accessLevel: PHAccessLevel) -> PermissionStatus {
        mapPhotoStatus(PHPhotoLibrary.authorizationStatus(for: accessLevel))
    }

    private static func requestPhotoAuthorization(for accessLevel: PHAccessLevel) async -> PermissionStatus {
        let current = photoStatus(for: accessLevel)
        guard current == .notDetermined else {
            return current
        }

        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                continuation.resume(returning: mapPhotoStatus(status))
            }
        }
    }

    private static func mapPhotoStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .limited:
            return .limited
        @unknown default:
            return .unavailable
        }
    }

    private static func notificationStatus() async -> PermissionStatus {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: mapNotificationStatus(settings.authorizationStatus))
            }
        }
    }

    private static func requestNotificationAuthorization() async -> PermissionStatus {
        let current = await notificationStatus()
        guard current == .notDetermined else {
            return current
        }

        _ = try? await withCheckedThrowingContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        } as Bool

        return await notificationStatus()
    }

    private static func mapNotificationStatus(_ status: UNAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .provisional
        @unknown default:
            return .unavailable
        }
    }

    static func locationStatus(from status: CLAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        @unknown default:
            return .unavailable
        }
    }
}

private final class LocationAuthorizationRequester: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<PermissionStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestWhenInUse() async -> PermissionStatus {
        let current = SystemPermissionClient.locationStatus(from: manager.authorizationStatus)
        guard current == .notDetermined else {
            return current
        }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            self.manager.requestWhenInUseAuthorization()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        finish(with: SystemPermissionClient.locationStatus(from: manager.authorizationStatus))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(with: SystemPermissionClient.locationStatus(from: manager.authorizationStatus))
    }

    private func finish(with status: PermissionStatus) {
        guard let continuation else {
            return
        }

        self.continuation = nil
        manager.delegate = nil
        continuation.resume(returning: status)
    }

    deinit {
        continuation?.resume(returning: .unavailable)
    }
}
