import UIKit

final class LumenMetricTile: UIView {
    private let glyphLabel = UILabel()
    private let valueLabel = UILabel()
    private let detailLabel = UILabel()

    init() {
        super.init(frame: .zero)
        zephyrBuild()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func distill(title: String, value: String, detail: String, tint: UIColor) {
        glyphLabel.text = title.uppercased()
        valueLabel.text = value
        detailLabel.text = detail
        valueLabel.textColor = tint
    }

    private func zephyrBuild() {
        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = PrismPalette.line.cgColor

        glyphLabel.font = VelvetTypography.body(11)
        glyphLabel.textColor = PrismPalette.haze

        valueLabel.font = VelvetTypography.title(24)
        valueLabel.textColor = PrismPalette.frost

        detailLabel.font = VelvetTypography.body(12)
        detailLabel.textColor = PrismPalette.haze
        detailLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [glyphLabel, valueLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 6

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
}

