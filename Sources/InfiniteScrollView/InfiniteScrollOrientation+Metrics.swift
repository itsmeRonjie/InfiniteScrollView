//
//  InfiniteScrollViewContainer+Vertical.swift
//  Clock Me
//
//  Created by Ronjie Man-on on 11/9/25.
//

import SwiftUI

extension InfiniteScrollOrientation {
    var axis: Axis.Set {
        switch self {
        case .horizontal: return .horizontal
        case .vertical: return .vertical
        }
    }

    func primaryLength(for size: CGSize) -> CGFloat {
        switch self {
        case .horizontal: return size.width
        case .vertical: return size.height
        }
    }

    func prefetchDistance(viewportSize: CGSize, multiplier: CGFloat) -> CGFloat {
        let base = primaryLength(for: viewportSize)
        return max(base * 0.75, base / max(1, multiplier))
    }

    func recycleDistance(viewportSize: CGSize, multiplier: CGFloat) -> CGFloat {
        let base = primaryLength(for: viewportSize)
        return max(base * 1.5, base * multiplier / 4)
    }
}

extension CGRect {
    func minValue(for orientation: InfiniteScrollOrientation) -> CGFloat {
        switch orientation {
        case .horizontal: return minX
        case .vertical: return minY
        }
    }

    func maxValue(for orientation: InfiniteScrollOrientation) -> CGFloat {
        switch orientation {
        case .horizontal: return maxX
        case .vertical: return maxY
        }
    }

    func midValue(for orientation: InfiniteScrollOrientation) -> CGFloat {
        switch orientation {
        case .horizontal: return midX
        case .vertical: return midY
        }
    }
}
