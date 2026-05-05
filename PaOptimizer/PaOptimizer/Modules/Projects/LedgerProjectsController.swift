import UIKit

final class LedgerProjectsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var onProjectPick: ((AtelierProject) -> Void)?
    var onProjectForge: ((String) -> Void)?
    var onSnapshotPick: ((ScribeSnapshot) -> Void)?

    private var projects: [AtelierProject] = []
    private var currentProject: AtelierProject?

    private let table = IntrinsicTableView(frame: .zero, style: .insetGrouped)
    private let forgeField = UITextField()

    func hydrate(projects: [AtelierProject], currentProject: AtelierProject?) {
        self.projects = projects
        self.currentProject = currentProject
        table.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        marbleBuild()
    }

    private func marbleBuild() {
        view.backgroundColor = .clear

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.emberPin(to: view)

        stack.addArrangedSubview(forgeCard())
        stack.addArrangedSubview(tableCard())
    }

    private func forgeCard() -> UIView {
        let card = NebulaCard()
        let title = UILabel()
        title.text = "Project Center"
        title.font = VelvetTypography.title(22)
        title.textColor = PrismPalette.frost

        let body = UILabel()
        body.text = "Keep reusable projects and historical optimization runs so the app behaves like a repeat-use workspace, not a single transient utility."
        body.font = VelvetTypography.body(14)
        body.textColor = PrismPalette.haze
        body.numberOfLines = 0

        forgeField.borderStyle = .none
        forgeField.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        forgeField.layer.cornerRadius = 14
        forgeField.textColor = PrismPalette.frost
        forgeField.font = VelvetTypography.body(15)
        forgeField.placeholder = "New project title"
        forgeField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        forgeField.leftViewMode = .always
        forgeField.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let forgeButton = GlintButton()
        forgeButton.tincture(title: "Create Project", accent: [PrismPalette.flare, PrismPalette.rose])
        forgeButton.addTarget(self, action: #selector(tapForge), for: .touchUpInside)

        let host = UIStackView(arrangedSubviews: [title, body, forgeField, forgeButton])
        host.axis = .vertical
        host.spacing = 12
        card.quasarContent.addSubview(host)
        host.emberPin(to: card.quasarContent)
        return card
    }

    private func tableCard() -> UIView {
        let card = NebulaCard()

        table.backgroundColor = .clear
        table.separatorColor = PrismPalette.line
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ledger")
        table.rowHeight = 72
        table.isScrollEnabled = false

        card.quasarContent.addSubview(table)
        table.emberPin(to: card.quasarContent)
        return card
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return projects.count
        }
        return currentProject?.snapshots.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Projects" : "Run History"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ledger", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()

        if indexPath.section == 0 {
            let project = projects[indexPath.row]
            config.text = project.title
            config.secondaryText = "\(project.blueprint.lattice.rawValue) · \(project.blueprint.reelCount) reels · \(project.snapshots.count) runs"
            config.image = project.id == currentProject?.id ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
            config.imageProperties.tintColor = project.id == currentProject?.id ? PrismPalette.mint : PrismPalette.haze
        } else if let snapshot = currentProject?.snapshots[indexPath.row] {
            config.text = snapshot.label
            config.secondaryText = snapshot.summary
            config.image = UIImage(systemName: "clock.arrow.circlepath")
            config.imageProperties.tintColor = PrismPalette.amber
        }

        config.textProperties.color = PrismPalette.frost
        config.secondaryTextProperties.color = PrismPalette.haze
        cell.contentConfiguration = config
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            onProjectPick?(projects[indexPath.row])
            return
        }
        if let snapshot = currentProject?.snapshots[indexPath.row] {
            onSnapshotPick?(snapshot)
        }
    }

    @objc private func tapForge() {
        let trimmed = (forgeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let title = trimmed.isEmpty ? "Scenario \(projects.count + 1)" : trimmed
        onProjectForge?(title)
        forgeField.text = nil
    }
}
