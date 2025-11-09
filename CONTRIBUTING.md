# Contributing to InfiniteScrollView

Thanks for taking the time to improve this library! The guidelines below help keep changes coordinated and aligned with the package’s goals.

## Prerequisites
- Xcode 15.4 or later (or Swift 5.9 toolchain)
- macOS 14 or later for building/testing locally
- Familiarity with SwiftUI and Swift Package Manager

## Development Workflow

1. **Fork and clone** the repository.
2. **Create a feature branch** off `main` (`git checkout -b feature/my-improvement`).
3. **Install dependencies** and open the package:
   - `swift build` / `swift test`
   - or `xed .` to open in Xcode via `Package.swift`
4. **Add tests** for any new logic or bug fix. At minimum, run `swift test` before submitting.
5. **Keep commits focused**: one logical change per commit; avoid large refactors mixed with feature work.
6. **Run formatting/linting** if you have custom rules (none enforced yet).

## Pull Requests
- Use the template (if provided) and describe motivation, approach, and validation steps.
- Update documentation (README, comments, etc.) when public APIs change.
- Ensure CI passes (GitHub Actions `CI` workflow) before requesting review.
- For UI/behavior changes, include screenshots or short videos when possible.

## Coding Guidelines
- Prefer SwiftUI idioms and avoid UIKit unless necessary.
- Keep APIs generic; the `InfiniteScrollView` should remain flexible for different data types.
- Document new public APIs using Swift doc comments.

## Reporting Issues / Feature Requests
- Search existing issues first.
- Provide clear reproduction steps or mock data if reporting a bug.
- Describe real-world use cases when requesting new features.

Thanks again for contributing!
