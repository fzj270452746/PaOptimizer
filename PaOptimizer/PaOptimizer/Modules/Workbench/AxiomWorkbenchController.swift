import UIKit

final class AxiomWorkbenchController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private enum LedgerPanel: Int {
        case symbols
        case paytable
    }

    var onBlueprintShift: ((LoomBlueprint) -> Void)?
    var onOptimizeTap: (() -> Void)?
    var onInfoTap: (() -> Void)?

    private var blueprint = LoomBlueprint.canned()
    private var chronicle: TuningChronicle?

    private let stack = UIStackView()
    private let tokenRoster = IntrinsicTableView(frame: .zero, style: .plain)
    private let payoutRoster = IntrinsicTableView(frame: .zero, style: .plain)
    private let targetRTP = UITextField()
    private let targetHit = UITextField()
    private let reelCount = UISegmentedControl(items: ["3", "5", "6"])
    private let latticeKind = UISegmentedControl(items: LatticeFlavor.allCases.map(\.rawValue))
    private let driftKind = UISegmentedControl(items: DriftGrade.allCases.map(\.rawValue))
    private let cadenceKind = UISegmentedControl(items: PulseCadence.allCases.map(\.rawValue))
    private let floorField = UITextField()
    private let ceilingField = UITextField()
    private let ordinalField = UITextField()
    private let baselineTile = LumenMetricTile()
    private let hitTile = LumenMetricTile()
    private let driftTile = LumenMetricTile()

    override func viewDidLoad() {
        super.viewDidLoad()
        mercuryBuild()
    }

    func hydrate(with blueprint: LoomBlueprint, chronicle: TuningChronicle?) {
        self.blueprint = blueprint
        self.chronicle = chronicle
        targetRTP.text = String(format: "%.1f", blueprint.targetRTP * 100)
        targetHit.text = String(format: "%.1f", blueprint.targetHitRate * 100)
        floorField.text = String(format: "%.0f", blueprint.constraints.floorPayout)
        ceilingField.text = String(format: "%.0f", blueprint.constraints.ceilingPayout)
        ordinalField.text = blueprint.constraints.ordinalRules.joined(separator: " | ")
        reelCount.selectedSegmentIndex = [3, 5, 6].firstIndex(of: blueprint.reelCount) ?? 1
        latticeKind.selectedSegmentIndex = LatticeFlavor.allCases.firstIndex(of: blueprint.lattice) ?? 1
        driftKind.selectedSegmentIndex = DriftGrade.allCases.firstIndex(of: blueprint.targetDrift) ?? 1
        cadenceKind.selectedSegmentIndex = PulseCadence.allCases.firstIndex(of: blueprint.cadence) ?? 1
        refreshHeroMetrics()
        tokenRoster.reloadData()
        payoutRoster.reloadData()
    }

    private func mercuryBuild() {
        view.backgroundColor = .clear
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.emberPin(to: view)

        stack.addArrangedSubview(heroCard())
        stack.addArrangedSubview(configCard())
        stack.addArrangedSubview(symbolCard())
        stack.addArrangedSubview(tableCard())
        stack.addArrangedSubview(constraintCard())
        stack.addArrangedSubview(actionRow())
    }

    private func heroCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Workbench"
        title.font = VelvetTypography.title(24)
        title.textColor = PrismPalette.frost

        let body = UILabel()
        body.text = "Tune configuration inputs, symbol math, paytable ladders, and balancing constraints before each run."
        body.font = VelvetTypography.body(14)
        body.textColor = PrismPalette.haze
        body.numberOfLines = 0

        let metricsRow = UIStackView(arrangedSubviews: [baselineTile, hitTile, driftTile])
        metricsRow.axis = traitCollection.userInterfaceIdiom == .pad ? .horizontal : .vertical
        metricsRow.spacing = 12
        metricsRow.distribution = .fillEqually

        let host = UIStackView(arrangedSubviews: [title, body, metricsRow])
        host.axis = .vertical
        host.spacing = 14
        card.quasarContent.addSubview(host)
        host.emberPin(to: card.quasarContent)
        refreshHeroMetrics()
        return card
    }

    private func refreshHeroMetrics() {
        if let chronicle = chronicle {
            baselineTile.distill(title: "Baseline RTP", value: percent(chronicle.initialMetrics.rtp), detail: "Target \(percent(blueprint.targetRTP))", tint: PrismPalette.mint)
            hitTile.distill(title: "Hit Rate", value: percent(chronicle.initialMetrics.hitRate), detail: "Target \(percent(blueprint.targetHitRate))", tint: PrismPalette.amber)
            driftTile.distill(title: "Volatility", value: chronicle.initialMetrics.driftCaption, detail: "Target \(blueprint.targetDrift.rawValue)", tint: PrismPalette.rose)
            return
        }

        baselineTile.distill(title: "Baseline RTP", value: "--", detail: "Awaiting run", tint: PrismPalette.mint)
        hitTile.distill(title: "Hit Rate", value: "--", detail: "Awaiting run", tint: PrismPalette.amber)
        driftTile.distill(title: "Volatility", value: "--", detail: "Awaiting run", tint: PrismPalette.rose)
    }

    private func configCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Input Config"
        title.font = VelvetTypography.subtitle(18)
        title.textColor = PrismPalette.frost

        configureNumeric(targetRTP, placeholder: "Target RTP %")
        configureNumeric(targetHit, placeholder: "Target Hit %")

        [reelCount, latticeKind, driftKind, cadenceKind].forEach {
            $0.selectedSegmentTintColor = PrismPalette.rose
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.06)
            $0.addTarget(self, action: #selector(controlShift), for: .valueChanged)
        }

        let grid = UIStackView(arrangedSubviews: [
            labeled("Reels", reelCount),
            labeled("Mode", latticeKind),
            labeled("Drift", driftKind),
            labeled("Cadence", cadenceKind),
            labeled("Target RTP", targetRTP),
            labeled("Hit Frequency", targetHit)
        ])
        grid.axis = .vertical
        grid.spacing = 12

        let host = UIStackView(arrangedSubviews: [title, grid])
        host.axis = .vertical
        host.spacing = 14
        card.quasarContent.addSubview(host)
        host.emberPin(to: card.quasarContent)
        return card
    }

    private func symbolCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Symbol Studio"
        title.font = VelvetTypography.subtitle(18)
        title.textColor = PrismPalette.frost

        let note = UILabel()
        note.text = "Tap a row to edit base weight, type, and optimizer access."
        note.font = VelvetTypography.body(13)
        note.textColor = PrismPalette.haze
        note.numberOfLines = 0

        tokenRoster.backgroundColor = .clear
        tokenRoster.separatorColor = PrismPalette.line
        tokenRoster.rowHeight = 72
        tokenRoster.dataSource = self
        tokenRoster.delegate = self
        tokenRoster.tag = LedgerPanel.symbols.rawValue
        tokenRoster.register(UITableViewCell.self, forCellReuseIdentifier: "token")
        tokenRoster.isScrollEnabled = false

        let host = UIStackView(arrangedSubviews: [title, note, tokenRoster])
        host.axis = .vertical
        host.spacing = 10
        card.quasarContent.addSubview(host)
        host.emberPin(to: card.quasarContent)
        return card
    }

    private func tableCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Paytable Studio"
        title.font = VelvetTypography.subtitle(18)
        title.textColor = PrismPalette.frost

        let note = UILabel()
        note.text = "Tap a row to edit the payout ladder for that symbol."
        note.font = VelvetTypography.body(13)
        note.textColor = PrismPalette.haze
        note.numberOfLines = 0

        payoutRoster.backgroundColor = .clear
        payoutRoster.separatorColor = PrismPalette.line
        payoutRoster.rowHeight = 54
        payoutRoster.dataSource = self
        payoutRoster.delegate = self
        payoutRoster.tag = LedgerPanel.paytable.rawValue
        payoutRoster.register(UITableViewCell.self, forCellReuseIdentifier: "glyph")
        payoutRoster.isScrollEnabled = false

        let host = UIStackView(arrangedSubviews: [title, note, payoutRoster])
        host.axis = .vertical
        host.spacing = 10
        card.quasarContent.addSubview(host)
        host.emberPin(to: card.quasarContent)
        return card
    }

    private func constraintCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Constraint Studio"
        title.font = VelvetTypography.subtitle(18)
        title.textColor = PrismPalette.frost

        let note = UILabel()
        note.text = "Set payout floors, caps, and the ordinal relationship string used during balancing reviews."
        note.font = VelvetTypography.body(13)
        note.textColor = PrismPalette.haze
        note.numberOfLines = 0

        configureNumeric(floorField, placeholder: "Minimum payout")
        configureNumeric(ceilingField, placeholder: "Maximum payout")
        ordinalField.borderStyle = .none
        ordinalField.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        ordinalField.layer.cornerRadius = 14
        ordinalField.textColor = PrismPalette.frost
        ordinalField.font = VelvetTypography.body(15)
        ordinalField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        ordinalField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        ordinalField.leftViewMode = .always
        ordinalField.addTarget(self, action: #selector(constraintShift), for: .editingChanged)

        let host = UIStackView(arrangedSubviews: [
            title,
            note,
            labeled("Min Payout", floorField),
            labeled("Max Payout", ceilingField),
            labeled("Ordinal Rules", ordinalField)
        ])
        host.axis = .vertical
        host.spacing = 12
        card.quasarContent.addSubview(host)
        host.emberPin(to: card.quasarContent)
        return card
    }

    private func actionRow() -> UIView {
        let row = UIStackView()
        row.axis = traitCollection.userInterfaceIdiom == .pad ? .horizontal : .vertical
        row.spacing = 12
        row.distribution = .fillEqually

        let optimize = GlintButton()
        optimize.tincture(title: "Run Optimization", accent: [PrismPalette.flare, PrismPalette.rose])
        optimize.addTarget(self, action: #selector(fireOptimization), for: .touchUpInside)

        let reset = GlintButton()
        reset.tincture(title: "Reset Template", accent: [PrismPalette.amber, PrismPalette.rose])
        reset.addTarget(self, action: #selector(resetBlueprint), for: .touchUpInside)

        let info = GlintButton()
        info.tincture(title: "Review Scope", accent: [PrismPalette.mint, PrismPalette.flare])
        info.addTarget(self, action: #selector(openInfo), for: .touchUpInside)

        [optimize, reset, info].forEach { row.addArrangedSubview($0) }
        return row
    }

    private func labeled(_ title: String, _ view: UIView) -> UIView {
        let caption = UILabel()
        caption.text = title.uppercased()
        caption.font = VelvetTypography.body(11)
        caption.textColor = PrismPalette.haze

        let stack = UIStackView(arrangedSubviews: [caption, view])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func configureNumeric(_ field: UITextField, placeholder: String) {
        field.borderStyle = .none
        field.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        field.layer.cornerRadius = 14
        field.textColor = PrismPalette.frost
        field.font = VelvetTypography.mono(16)
        field.keyboardType = .decimalPad
        field.placeholder = placeholder
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        field.leftViewMode = .always
        field.addTarget(self, action: #selector(fieldShift), for: .editingChanged)
    }

    @objc private func fieldShift() {
        var copy = blueprint
        if let text = targetRTP.text, let value = Double(text) {
            copy.targetRTP = min(0.99, max(0.85, value / 100))
        }
        if let text = targetHit.text, let value = Double(text) {
            copy.targetHitRate = min(0.50, max(0.10, value / 100))
        }
        if let text = floorField.text, let value = Double(text) {
            copy.constraints.floorPayout = max(1, value)
        }
        if let text = ceilingField.text, let value = Double(text) {
            copy.constraints.ceilingPayout = max(copy.constraints.floorPayout + 1, value)
        }
        onBlueprintShift?(copy)
    }

    @objc private func controlShift() {
        var copy = blueprint
        copy.reelCount = [3, 5, 6][reelCount.selectedSegmentIndex]
        copy.lattice = LatticeFlavor.allCases[latticeKind.selectedSegmentIndex]
        copy.targetDrift = DriftGrade.allCases[driftKind.selectedSegmentIndex]
        copy.cadence = PulseCadence.allCases[cadenceKind.selectedSegmentIndex]
        onBlueprintShift?(copy)
    }

    @objc private func constraintShift() {
        var copy = blueprint
        let fragments = (ordinalField.text ?? "")
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        copy.constraints.ordinalRules = fragments.isEmpty ? blueprint.constraints.ordinalRules : fragments
        onBlueprintShift?(copy)
    }

    @objc private func fireOptimization() {
        onOptimizeTap?()
    }

    @objc private func resetBlueprint() {
        onBlueprintShift?(LoomBlueprint.canned())
    }

    @objc private func openInfo() {
        onInfoTap?()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == LedgerPanel.symbols.rawValue {
            return blueprint.tokens.count
        }
        return blueprint.payouts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == LedgerPanel.symbols.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "token", for: indexPath)
            let token = blueprint.tokens[indexPath.row]
            var config = UIListContentConfiguration.subtitleCell()
            config.text = "\(token.id) · \(token.kind.rawValue.capitalized)"
            config.secondaryText = "Weight \(String(format: "%.1f", token.baseWeight)) · \(token.isAdjustable ? "Editable" : "Locked")"
            config.textProperties.color = PrismPalette.frost
            config.secondaryTextProperties.color = PrismPalette.haze
            config.secondaryTextProperties.numberOfLines = 2
            cell.contentConfiguration = config
            cell.backgroundColor = .clear
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "glyph", for: indexPath)
        let row = blueprint.payouts[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = "\(row.symbol)   3: \(Int(row.trio))   4: \(Int(row.quartet))   5: \(Int(row.quintet))"
        config.textProperties.font = VelvetTypography.mono(15)
        config.textProperties.color = PrismPalette.frost
        cell.backgroundColor = .clear
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView.tag == LedgerPanel.symbols.rawValue {
            let token = blueprint.tokens[indexPath.row]
            present(SigilStudioController(token: token) { [weak self] revised in
                guard let self else { return }
                var copy = self.blueprint
                copy.tokens[indexPath.row] = revised
                self.onBlueprintShift?(copy)
            }, animated: true)
            return
        }

        let row = blueprint.payouts[indexPath.row]
        present(PayoutStudioController(row: row) { [weak self] revised in
            guard let self else { return }
            var copy = self.blueprint
            copy.payouts[indexPath.row] = revised
            self.onBlueprintShift?(copy)
        }, animated: true)
    }

    private func percent(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }
}
