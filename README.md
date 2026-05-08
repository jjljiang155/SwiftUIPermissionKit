# SwiftUIPermissionKit

SwiftUIPermissionKit is a small Swift Package for reading and requesting common iOS permissions from SwiftUI.

It normalizes system authorization APIs into one `PermissionStatus` model and gives SwiftUI apps an observable `PermissionCenter`, a refresh task modifier, and a ready-to-use request sheet.

## Features

- Camera, microphone, photo library, add-only photo library, notifications, and when-in-use location.
- Async APIs for querying and requesting permission state.
- `ObservableObject` state that works with iOS 15+ SwiftUI apps.
- Injectable `PermissionClient` for tests and previews.
- Lightweight SwiftUI sheet for first-time requests and Settings handoff.

## Installation

Add this package in Xcode:

```text
https://github.com/jjljiang155/SwiftUIPermissionKit
```

Then import the library:

```swift
import SwiftUIPermissionKit
```

## Quick Start

```swift
import SwiftUI
import SwiftUIPermissionKit

struct ContentView: View {
    @StateObject private var permissions = PermissionCenter()
    @State private var showsCameraPermission = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Camera: \(permissions.status(for: .camera).displayName)")

            Button("Request Camera") {
                showsCameraPermission = true
            }
        }
        .permissionStatusTask([.camera], center: permissions)
        .permissionSheet(
            for: .camera,
            isPresented: $showsCameraPermission,
            center: permissions
        )
    }
}
```

You can also request directly:

```swift
@MainActor
func requestPhotos() async {
    let center = PermissionCenter()
    let status = await center.request(.photoLibrary)

    if status.isUsable {
        // Continue with the feature.
    }
}
```

## Info.plist Keys

Apple requires purpose strings for the permissions your app requests:

| Permission | Info.plist key |
| --- | --- |
| Camera | `NSCameraUsageDescription` |
| Microphone | `NSMicrophoneUsageDescription` |
| Photo Library | `NSPhotoLibraryUsageDescription` |
| Add Photos | `NSPhotoLibraryAddUsageDescription` |
| Location When In Use | `NSLocationWhenInUseUsageDescription` |
| Notifications | No purpose string required |

Missing purpose strings can crash the app when the system prompt is requested.

## Testing and Previews

Inject a fake client to avoid real system prompts:

```swift
let previewCenter = PermissionCenter(
    client: PermissionClient(
        status: { _ in .authorized },
        request: { _ in .authorized }
    )
)
```

## Requirements

- iOS 15+
- macOS 12+ for package tests and previews
- Swift 5.9+

## License

SwiftUIPermissionKit is available under the MIT license.
