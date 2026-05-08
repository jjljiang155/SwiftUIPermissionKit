import XCTest
@testable import SwiftUIPermissionKit

final class PermissionStatusTests: XCTestCase {
    func testUsableStatuses() {
        XCTAssertTrue(PermissionStatus.authorized.isUsable)
        XCTAssertTrue(PermissionStatus.limited.isUsable)
        XCTAssertTrue(PermissionStatus.provisional.isUsable)

        XCTAssertFalse(PermissionStatus.notDetermined.isUsable)
        XCTAssertFalse(PermissionStatus.denied.isUsable)
        XCTAssertFalse(PermissionStatus.restricted.isUsable)
        XCTAssertFalse(PermissionStatus.unavailable.isUsable)
    }

    func testNeedsSettingsStatuses() {
        XCTAssertTrue(PermissionStatus.denied.needsSettings)
        XCTAssertTrue(PermissionStatus.restricted.needsSettings)

        XCTAssertFalse(PermissionStatus.notDetermined.needsSettings)
        XCTAssertFalse(PermissionStatus.authorized.needsSettings)
        XCTAssertFalse(PermissionStatus.limited.needsSettings)
        XCTAssertFalse(PermissionStatus.provisional.needsSettings)
        XCTAssertFalse(PermissionStatus.unavailable.needsSettings)
    }
}
