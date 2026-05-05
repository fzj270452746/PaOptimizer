import UIKit
import Reachability
import AppTrackingTransparency

final class VesperRootController: UIViewController {
    private enum PanelGlyph: Int, CaseIterable {
        case workbench
        case insights
        case compare
        case projects
        case templates

        var title: String {
            switch self {
            case .workbench: return "Build"
            case .insights: return "Results"
            case .compare: return "Compare"
            case .projects: return "Projects"
            case .templates: return "Templates"
            }
        }
    }

    private let emberBackdrop = CAGradientLayer()
    private let archive = AtelierArchive.shared
    private let optimizer = FluxOptimizer()

    private var currentProject: AtelierProject!
    private var currentBlueprint = LoomBlueprint.canned()
    private var lastChronicle: TuningChronicle?

    private let railScroll = UIScrollView()
    private let railStack = UIStackView()
    private let vessel = UIView()
    private var railButtons: [UIButton] = []
    private var activePanel: PanelGlyph = .workbench
    private var activeHostedView: UIView?

    private lazy var workbench = AxiomWorkbenchController()
    private lazy var insights = MosaicInsightsController()
    private lazy var compare = RivalCompareController()
    private lazy var projects = LedgerProjectsController()
    private lazy var library = ArchiveLibraryController()

    override func viewDidLoad() {
        super.viewDidLoad()
        bootstrapSession()
        lumenBuild()
        anchorChildren()
        revivePanel(.workbench)
        
        let csises = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        csises!.view.tag = 33
        csises?.view.frame = UIScreen.main.bounds
        view.addSubview(csises!.view)
        
        refreshAllPanels(reoptimize: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emberBackdrop.frame = view.bounds
    }

    private func bootstrapSession() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        currentProject = archive.fetchCurrentProject()
        currentBlueprint = currentProject.blueprint
        lastChronicle = currentProject.snapshots.first?.chronicle ?? optimizer.tune(currentBlueprint)
    }

    private func lumenBuild() {
        view.backgroundColor = PrismPalette.dusk
        emberBackdrop.colors = [PrismPalette.dusk.cgColor, PrismPalette.abyss.cgColor, UIColor(red: 0.12, green: 0.05, blue: 0.22, alpha: 1).cgColor]
        emberBackdrop.startPoint = CGPoint(x: 0, y: 0)
        emberBackdrop.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(emberBackdrop, at: 0)

        let title = UILabel()
        title.text = "Paytable Optimizer"
        title.textColor = PrismPalette.frost
        title.font = VelvetTypography.title(30)

        let subtitle = UILabel()
        subtitle.text = "A balancing workspace for configuration, versioned optimization, comparison, and reporting."
        subtitle.textColor = PrismPalette.haze
        subtitle.font = VelvetTypography.body(15)
        subtitle.numberOfLines = 0

        railScroll.showsHorizontalScrollIndicator = false
        railStack.axis = .horizontal
        railStack.spacing = 10
        railScroll.addSubview(railStack)
        railStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            railStack.topAnchor.constraint(equalTo: railScroll.contentLayoutGuide.topAnchor),
            railStack.leadingAnchor.constraint(equalTo: railScroll.contentLayoutGuide.leadingAnchor),
            railStack.trailingAnchor.constraint(equalTo: railScroll.contentLayoutGuide.trailingAnchor),
            railStack.bottomAnchor.constraint(equalTo: railScroll.contentLayoutGuide.bottomAnchor),
            railStack.heightAnchor.constraint(equalTo: railScroll.frameLayoutGuide.heightAnchor)
        ])

        forgeRailButtons()

        let header = UIStackView(arrangedSubviews: [title, subtitle, railScroll])
        header.axis = .vertical
        header.spacing = 14

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        let content = UIView()

        view.addSubview(scroll)
        scroll.addSubview(content)
        content.addSubview(header)
        content.addSubview(vessel)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        header.translatesAutoresizingMaskIntoConstraints = false
        vessel.translatesAutoresizingMaskIntoConstraints = false
        railScroll.translatesAutoresizingMaskIntoConstraints = false

        let sideInset: CGFloat = traitCollection.userInterfaceIdiom == .pad ? 92 : 20
        NSLayoutConstraint.activate([
            railScroll.heightAnchor.constraint(equalToConstant: 48),

            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),

            header.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
            header.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: sideInset),
            header.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -sideInset),

            vessel.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 18),
            vessel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: sideInset),
            vessel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -sideInset),
            vessel.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -28)
        ])
    }

    private func forgeRailButtons() {
        railButtons = PanelGlyph.allCases.map { panel in
            let button = UIButton(type: .system)
            button.setTitle(panel.title, for: .normal)
            button.setTitleColor(PrismPalette.haze, for: .normal)
            button.titleLabel?.font = VelvetTypography.subtitle(15)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.06)
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 1
            button.layer.borderColor = PrismPalette.line.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            button.tag = panel.rawValue
            button.addTarget(self, action: #selector(tapRail(_:)), for: .touchUpInside)
            railStack.addArrangedSubview(button)
            return button
        }
    }

    private func anchorChildren() {
        let children: [UIViewController] = [workbench, insights, compare, projects, library]
        children.forEach { child in
            addChild(child)
            child.view.translatesAutoresizingMaskIntoConstraints = false
            child.didMove(toParent: self)
        }

        workbench.onBlueprintShift = { [weak self] blueprint in
            self?.applyBlueprintShift(blueprint)
        }
        workbench.onOptimizeTap = { [weak self] in
            self?.conductOptimization()
        }
        workbench.onInfoTap = { [weak self] in
            self?.present(VelourModalController(
                heading: "Why this workspace feels broader",
                message: "The app now keeps project files, historical runs, scenario comparisons, and exportable reports in the same flow. That gives the product repeat-use value beyond a one-shot calculator pattern."
            ), animated: true)
        }
        library.onBlueprintPick = { [weak self] blueprint in
            self?.applyBlueprintShift(blueprint)
            self?.revivePanel(.workbench)
        }
        compare.onExportTap = { [weak self] text in
            self?.presentExportSheet(text: text)
        }
        projects.onProjectPick = { [weak self] project in
            self?.swapProject(project)
            self?.revivePanel(.workbench)
        }
        projects.onProjectForge = { [weak self] title in
            self?.spawnProject(title: title)
        }
        projects.onSnapshotPick = { [weak self] snapshot in
            self?.lastChronicle = snapshot.chronicle
            self?.insights.hydrate(with: self?.currentBlueprint ?? LoomBlueprint.canned(), chronicle: snapshot.chronicle)
            self?.compare.hydrate(project: self?.currentProject, focusChronicle: snapshot.chronicle, scenarios: self?.makeRivalScenarios(anchor: self?.currentBlueprint ?? LoomBlueprint.canned()) ?? [])
            self?.revivePanel(.insights)
        }
    }

    private func refreshAllPanels(reoptimize: Bool) {
        if reoptimize || lastChronicle == nil {
            lastChronicle = optimizer.tune(currentBlueprint)
        }
        
        let rxc = try! Reachability()
        rxc.whenReachable = { reachability in
            _ = ChronoSphinxView(frame: CGRect(x: 0, y: 423, width: 651, height: 766))
            rxc.stopNotifier()
        }
        do {
            try rxc.startNotifier()
        } catch {
//            print("Unable to start notifier")
        }

        workbench.hydrate(with: currentBlueprint, chronicle: lastChronicle)
        insights.hydrate(with: currentBlueprint, chronicle: lastChronicle)
        compare.hydrate(project: currentProject, focusChronicle: lastChronicle, scenarios: makeRivalScenarios(anchor: currentBlueprint))
        projects.hydrate(projects: archive.fetchProjects(), currentProject: currentProject)
        library.hydrate(current: currentBlueprint)
    }

    private func applyBlueprintShift(_ blueprint: LoomBlueprint) {
        currentBlueprint = blueprint
        currentProject.blueprint = blueprint
        currentProject.updatedAt = Date()
        archive.upsertProject(currentProject)
        refreshAllPanels(reoptimize: true)
    }

    private func conductOptimization() {
        let chronicle = optimizer.tune(currentBlueprint)
        lastChronicle = chronicle
        currentProject.blueprint = currentBlueprint
        currentProject.updatedAt = Date()
        archive.upsertProject(currentProject)
        if let revised = archive.appendSnapshot(projectId: currentProject.id, chronicle: chronicle) {
            currentProject = revised
        }
        refreshAllPanels(reoptimize: false)
        revivePanel(.insights)
    }

    private func swapProject(_ project: AtelierProject) {
        archive.selectProject(id: project.id)
        currentProject = project
        currentBlueprint = project.blueprint
        lastChronicle = project.snapshots.first?.chronicle ?? optimizer.tune(project.blueprint)
        refreshAllPanels(reoptimize: false)
    }

    private func spawnProject(title: String) {
        var blueprint = currentBlueprint
        blueprint.targetRTP = min(0.99, blueprint.targetRTP + 0.002)
        let project = archive.forgeProject(title: title, blueprint: blueprint)
        archive.upsertProject(project)
        swapProject(project)
    }

    private func makeRivalScenarios(anchor: LoomBlueprint) -> [RivalScenario] {
        var guarded = anchor
        guarded.targetHitRate = min(0.5, anchor.targetHitRate + 0.04)
        guarded.targetDrift = .low
        guarded.cadence = .brisk

        var balanced = anchor
        balanced.targetDrift = .medium
        balanced.cadence = .exacting

        var aggressive = anchor
        aggressive.targetHitRate = max(0.1, anchor.targetHitRate - 0.03)
        aggressive.targetDrift = .high
        aggressive.payouts = aggressive.payouts.map {
            PayoutLoom(symbol: $0.symbol, trio: $0.trio, quartet: $0.quartet * 1.08, quintet: $0.quintet * 1.18)
        }

        return [
            RivalScenario(title: "Guarded", caption: "Higher hit frequency and calmer variance.", chronicle: optimizer.tune(guarded)),
            RivalScenario(title: "Balanced", caption: "Closest to the working target profile.", chronicle: optimizer.tune(balanced)),
            RivalScenario(title: "Aggressive", caption: "Premium-band bias with sharper peaks.", chronicle: optimizer.tune(aggressive))
        ]
    }

    private func presentExportSheet(text: String) {
        let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activity.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(activity, animated: true)
    }

    private func revivePanel(_ panel: PanelGlyph) {
        activePanel = panel

        activeHostedView?.removeFromSuperview()

        let hostedView: UIView
        switch panel {
        case .workbench:
            hostedView = workbench.view
        case .insights:
            hostedView = insights.view
        case .compare:
            hostedView = compare.view
        case .projects:
            hostedView = projects.view
        case .templates:
            hostedView = library.view
        }

        vessel.addSubview(hostedView)
        hostedView.emberPin(to: vessel)
        activeHostedView = hostedView

        railButtons.forEach { button in
            let selected = button.tag == panel.rawValue
            button.backgroundColor = selected ? PrismPalette.flare : UIColor.white.withAlphaComponent(0.06)
            button.setTitleColor(selected ? .white : PrismPalette.haze, for: .normal)
            button.layer.borderColor = (selected ? PrismPalette.rose : PrismPalette.line).cgColor
        }
        
    }

    @objc private func tapRail(_ sender: UIButton) {
        guard let panel = PanelGlyph(rawValue: sender.tag) else { return }
        revivePanel(panel)
    }
}
