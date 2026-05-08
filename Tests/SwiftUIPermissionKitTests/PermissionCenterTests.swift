import XCTest
@testable import SwiftUIPermissionKit

@MainActor
final class PermissionCenterTests: XCTestCase {
    func testRefreshStoresReturnedStatus() async {
        let center = PermissionCenter(
            client: PermissionClient(
                status: { permission in
                    permission == .camera ? .authorized : .denied
                },
                request: { _ in .authorized }
            )
        )

        await center.refresh([.camera, .microphone])

        XCTAssertEqual(center.status(for: .camera), .authorized)
        XCTAssertEqual(center.status(for: .microphone), .denied)
    }

    func testRequestStoresReturnedStatus() async {
        let center = PermissionCenter(
            client: PermissionClient(
                status: { _ in .notDetermined },
                request: { _ in .limited }
            )
        )

        let status = await center.request(.photoLibrary)

        XCTAssertEqual(status, .limited)
        XCTAssertEqual(center.status(for: .photoLibrary), .limited)
    }

    func testStatusDefaultsToNotDetermined() {
        let center = PermissionCenter(
            client: PermissionClient(
                status: { _ in .authorized },
                request: { _ in .authorized }
            )
        )

        XCTAssertEqual(center.status(for: .notifications), .notDetermined)
    }
}
