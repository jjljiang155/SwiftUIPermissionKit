# Contributing

Thanks for helping improve SwiftUIPermissionKit.

## Development

Run tests before opening a pull request:

```sh
swift test
```

Keep changes focused and include tests for behavior changes. Permission prompts should stay behind `PermissionClient` so tests and previews do not trigger real system dialogs.

## Pull Requests

- Describe the permission flow or SwiftUI API being changed.
- Include screenshots when changing visible SwiftUI components.
- Update `README.md` when public APIs change.
