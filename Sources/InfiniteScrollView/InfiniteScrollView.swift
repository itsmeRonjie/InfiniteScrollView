//
//  InfiniteScrollView.swift
//  Clock Me
//
//  Created by Ronjie Man-on on 11/9/25.
//

import SwiftUI

public enum InfiniteScrollOrientation {
    case horizontal, vertical
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct InfiniteScrollView<Content: View, ChangeIndex: Equatable>: View {
    public typealias Orientation = InfiniteScrollOrientation

    public var changeIndex: ChangeIndex
    public var contentMultiplier: CGFloat
    public var updateBinding: Binding<Bool>?
    public let spacing: CGFloat
    public let orientation: Orientation
    public let content: (ChangeIndex) -> Content
    public let refreshAction: ((@escaping () -> Void) -> Void)?
    public let increaseIndexAction: (ChangeIndex) -> ChangeIndex?
    public let decreaseIndexAction: (ChangeIndex) -> ChangeIndex?
    public var onCenteredIndexChanged: ((ChangeIndex) -> Void)?
    public var stopScrollingOnUpdate: Bool
    public var scrollsToTop: Bool

    public init(
        spacing: CGFloat = 0,
        changeIndex: ChangeIndex,
        contentMultiplier: CGFloat = 11,
        updateBinding: Binding<Bool>? = nil,
        orientation: Orientation = .vertical,
        refreshAction: ((@escaping () -> Void) -> Void)? = nil,
        increaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        decreaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        onCenteredIndexChanged: ((ChangeIndex) -> Void)? = nil,
        stopScrollingOnUpdate: Bool = true,
        scrollsToTop: Bool = false,
        @ViewBuilder content: @escaping (ChangeIndex) -> Content
    ) {
        self.spacing = spacing
        self.content = content
        self.changeIndex = changeIndex
        self.orientation = orientation
        self.refreshAction = refreshAction
        self.updateBinding = updateBinding
        self.contentMultiplier = max(3, contentMultiplier)
        self.increaseIndexAction = increaseIndexAction
        self.decreaseIndexAction = decreaseIndexAction
        self.onCenteredIndexChanged = onCenteredIndexChanged
        self.stopScrollingOnUpdate = stopScrollingOnUpdate
        self.scrollsToTop = scrollsToTop
    }

    public var body: some View {
        InfiniteScrollViewContainer(
            spacing: spacing,
            changeIndex: changeIndex,
            contentMultiplier: contentMultiplier,
            updateBinding: updateBinding,
            orientation: orientation,
            refreshAction: refreshAction,
            increaseIndexAction: increaseIndexAction,
            decreaseIndexAction: decreaseIndexAction,
            onCenteredIndexChanged: onCenteredIndexChanged,
            stopScrollingOnUpdate: stopScrollingOnUpdate,
            scrollsToTop: scrollsToTop,
            content: content
        )
    }
}
