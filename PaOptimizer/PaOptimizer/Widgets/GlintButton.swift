import UIKit

final class GlintButton: UIButton {
    private let sheen = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        helioBuild()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        sheen.frame = bounds
        sheen.cornerRadius = 18
    }

    func tincture(title: String, accent: [UIColor]) {
        setTitle(title, for: .normal)
        sheen.colors = accent.map(\.cgColor)
    }

    private func helioBuild() {
        layer.insertSublayer(sheen, at: 0)
        layer.cornerRadius = 18
        titleLabel?.font = VelvetTypography.subtitle(16)
        setTitleColor(.white, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
        auroraShadow(tint: PrismPalette.flare, blur: 18, lift: 10)
    }
}
