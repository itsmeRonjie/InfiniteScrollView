#if canImport(XCTest) && canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import InfiniteScrollView

final class InfiniteScrollViewTests: XCTestCase {
    func testWindowSizeAlwaysOddAndAtLeastThree() {
        XCTAssertEqual(
            InfiniteScrollViewContainer<Int, EmptyView>.windowSize(for: 2),
            3,
            "Values below 3 should clamp to 3."
        )
        XCTAssertEqual(
            InfiniteScrollViewContainer<Int, EmptyView>.windowSize(for: 4),
            5,
            "Even window sizes should round up to the next odd number."
        )
        XCTAssertEqual(
            InfiniteScrollViewContainer<Int, EmptyView>.windowSize(for: 5.4),
            7,
            "Non-integer multipliers should ceil before ensuring oddness."
        )
    }

    func testBootstrapItemsKeepsCenterIndex() {
        let items = InfiniteScrollViewContainer<Int, EmptyView>.bootstrapItems(
            around: 0,
            requestedCount: 5,
            increase: { $0 < 2 ? $0 + 1 : nil },
            decrease: { $0 > -2 ? $0 - 1 : nil }
        )

        XCTAssertEqual(items.count, 5)
        XCTAssertEqual(items.map(\.index), [-2, -1, 0, 1, 2])
    }
}
#endif
