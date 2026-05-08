# ``SwiftUIPermissionKit``

Read and request common app permissions from SwiftUI.

## Overview

Use ``PermissionCenter`` as the observable source of truth for authorization state. Query current state with ``PermissionCenter/status(for:)``, refresh state with ``PermissionCenter/refresh(_:)``, and request access with ``PermissionCenter/request(_:)``.

For SwiftUI screens, attach ``SwiftUI/View/permissionStatusTask(_:center:)`` to refresh state on appearance and present ``PermissionRequestSheet`` with ``SwiftUI/View/permissionSheet(for:isPresented:center:title:message:)``.
