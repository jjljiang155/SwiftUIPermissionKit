import SwiftUI

/// A compact SwiftUI sheet that requests one permission or directs the user to Settings.
@MainActor
public struct PermissionRequestSheet: View {
    private let permission: Permission
    private let title: String
    private let message: String

    @ObservedObject private var center: PermissionCenter
    @Environment(\.dismiss) private var dismiss
    @State private var status: PermissionStatus
    @State private var isRequesting = false

    public init(
        permission: Permission,
        center: PermissionCenter,
        title: String? = nil,
        message: String? = nil
    ) {
        self.permission = permission
        self.title = title ?? permission.defaultRequestTitle
        self.message = message ?? permission.defaultRequestMessage
        self._center = ObservedObject(wrappedValue: center)
        self._status = State(initialValue: center.status(for: permission))
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: permission.systemImageName)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(status.displayName)
                .font(.footnote)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.quaternary, in: Capsule())

            VStack(spacing: 10) {
                Button(action: primaryAction) {
                    HStack(spacing: 8) {
                        if isRequesting {
                            ProgressView()
                                .controlSize(.small)
                        }

                        Text(primaryButtonTitle)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRequesting || status == .unavailable)

                Button("Not Now") {
                    dismiss()
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(24)
        .task {
            status = await center.refresh(permission)
        }
    }

    private var primaryButtonTitle: String {
        if status.needsSettings {
            return "Open Settings"
        }

        if status.isUsable {
            return "Done"
        }

        return "Continue"
    }

    private func primaryAction() {
        if status.needsSettings {
            PermissionSettings.openAppSettings()
            return
        }

        if status.isUsable {
            dismiss()
            return
        }

        Task { @MainActor in
            isRequesting = true
            status = await center.request(permission)
            isRequesting = false

            if status.isUsable {
                dismiss()
            }
        }
    }
}
