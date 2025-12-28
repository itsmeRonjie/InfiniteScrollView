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

    @ViewBuilder
    func scrollsToTopCompat(_ enabled: Bool) -> some View {
#if os(iOS)
        background(
            ScrollViewConfigurator { scrollView in
                scrollView.scrollsToTop = enabled
            }
        )
#else
        self
#endif
    }
}

#if os(iOS)
import UIKit

private struct ScrollViewConfigurator: UIViewRepresentable {
    let configure: (UIScrollView) -> Void

    func makeUIView(context: Context) -> ScrollViewResolverView {
        let view = ScrollViewResolverView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: ScrollViewResolverView, context: Context) {
        uiView.configure = configure
        uiView.resolve()
    }
}

private final class ScrollViewResolverView: UIView {
    var configure: ((UIScrollView) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        resolve()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        resolve()
    }

    func resolve() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let scrollView = self.resolveScrollView() else { return }
            self.configure?(scrollView)
        }
    }

    private func resolveScrollView() -> UIScrollView? {
        if let scrollView = enclosingScrollView { return scrollView }
        guard let superview else { return nil }
        return findScrollView(in: superview)
    }
}

private extension UIView {
    var enclosingScrollView: UIScrollView? {
        var view: UIView? = self
        while let current = view {
            if let scrollView = current as? UIScrollView {
                return scrollView
            }
            view = current.superview
        }
        return nil
    }
}

@MainActor
private func findScrollView(in view: UIView) -> UIScrollView? {
    for subview in view.subviews {
        if let scrollView = subview as? UIScrollView {
            return scrollView
        }
        if let scrollView = findScrollView(in: subview) {
            return scrollView
        }
    }
    return nil
}
#endif
