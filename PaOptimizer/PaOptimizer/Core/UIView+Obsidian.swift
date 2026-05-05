import UIKit

extension UIView {
    func emberPin(to anchor: UIView, inset: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: anchor.topAnchor, constant: inset.top),
            leadingAnchor.constraint(equalTo: anchor.leadingAnchor, constant: inset.left),
            trailingAnchor.constraint(equalTo: anchor.trailingAnchor, constant: -inset.right),
            bottomAnchor.constraint(equalTo: anchor.bottomAnchor, constant: -inset.bottom)
        ])
    }

    func auroraShadow(tint: UIColor, blur: CGFloat = 20, lift: CGFloat = 8) {
        layer.shadowColor = tint.cgColor
        layer.shadowOpacity = 0.24
        layer.shadowRadius = blur
        layer.shadowOffset = CGSize(width: 0, height: lift)
    }
}

