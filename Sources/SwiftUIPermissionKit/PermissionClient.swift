import Foundation

/// A small dependency boundary around system authorization APIs.
///
/// Inject a custom client in tests or previews to avoid triggering real system prompts.
public struct PermissionClient {
    public var status: @MainActor (Permission) async -> PermissionStatus
    public var request: @MainActor (Permission) async -> PermissionStatus

    public init(
        status: @escaping @MainActor (Permission) async -> PermissionStatus,
        request: @escaping @MainActor (Permission) async -> PermissionStatus
    ) {
        self.status = status
        self.request = request
    }
}

public extension PermissionClient {
    static var live: PermissionClient {
        PermissionClient(
            status: { permission in
                await SystemPermissionClient.status(for: permission)
            },
            request: { permission in
                await SystemPermissionClient.request(permission)
            }
        )
    }
}
