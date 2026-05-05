import UIKit

final class MosaicInsightsController: UIViewController, UITableViewDataSource {
    private var chronicle: TuningChronicle?
    private let stack = UIStackView()
    private let rtpCurve = ArcTrendView()
    private let driftCurve = ArcTrendView()
    private let table = IntrinsicTableView(frame: .zero, style: .plain)
    private let optimizedRTPTile = LumenMetricTile()
    private let optimizedHitTile = LumenMetricTile()
    private let optimizedVarianceTile = LumenMetricTile()

    func hydrate(with blueprint: LoomBlueprint, chronicle: TuningChronicle?) {
        self.chronicle = chronicle
        let pulses = chronicle?.pulses ?? []
        rtpCurve.infuse(values: pulses.map(\.rtp), tint: PrismPalette.mint)
        driftCurve.infuse(values: pulses.map(\.variance), tint: PrismPalette.rose)
        refreshSummary()
        table.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        orchardBuild()
    }

    private func orchardBuild() {
        view.backgroundColor = .clear
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.emberPin(to: view)

        stack.addArrangedSubview(summaryRow())
        stack.addArrangedSubview(chartCard(title: "RTP Convergence", chart: rtpCurve))
        stack.addArrangedSubview(chartCard(title: "Volatility Drift", chart: driftCurve))
        stack.addArrangedSubview(notesCard())
    }

    private func summaryRow() -> UIView {
        let row = UIStackView()
        row.axis = traitCollection.userInterfaceIdiom == .pad ? .horizontal : .vertical
        row.spacing = 12
        row.distribution = .fillEqually

        refreshSummary()

        [optimizedRTPTile, optimizedHitTile, optimizedVarianceTile].forEach { row.addArrangedSubview($0) }
        return row
    }

    private func refreshSummary() {
        if let chronicle = chronicle {
            optimizedRTPTile.distill(title: "Optimized RTP", value: String(format: "%.1f%%", chronicle.optimizedMetrics.rtp * 100), detail: "From \(String(format: "%.1f%%", chronicle.initialMetrics.rtp * 100))", tint: PrismPalette.mint)
            optimizedHitTile.distill(title: "Optimized Hit", value: String(format: "%.1f%%", chronicle.optimizedMetrics.hitRate * 100), detail: "From \(String(format: "%.1f%%", chronicle.initialMetrics.hitRate * 100))", tint: PrismPalette.amber)
            optimizedVarianceTile.distill(title: "Variance", value: chronicle.optimizedMetrics.driftCaption, detail: "From \(chronicle.initialMetrics.driftCaption)", tint: PrismPalette.rose)
            return
        }

        optimizedRTPTile.distill(title: "Optimized RTP", value: "--", detail: "No data yet", tint: PrismPalette.haze)
        optimizedHitTile.distill(title: "Optimized Hit", value: "--", detail: "No data yet", tint: PrismPalette.haze)
        optimizedVarianceTile.distill(title: "Variance", value: "--", detail: "No data yet", tint: PrismPalette.haze)
    }

    private func chartCard(title: String, chart: UIView) -> UIView {
        let card = NebulaCard()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = VelvetTypography.subtitle(18)
        titleLabel.textColor = PrismPalette.frost

        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 180).isActive = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, chart])
        stack.axis = .vertical
        stack.spacing = 12
        card.quasarContent.addSubview(stack)
        stack.emberPin(to: card.quasarContent)
        return card
    }

    private func notesCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Distribution Notes"
        title.font = VelvetTypography.subtitle(18)
        title.textColor = PrismPalette.frost

        table.backgroundColor = .clear
        table.separatorColor = PrismPalette.line
        table.dataSource = self
        table.rowHeight = 64
        table.register(UITableViewCell.self, forCellReuseIdentifier: "note")
        table.isScrollEnabled = false

        let stack = UIStackView(arrangedSubviews: [title, table])
        stack.axis = .vertical
        stack.spacing = 8
        card.quasarContent.addSubview(stack)
        stack.emberPin(to: card.quasarContent)
        return card
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(chronicle?.notes.count ?? 0, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.textProperties.numberOfLines = 0
        config.textProperties.color = PrismPalette.frost
        config.textProperties.font = VelvetTypography.body(14)
        config.text = chronicle?.notes[indexPath.row] ?? "Run optimization to inspect convergence commentary and payout distribution movement."
        cell.backgroundColor = .clear
        cell.contentConfiguration = config
        return cell
    }
}
