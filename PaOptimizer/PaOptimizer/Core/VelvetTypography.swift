import UIKit

enum VelvetTypography {
    static func title(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func subtitle(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func body(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func mono(_ size: CGFloat) -> UIFont {
        UIFont.monospacedDigitSystemFont(ofSize: size, weight: .medium)
    }
}

