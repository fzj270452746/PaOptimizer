import UIKit

final class SigilStudioController: UIViewController {
    private let token: RuneToken
    private let commit: (RuneToken) -> Void

    private let weightField = UITextField()
    private let kindControl = UISegmentedControl(items: SigilGlyph.allCases.map(\.rawValue.capitalized))
    private let adjustControl = UISegmentedControl(items: ["Locked", "Editable"])

    init(token: RuneToken, commit: @escaping (RuneToken) -> Void) {
        self.token = token
        self.commit = commit
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

        let title = UILabel()
        title.text = "Symbol Studio · \(token.id)"
        title.font = VelvetTypography.title(22)
        title.textColor = PrismPalette.frost

        let note = UILabel()
        note.text = "Adjust weight, symbol type, and whether the optimizer may tune it."
        note.font = VelvetTypography.body(14)
        note.textColor = PrismPalette.haze
        note.numberOfLines = 0

        weightField.borderStyle = .none
        weightField.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        weightField.layer.cornerRadius = 14
        weightField.textColor = PrismPalette.frost
        weightField.keyboardType = .decimalPad
        weightField.font = VelvetTypography.mono(16)
        weightField.text = String(format: "%.1f", token.baseWeight)
        weightField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        weightField.leftViewMode = .always
        weightField.heightAnchor.constraint(equalToConstant: 48).isActive = true

        kindControl.selectedSegmentIndex = SigilGlyph.allCases.firstIndex(of: token.kind) ?? 0
        kindControl.selectedSegmentTintColor = PrismPalette.flare
        kindControl.backgroundColor = UIColor.white.withAlphaComponent(0.06)

        adjustControl.selectedSegmentIndex = token.isAdjustable ? 1 : 0
        adjustControl.selectedSegmentTintColor = PrismPalette.rose
        adjustControl.backgroundColor = UIColor.white.withAlphaComponent(0.06)

        let saveButton = GlintButton()
        saveButton.tincture(title: "Save Symbol", accent: [PrismPalette.flare, PrismPalette.rose])
        saveButton.addTarget(self, action: #selector(tapSave), for: .touchUpInside)

        let cancelButton = GlintButton()
        cancelButton.tincture(title: "Cancel", accent: [PrismPalette.amber, PrismPalette.rose])
        cancelButton.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)

        let actions = UIStackView(arrangedSubviews: [saveButton, cancelButton])
        actions.axis = .vertical
        actions.spacing = 12

        let stack = UIStackView(arrangedSubviews: [
            title,
            note,
            labeled("Base Weight", weightField),
            labeled("Symbol Type", kindControl),
            labeled("Optimizer Access", adjustControl),
            actions
        ])
        stack.axis = .vertical
        stack.spacing = 14
        cradle.quasarContent.addSubview(stack)
        stack.emberPin(to: cradle.quasarContent)

        NSLayoutConstraint.activate([
            cradle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cradle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            cradle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22)
        ])
    }

    private func labeled(_ title: String, _ field: UIView) -> UIView {
        let caption = UILabel()
        caption.text = title.uppercased()
        caption.textColor = PrismPalette.haze
        caption.font = VelvetTypography.body(11)
        let stack = UIStackView(arrangedSubviews: [caption, field])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    @objc private func tapSave() {
        let weight = max(1, Double(weightField.text ?? "") ?? token.baseWeight)
        let kind = SigilGlyph.allCases[kindControl.selectedSegmentIndex]
        let editable = adjustControl.selectedSegmentIndex == 1
        let revised = RuneToken(id: token.id, kind: kind, baseWeight: weight, isAdjustable: editable)
        dismiss(animated: true) { [commit] in
            commit(revised)
        }
    }

    @objc private func tapCancel() {
        dismiss(animated: true)
    }
}

