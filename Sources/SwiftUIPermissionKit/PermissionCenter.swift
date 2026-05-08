import Combine
import Foundation

/// Observable permission state for SwiftUI views.
@MainActor
public final class PermissionCenter: ObservableObject {
    @Published public private(set) var statuses: [Permission: PermissionStatus]

    private let client: PermissionClient

    public init(
        client: PermissionClient = .live,
        initialStatuses: [Permission: PermissionStatus] = [:]
    ) {
        self.client = client
        self.statuses = initialStatuses
    }

    public func status(for permission: Permission) -> PermissionStatus {
        statuses[permission] ?? .notDetermined
    }

    @discardableResult
    public func refresh(_ permission: Permission) async -> PermissionStatus {
        let status = await client.status(permission)
        statuses[permission] = status
        return status
    }

    public func refresh(_ permissions: [Permission]) async {
        for permission in permissions {
            await refresh(permission)
        }
    }

    @discardableResult
    public func request(_ permission: Permission) async -> PermissionStatus {
        let status = await client.request(permission)
        statuses[permission] = status
        return status
    }
}
