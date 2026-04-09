import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let background = Color(red: 0.02, green: 0.02, blue: 0.04)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.53)
    static let accent = Color(red: 0.75, green: 0.63, blue: 1.0)
    static let accentBlue = Color(red: 0.5, green: 0.5, blue: 1.0)

    // MARK: - Fonts
    static let largeTitle = Font.system(size: 32, weight: .bold)
    static let heroText = Font.system(size: 28, weight: .semibold)
    static let emphasisText = Font.system(size: 24, weight: .bold)
    static let messageText = Font.system(size: 22, weight: .medium)
    static let titleText = Font.system(size: 20, weight: .semibold)
    static let buttonText = Font.system(size: 18, weight: .semibold)
    static let bodyText = Font.system(size: 16, weight: .regular)
    static let captionText = Font.system(size: 14, weight: .regular)
    static let promiseText = Font.system(size: 24, weight: .medium)
    static let countdownText = Font.system(size: 48, weight: .thin)
}
