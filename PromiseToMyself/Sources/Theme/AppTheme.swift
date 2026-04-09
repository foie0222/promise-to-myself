import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let background = Color(red: 0.02, green: 0.02, blue: 0.04)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.53) // #888888
    static let accent = Color(red: 0.75, green: 0.63, blue: 1.0) // #C0A0FF
    static let accentBlue = Color(red: 0.5, green: 0.5, blue: 1.0) // #8080FF

    // MARK: - Fonts
    static let promiseText = Font.system(size: 24, weight: .medium, design: .default)
    static let titleText = Font.system(size: 20, weight: .semibold, design: .default)
    static let bodyText = Font.system(size: 16, weight: .regular, design: .default)
    static let captionText = Font.system(size: 14, weight: .regular, design: .default)
    static let buttonText = Font.system(size: 18, weight: .semibold, design: .default)
}
