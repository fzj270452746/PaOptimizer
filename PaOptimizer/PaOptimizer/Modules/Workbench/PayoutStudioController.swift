import UIKit

final class PayoutStudioController: UIViewController {
    private let row: PayoutLoom
    private let commit: (PayoutLoom) -> Void

    private let trioField = UITextField()
    private let quartetField = UITextField()
    private let quintetField = UITextField()

    init(row: PayoutLoom, commit: @escaping (PayoutLoom) -> Void) {
        self.row = row
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
        title.text = "Paytable Studio · \(row.symbol)"
        title.font = VelvetTypography.title(22)
        title.textColor = PrismPalette.frost

        let note = UILabel()
        note.text = "Edit each payout tier directly. The controller still preserves a realistic ascending structure on save."
        note.font = VelvetTypography.body(14)
        note.textColor = PrismPalette.haze
        note.numberOfLines = 0

        configure(trioField, value: row.trio)
        configure(quartetField, value: row.quartet)
        configure(quintetField, value: row.quintet)

        let saveButton = GlintButton()
        saveButton.tincture(title: "Save Payouts", accent: [PrismPalette.mint, PrismPalette.flare])
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
            labeled("3 Of A Kind", trioField),
            labeled("4 Of A Kind", quartetField),
            labeled("5 Of A Kind", quintetField),
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

    private func configure(_ field: UITextField, value: Double) {
        field.borderStyle = .none
        field.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        field.layer.cornerRadius = 14
        field.textColor = PrismPalette.frost
        field.keyboardType = .decimalPad
        field.font = VelvetTypography.mono(16)
        field.text = String(format: "%.0f", value)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        field.leftViewMode = .always
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
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
        let trio = max(1, Double(trioField.text ?? "") ?? row.trio)
        let quartetRaw = max(trio + 1, Double(quartetField.text ?? "") ?? row.quartet)
        let quintetRaw = max(quartetRaw + 1, Double(quintetField.text ?? "") ?? row.quintet)
        let revised = PayoutLoom(symbol: row.symbol, trio: trio, quartet: quartetRaw, quintet: quintetRaw)
        dismiss(animated: true) { [commit] in
            commit(revised)
        }
    }

    @objc private func tapCancel() {
        dismiss(animated: true)
    }
}
