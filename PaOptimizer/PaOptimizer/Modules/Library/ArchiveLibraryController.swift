import UIKit

final class ArchiveLibraryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var onBlueprintPick: ((LoomBlueprint) -> Void)?

    private let table = IntrinsicTableView(frame: .zero, style: .plain)
    private let footer = UILabel()
    private var current = LoomBlueprint.canned()
    private var presets: [(String, String, LoomBlueprint)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        presets = forgePresets()
        atlasBuild()
    }

    func hydrate(current: LoomBlueprint) {
        self.current = current
        footer.text = "Current session: \(current.lattice.rawValue), \(current.reelCount) reels, target RTP \(Int(current.targetRTP * 100))%"
        table.reloadData()
    }

    private func atlasBuild() {
        view.backgroundColor = .clear

        let card = NebulaCard()
        view.addSubview(card)
        card.emberPin(to: view)

        let title = UILabel()
        title.text = "Templates & Export Readiness"
        title.font = VelvetTypography.title(22)
        title.textColor = PrismPalette.frost

        let body = UILabel()
        body.text = "Start from editorial presets, then move back to the workbench to tune. Keeping multiple scenarios in the same app flow helps position the product as a broader balancing suite."
        body.font = VelvetTypography.body(14)
        body.textColor = PrismPalette.haze
        body.numberOfLines = 0

        table.backgroundColor = .clear
        table.separatorColor = PrismPalette.line
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 78
        table.register(UITableViewCell.self, forCellReuseIdentifier: "preset")
        table.isScrollEnabled = false

        footer.text = "Current session: \(current.lattice.rawValue), \(current.reelCount) reels, target RTP \(Int(current.targetRTP * 100))%"
        footer.font = VelvetTypography.body(13)
        footer.textColor = PrismPalette.amber
        footer.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [title, body, table, footer])
        stack.axis = .vertical
        stack.spacing = 12
        card.quasarContent.addSubview(stack)
        stack.emberPin(to: card.quasarContent)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "preset", for: indexPath)
        let item = presets[indexPath.row]
        var config = UIListContentConfiguration.subtitleCell()
        config.text = item.0
        config.secondaryText = item.1
        config.textProperties.color = PrismPalette.frost
        config.secondaryTextProperties.color = PrismPalette.haze
        config.textProperties.font = VelvetTypography.subtitle(16)
        config.secondaryTextProperties.font = VelvetTypography.body(13)
        cell.contentConfiguration = config
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onBlueprintPick?(presets[indexPath.row].2)
    }

    private func forgePresets() -> [(String, String, LoomBlueprint)] {
        var swift = LoomBlueprint.canned()
        swift.targetRTP = 0.94
        swift.targetHitRate = 0.30
        swift.targetDrift = .low
        swift.cadence = .brisk

        var summit = LoomBlueprint.canned()
        summit.targetRTP = 0.965
        summit.targetHitRate = 0.21
        summit.targetDrift = .high
        summit.payouts = summit.payouts.map { row in
            PayoutLoom(symbol: row.symbol, trio: row.trio, quartet: row.quartet * 1.1, quintet: row.quintet * 1.24)
        }

        var arcade = LoomBlueprint.canned()
        arcade.lattice = .line
        arcade.reelCount = 3
        arcade.reelLength = 36
        arcade.targetRTP = 0.91
        arcade.targetHitRate = 0.33
        arcade.targetDrift = .medium

        return [
            ("Soft Landing", "Higher hit frequency, lower variance for longer retention loops.", swift),
            ("Summit Chase", "Premium top-band focus with sharper swings and more event peaks.", summit),
            ("Arcade Trim", "Compact 3-reel profile for lightweight line-slot balancing.", arcade)
        ]
    }
}
