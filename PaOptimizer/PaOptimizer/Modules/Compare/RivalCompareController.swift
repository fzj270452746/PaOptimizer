import UIKit

final class RivalCompareController: UIViewController {
    var onExportTap: ((String) -> Void)?

    private var project: AtelierProject?
    private var focusChronicle: TuningChronicle?
    private var scenarios: [RivalScenario] = []

    private let stack = UIStackView()
    private let matrix = UIStackView()
    private let reportView = UITextView()

    func hydrate(project: AtelierProject?, focusChronicle: TuningChronicle?, scenarios: [RivalScenario]) {
        self.project = project
        self.focusChronicle = focusChronicle
        self.scenarios = scenarios
        refreshMatrix()
        reportView.text = forgeReportText()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        velvetBuild()
    }

    private func velvetBuild() {
        view.backgroundColor = .clear
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.emberPin(to: view)

        stack.addArrangedSubview(introCard())
        stack.addArrangedSubview(compareCard())
        stack.addArrangedSubview(reportCard())
    }

    private func introCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Scenario Compare"
        title.font = VelvetTypography.title(24)
        title.textColor = PrismPalette.frost

        let body = UILabel()
        body.text = "Compare multiple balancing directions and export a readable report instead of ending the flow at a single optimization run."
        body.font = VelvetTypography.body(14)
        body.textColor = PrismPalette.haze
        body.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [title, body])
        stack.axis = .vertical
        stack.spacing = 10
        card.quasarContent.addSubview(stack)
        stack.emberPin(to: card.quasarContent)
        return card
    }

    private func compareCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Scenario Matrix"
        title.font = VelvetTypography.subtitle(18)
        title.textColor = PrismPalette.frost

        matrix.axis = .vertical
        matrix.spacing = 10

        let host = UIStackView(arrangedSubviews: [title, matrix])
        host.axis = .vertical
        host.spacing = 12
        card.quasarContent.addSubview(host)
        host.emberPin(to: card.quasarContent)
        return card
    }

    private func reportCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Export-Ready Report"
        title.font = VelvetTypography.subtitle(18)
        title.textColor = PrismPalette.frost

        reportView.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        reportView.layer.cornerRadius = 16
        reportView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        reportView.font = VelvetTypography.body(14)
        reportView.textColor = PrismPalette.frost
        reportView.isEditable = false
        reportView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        let exportButton = GlintButton()
        exportButton.tincture(title: "Share Report", accent: [PrismPalette.mint, PrismPalette.flare])
        exportButton.addTarget(self, action: #selector(tapExport), for: .touchUpInside)

        let host = UIStackView(arrangedSubviews: [title, reportView, exportButton])
        host.axis = .vertical
        host.spacing = 12
        card.quasarContent.addSubview(host)
        host.emberPin(to: card.quasarContent)
        return card
    }

    private func refreshMatrix() {
        matrix.arrangedSubviews.forEach {
            matrix.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let focusCard = LumenMetricTile()
        if let focusChronicle {
            focusCard.distill(
                title: "Current Focus",
                value: percent(focusChronicle.optimizedMetrics.rtp),
                detail: "Hit \(percent(focusChronicle.optimizedMetrics.hitRate)) · Var \(focusChronicle.optimizedMetrics.driftCaption)",
                tint: PrismPalette.amber
            )
        } else {
            focusCard.distill(title: "Current Focus", value: "--", detail: "Run optimization first", tint: PrismPalette.haze)
        }
        matrix.addArrangedSubview(focusCard)

        scenarios.forEach { scenario in
            let tile = LumenMetricTile()
            tile.distill(
                title: scenario.title,
                value: percent(scenario.chronicle.optimizedMetrics.rtp),
                detail: "\(scenario.caption) Hit \(percent(scenario.chronicle.optimizedMetrics.hitRate)) · Var \(scenario.chronicle.optimizedMetrics.driftCaption)",
                tint: PrismPalette.mint
            )
            matrix.addArrangedSubview(tile)
        }
    }

    private func forgeReportText() -> String {
        let projectTitle = project?.title ?? "Untitled Project"
        let header = "Project: \(projectTitle)\nMode: \(project?.blueprint.lattice.rawValue ?? "--")\n"

        let focusBlock: String
        if let focusChronicle {
            focusBlock = "Current Result\n- RTP: \(percent(focusChronicle.optimizedMetrics.rtp))\n- Hit Rate: \(percent(focusChronicle.optimizedMetrics.hitRate))\n- Variance: \(focusChronicle.optimizedMetrics.driftCaption)\n"
        } else {
            focusBlock = "Current Result\n- No optimized result loaded yet\n"
        }

        let scenarioBlock = scenarios.map {
            "\($0.title)\n- \($0.caption)\n- RTP: \(percent($0.chronicle.optimizedMetrics.rtp))\n- Hit Rate: \(percent($0.chronicle.optimizedMetrics.hitRate))\n- Variance: \($0.chronicle.optimizedMetrics.driftCaption)"
        }.joined(separator: "\n\n")

        let notesBlock = focusChronicle?.notes.prefix(3).map { "- \($0)" }.joined(separator: "\n") ?? "- Compare scenarios after the first run to populate guidance."

        return [header, focusBlock, "Scenarios\n\(scenarioBlock)", "Notes\n\(notesBlock)"].joined(separator: "\n")
    }

    @objc private func tapExport() {
        onExportTap?(forgeReportText())
    }

    private func percent(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }
}
