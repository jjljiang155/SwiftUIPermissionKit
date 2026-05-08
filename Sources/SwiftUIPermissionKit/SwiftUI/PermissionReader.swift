import SwiftUI

/// Owns a `PermissionCenter` and refreshes permissions as the view appears.
@MainActor
public struct PermissionReader<Content: View>: View {
    @StateObject private var center: PermissionCenter

    private let permissions: [Permission]
    private let content: (PermissionCenter) -> Content

    public init(
        _ permissions: [Permission] = Permission.allCases,
        @ViewBuilder content: @escaping (PermissionCenter) -> Content
    ) {
        self.permissions = permissions
        self._center = StateObject(wrappedValue: PermissionCenter())
        self.content = content
    }

    public init(
        _ permissions: [Permission] = Permission.allCases,
        center: PermissionCenter,
        @ViewBuilder content: @escaping (PermissionCenter) -> Content
    ) {
        self.permissions = permissions
        self._center = StateObject(wrappedValue: center)
        self.content = content
    }

    public var body: some View {
        content(center)
            .task(id: permissions) {
                await center.refresh(permissions)
            }
    }
}
