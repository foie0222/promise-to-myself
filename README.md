# 自分との約束 (Promise to Myself)

An iOS app for keeping one promise to yourself at a time. Local storage, local notifications, black/cosmic theme.

## Prerequisites

- Mac with macOS 14+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Setup

1. Install XcodeGen (if not already installed):

   ```bash
   brew install xcodegen
   ```

2. Clone this repository:

   ```bash
   git clone <repo-url>
   cd promise-to-myself
   ```

3. Generate the Xcode project:

   ```bash
   xcodegen generate
   ```

4. Open the project:

   ```bash
   open PromiseToMyself.xcodeproj
   ```

5. Select your target device or simulator and press **Cmd+R** to build and run.

## Project Structure

```
PromiseToMyself/
  Sources/
    App/         # App entry point (@main)
    Models/      # Data models
    Navigation/  # Router / navigation state
    Views/       # SwiftUI views
    Effects/     # Visual effects (cosmic theme)
    Services/    # Notification, persistence services
    Theme/       # Colors, fonts, design tokens
  Tests/         # Unit tests
project.yml      # XcodeGen configuration
```

## Notes

- The `.xcodeproj` is not committed to source control. Always run `xcodegen generate` after cloning or pulling changes to `project.yml`.
- Deployment target: iOS 17.0
- Swift 5.9+
