import UIKit

final class NebulaCard: UIView {
    let quasarContent = UIView()

    init() {
        super.init(frame: .zero)
        astralBuild()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func astralBuild() {
        backgroundColor = PrismPalette.veil
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = PrismPalette.line.cgColor
        auroraShadow(tint: PrismPalette.flare)

        addSubview(quasarContent)
        quasarContent.emberPin(to: self, inset: UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18))
    }
}

