import UIKit

final class VelourModalController: UIViewController {
    private let heading: String
    private let message: String
    private let quillAction: (() -> Void)?

    init(heading: String, message: String, action: (() -> Void)? = nil) {
        self.heading = heading
        self.message = message
        self.quillAction = action
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.78)

        let cradle = NebulaCard()
        cradle.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.21, alpha: 1)
        cradle.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        cradle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cradle)

        let titleLabel = UILabel()
        titleLabel.font = VelvetTypography.title(24)
        titleLabel.textColor = PrismPalette.frost
        titleLabel.text = heading

        let bodyLabel = UILabel()
        bodyLabel.font = VelvetTypography.body(15)
        bodyLabel.textColor = PrismPalette.haze
        bodyLabel.text = message
        bodyLabel.numberOfLines = 0

        let closeButton = GlintButton()
        closeButton.tincture(title: "Continue", accent: [PrismPalette.flare, PrismPalette.rose])
        closeButton.addTarget(self, action: #selector(vanish), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, closeButton])
        stack.axis = .vertical
        stack.spacing = 18
        cradle.quasarContent.addSubview(stack)
        stack.emberPin(to: cradle.quasarContent)

        NSLayoutConstraint.activate([
            cradle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cradle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cradle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    @objc private func vanish() {
        dismiss(animated: true) { [quillAction] in
            quillAction?()
        }
    }
}
