//
//  InfiniteScrollViewContainer+Centering.swift
//  Clock Me
//
//  Created by Ronjie Man-on on 11/9/25.
//

import SwiftUI

extension InfiniteScrollViewContainer {
    func ensureInitialCentering() {
        guard !didCenterInitially else { return }
        didCenterInitially = true
        DispatchQueue.main.async {
            centerOn(index: changeIndex, animated: false)
        }
    }

    func handleFrameChanges(_ frames: [UUID: CGRect], viewportSize: CGSize) {
        visibleFrames = frames
        guard !items.isEmpty else { return }
        maybePrefetch(viewportSize: viewportSize)
        trimInvisibleItems(viewportSize: viewportSize)
        updateCenteredIndex(viewportSize: viewportSize)
    }

    func maybePrefetch(viewportSize: CGSize) {
        let prefetchDistance = orientation.prefetchDistance(
            viewportSize: viewportSize,
            multiplier: contentMultiplier
        )

        if let last = items.last,
           let frame = visibleFrames[last.id],
           frame.maxValue(for: orientation) < orientation.primaryLength(for: viewportSize) + prefetchDistance,
           let next = increaseIndexAction(last.index) {
            items.append(.init(index: next))
        }

        if let first = items.first,
           let frame = visibleFrames[first.id],
           frame.minValue(for: orientation) > -prefetchDistance,
           let previous = decreaseIndexAction(first.index) {
            items.insert(.init(index: previous), at: 0)
        }
    }

    func trimInvisibleItems(viewportSize: CGSize) {
        guard items.count > minimumVisibleCount else { return }
        let recycleDistance = orientation.recycleDistance(
            viewportSize: viewportSize,
            multiplier: contentMultiplier
        )
        let viewportLength = orientation.primaryLength(for: viewportSize)

        if let first = items.first,
           let frame = visibleFrames[first.id],
           frame.maxValue(for: orientation) < -recycleDistance {
            visibleFrames[first.id] = nil
            items.removeFirst()
        }

        if items.count > minimumVisibleCount,
           let last = items.last,
           let frame = visibleFrames[last.id],
           frame.minValue(for: orientation) > viewportLength + recycleDistance {
            visibleFrames[last.id] = nil
            items.removeLast()
        }
    }

    func updateCenteredIndex(viewportSize: CGSize) {
        guard let target = centeredItem(viewportSize: viewportSize) else { return }
        let changed = lastReportedIndex != target.index
        lastReportedIndex = target.index

        if let pending = pendingProgrammaticTarget {
            if pending == target.index {
                pendingProgrammaticTarget = nil
            } else {
                return
            }
        }

        guard changed else { return }
        if onCenteredIndexChanged != nil {
            suppressChangeIndexReaction = true
        }
        onCenteredIndexChanged?(target.index)
    }

    func centeredItem(viewportSize: CGSize) -> ScrollItem? {
        let centerValue = orientation.primaryLength(for: viewportSize) / 2
        return items.compactMap { item -> (ScrollItem, CGFloat)? in
            guard let frame = visibleFrames[item.id] else { return nil }
            let distance = abs(frame.midValue(for: orientation) - centerValue)
            return (item, distance)
        }.min { lhs, rhs in
            lhs.1 < rhs.1
        }?.0
    }

    func centerOn(index: ChangeIndex, animated: Bool) {
        pendingProgrammaticTarget = index
        if let target = items.first(where: { $0.index == index }) {
            scheduleScroll(to: target.id, animated: animated)
        } else {
            rebuildItems(around: index, animated: false)
        }

        if stopScrollingOnUpdate {
            temporarilyDisableScrolling()
        }
    }

    func rebuildItems(around index: ChangeIndex, animated: Bool) {
        let updated = Self.bootstrapItems(
            around: index,
            requestedCount: Self.windowSize(for: contentMultiplier),
            increase: increaseIndexAction,
            decrease: decreaseIndexAction
        )
        items = updated
        visibleFrames.removeAll()
        lastReportedIndex = index
        if let target = updated.first(where: { $0.index == index }) {
            scheduleScroll(to: target.id, animated: animated)
        }
    }

    func reloadFromBinding() {
        centerOn(index: changeIndex, animated: !stopScrollingOnUpdate)
        DispatchQueue.main.async {
            updateBinding?.wrappedValue = false
        }
    }

    func scheduleScroll(to id: UUID, animated: Bool) {
        animateNextScroll = animated
        pendingScrollID = id
    }

    func temporarilyDisableScrolling() {
        guard !isScrollDisabled else { return }
        isScrollDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isScrollDisabled = false
        }
    }

    var minimumVisibleCount: Int {
        max(5, Self.windowSize(for: contentMultiplier) / 2)
    }

    static func windowSize(for multiplier: CGFloat) -> Int {
        let base = max(3, Int(ceil(multiplier)))
        return base % 2 == 0 ? base + 1 : base
    }

    static func bootstrapItems(
        around index: ChangeIndex,
        requestedCount: Int,
        increase: (ChangeIndex) -> ChangeIndex?,
        decrease: (ChangeIndex) -> ChangeIndex?
    ) -> [ScrollItem] {
        var before: [ChangeIndex] = []
        var after: [ChangeIndex] = []

        var cursor = index
        while before.count < requestedCount / 2 {
            guard let previous = decrease(cursor) else { break }
            before.append(previous)
            cursor = previous
        }

        cursor = index
        while after.count < requestedCount / 2 {
            guard let next = increase(cursor) else { break }
            after.append(next)
            cursor = next
        }

        let ordered = before.reversed() + [index] + after
        return ordered.map { ScrollItem(index: $0) }
    }
}
