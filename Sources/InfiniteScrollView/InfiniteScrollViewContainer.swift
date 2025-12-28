//
//  InfiniteScrollViewContainer.swift
//  Clock Me
//
//  Created by Ronjie Man-on on 11/9/25.
//

import SwiftUI

public struct InfiniteScrollViewContainer<ChangeIndex: Equatable, Content: View>: View {
    public typealias Orientation = InfiniteScrollOrientation
    
    public let spacing: CGFloat
    public let changeIndex: ChangeIndex
    public let contentMultiplier: CGFloat
    public let updateBinding: Binding<Bool>?
    public let orientation: Orientation
    public let refreshAction: ((@escaping () -> Void) -> Void)?
    public let increaseIndexAction: (ChangeIndex) -> ChangeIndex?
    public let decreaseIndexAction: (ChangeIndex) -> ChangeIndex?
    public let onCenteredIndexChanged: ((ChangeIndex) -> Void)?
    public let stopScrollingOnUpdate: Bool
    public let scrollsToTop: Bool
    public let content: (ChangeIndex) -> Content
    
    @State private var coordinateSpaceID = UUID()
    @State var items: [ScrollItem]
    @State var visibleFrames: [UUID: CGRect] = [:]
    @State var pendingScrollID: UUID?
    @State var animateNextScroll = true
    @State var lastReportedIndex: ChangeIndex?
    @State var isScrollDisabled = false
    @State var suppressChangeIndexReaction = false
    @State var pendingProgrammaticTarget: ChangeIndex?
    @State var pendingInitialCentering = true
    @State var initialCenteringAttempts = 0
    
    public init(
        spacing: CGFloat,
        changeIndex: ChangeIndex,
        contentMultiplier: CGFloat,
        updateBinding: Binding<Bool>?,
        orientation: Orientation,
        refreshAction: ((@escaping () -> Void) -> Void)?,
        increaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        decreaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        onCenteredIndexChanged: ((ChangeIndex) -> Void)?,
        stopScrollingOnUpdate: Bool,
        scrollsToTop: Bool = false,
        content: @escaping (ChangeIndex) -> Content
    ) {
        self.spacing = spacing
        self.changeIndex = changeIndex
        self.contentMultiplier = max(3, contentMultiplier)
        self.updateBinding = updateBinding
        self.orientation = orientation
        self.refreshAction = refreshAction
        self.increaseIndexAction = increaseIndexAction
        self.decreaseIndexAction = decreaseIndexAction
        self.onCenteredIndexChanged = onCenteredIndexChanged
        self.stopScrollingOnUpdate = stopScrollingOnUpdate
        self.scrollsToTop = scrollsToTop
        self.content = content
        
        let windowSize = Self.windowSize(for: self.contentMultiplier)
        let seedItems = Self.bootstrapItems(
            around: changeIndex,
            requestedCount: windowSize,
            increase: increaseIndexAction,
            decrease: decreaseIndexAction
        )
        _items = State(initialValue: seedItems)
        _lastReportedIndex = State(initialValue: changeIndex)
    }
    
    public var body: some View {
        GeometryReader { viewportProxy in
            ScrollViewReader { scrollProxy in
                let base = scrollBody(viewportSize: viewportProxy.size)

                let handlePendingChange: (UUID?) -> Void = { id in
                    guard let id else { return }
                    let shouldAnimate = animateNextScroll
                    DispatchQueue.main.async {
                        let action = { scrollProxy.scrollTo(id, anchor: .center) }
                        if shouldAnimate {
                            withAnimation(.easeInOut(duration: 0.25), action)
                        } else {
                            action()
                        }
                        animateNextScroll = true
                        pendingScrollID = nil
                    }
                }

                Group {
                    if #available(iOS 15.0, *), let refreshAction {
                        base.refreshable {
                            await performRefresh(refreshAction)
                        }
                    } else {
                        base
                    }
                }
                .onChange(of: pendingScrollID) { id in
                    handlePendingChange(id)
                }
            }
        }
        .onChange(of: changeIndex) { newValue in
            if suppressChangeIndexReaction,
               let lastReportedIndex,
               lastReportedIndex == newValue {
                suppressChangeIndexReaction = false
                return
            }
            suppressChangeIndexReaction = false
            centerOn(index: newValue, animated: true)
        }
        .onChange(of: updateBinding?.wrappedValue ?? false) { shouldReload in
            guard shouldReload else { return }
            reloadFromBinding()
        }
        .onAppear {
            ensureInitialCentering()
        }
    }
}

extension InfiniteScrollViewContainer {
    func scrollBody(viewportSize: CGSize) -> some View {
        ScrollView(orientation.axis, showsIndicators: false) {
            stackContent
                .scrollsToTopCompat(scrollsToTop)
        }
        .defaultScrollAnchorCompat(.center)
        .scrollDisabledCompat(isScrollDisabled)
        .coordinateSpace(name: coordinateSpaceID)
        .onPreferenceChange(ItemFramePreferenceKey.self) { frames in
            handleFrameChanges(frames, viewportSize: viewportSize)
        }
    }
    
    @ViewBuilder
    var stackContent: some View {
        switch orientation {
        case .horizontal:
            LazyHStack(spacing: spacing) {
                itemViews
            }
        case .vertical:
            LazyVStack(spacing: spacing) {
                itemViews
            }
        }
    }
    
    @ViewBuilder
    var itemViews: some View {
        ForEach(items) { item in
            content(item.index)
                .id(item.id)
                .background(
                    FrameReporter(
                        id: item.id,
                        coordinateSpaceID: coordinateSpaceID
                    )
                )
        }
    }
    struct ScrollItem: Identifiable {
        let id = UUID()
        let index: ChangeIndex
    }
}

private struct ItemFramePreferenceKey: PreferenceKey {
    static let defaultValue: [UUID: CGRect] = [:]
    
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private struct FrameReporter: View {
    let id: UUID
    let coordinateSpaceID: UUID
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: ItemFramePreferenceKey.self,
                    value: [id: proxy.frame(in: .named(coordinateSpaceID))]
                )
        }
    }
}

@available(iOS 15.0, *)
private extension InfiniteScrollViewContainer {
    func performRefresh(_ action: (@escaping () -> Void) -> Void) async {
        await withCheckedContinuation { continuation in
            action {
                continuation.resume()
            }
        }
    }
}
