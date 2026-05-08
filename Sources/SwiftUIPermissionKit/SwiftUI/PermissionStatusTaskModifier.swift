import SwiftUI

private struct PermissionStatusTaskModifier: ViewModifier {
    @ObservedObject var center: PermissionCenter

    let permissions: [Permission]

    func body(content: Content) -> some View {
        content.task(id: permissions) {
            await center.refresh(permissions)
        }
    }
}

public extension View {
    /// Refreshes the provided permissions when the view appears.
    @MainActor
    func permissionStatusTask(
        _ permissions: [Permission],
        center: PermissionCenter
    ) -> some View {
        modifier(PermissionStatusTaskModifier(center: center, permissions: permissions))
    }

    /// Presents `PermissionRequestSheet` for the selected permission.
    @MainActor
    func permissionSheet(
        for permission: Permission,
        isPresented: Binding<Bool>,
        center: PermissionCenter,
        title: String? = nil,
        message: String? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            PermissionRequestSheet(
                permission: permission,
                center: center,
                title: title,
                message: message
            )
        }
    }
}
