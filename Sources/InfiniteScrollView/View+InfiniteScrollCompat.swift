//
//  ViewModifier.swift
//  InfiniteScrollViewContainer
//
//  Created by Ronjie Man-on on 11/9/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        apply: (Self) -> Content
    ) -> some View {
        if condition { apply(self) } else { self }
    }

    @ViewBuilder
    func scrollDisabledCompat(_ disabled: Bool) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            scrollDisabled(disabled)
        } else {
            self
        }
    }

    @ViewBuilder
    func defaultScrollAnchorCompat(_ anchor: UnitPoint) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            defaultScrollAnchor(anchor)
        } else {
            self
        }
    }
}
