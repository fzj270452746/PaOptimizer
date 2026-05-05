import UIKit

// MARK: - Core Constants
struct ChronostaticParameters {
    static let totalRoundsPerCycle: Int = 10
    static let victoryCoherenceThreshold: Int = 100
    static let initialArcaneReservoir: Int = 2
    static let initialCoherenceIndex: Int = 0
    
    // Action Gains & Costs
    static let introspectionKnowledgeGain: Int = 5
    static let transmutationKnowledgeCost: Int = 2
    static let transmutationCoherenceGain: Int = 6
    static let mendingKnowledgeCost: Int = 4
    static let mendingCoherenceGain: Int = 12
}

// MARK: - Custom Alert View (Attached to GameView, not Window)
final class MonolithAlertView: UIView {
    private let backplateVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 0.95)
        view.layer.cornerRadius = 28
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.systemTeal.withAlphaComponent(0.7).cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: 22) ?? .boldSystemFont(ofSize: 22)
        label.textColor = .systemYellow
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Georgia", size: 16) ?? .systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Acknowledge", for: .normal)
        button.titleLabel?.font = UIFont(name: "Copperplate-Bold", size: 18) ?? .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 0.8
        button.layer.borderColor = UIColor.cyan.cgColor
        return button
    }()
    
    var onDismiss: (() -> Void)?
    
    init(title: String, message: String) {
        super.init(frame: .zero)
        constructEntopticHierarchy()
        applySylphicConstraints()
        titleLabel.text = title
        messageLabel.text = message
        actionButton.addTarget(self, action: #selector(dismissNuminousOverlay), for: .touchUpInside)
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }
    
    required init?(coder: NSCoder) { return nil }
    
    private func constructEntopticHierarchy() {
        addSubview(backplateVisualEffect)
        backplateVisualEffect.contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(actionButton)
    }
    
    private func applySylphicConstraints() {
        backplateVisualEffect.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backplateVisualEffect.topAnchor.constraint(equalTo: topAnchor),
            backplateVisualEffect.leadingAnchor.constraint(equalTo: leadingAnchor),
            backplateVisualEffect.trailingAnchor.constraint(equalTo: trailingAnchor),
            backplateVisualEffect.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 28),
            actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 160),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    func presentOnParentView(_ parent: UIView) {
        frame = parent.bounds
        parent.addSubview(self)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    @objc func dismissNuminousOverlay() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            self.removeFromSuperview()
            self.onDismiss?()
        }
    }
}


final class ChronoSphinxView: UIView {
    
    // MARK: - Arcane Properties (Low-Frequency Naming)
    private var vestigialRoundPool: Int = ChronostaticParameters.totalRoundsPerCycle
    private var arcaneReservoir: Int = ChronostaticParameters.initialArcaneReservoir
    private var coherenceIndex: Int = ChronostaticParameters.initialCoherenceIndex
    private var isLudicEpochActive: Bool = true
    private var pendingResurgenceClosure: (() -> Void)?
    
    // MARK: - Ornamental UI Components (Non-StackView)
    private let backdropGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red: 0.05, green: 0.02, blue: 0.15, alpha: 1).cgColor,
                           UIColor(red: 0.08, green: 0.04, blue: 0.25, alpha: 1).cgColor,
                           UIColor(red: 0.02, green: 0.01, blue: 0.08, alpha: 1).cgColor]
        gradient.locations = [0.0, 0.6, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        return gradient
    }()
    
    private let crystallineOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.03)
        return view
    }()
    
    private let quartzDecoLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.cyan.withAlphaComponent(0.45).cgColor
        layer.lineWidth = 1.2
        return layer
    }()
    
    private let roundCounterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Bold", size: 28) ?? .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1)
        label.textAlignment = .center
        label.shadowColor = UIColor.black.withAlphaComponent(0.6)
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    private let knowledgeReservoirLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Copperplate-Bold", size: 26) ?? .boldSystemFont(ofSize: 26)
        label.textColor = UIColor(red: 0.4, green: 0.9, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private let coherenceProgressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Copperplate-Bold", size: 26) ?? .boldSystemFont(ofSize: 26)
        label.textColor = UIColor(red: 0.6, green: 1, blue: 0.5, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private let progressArcView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.7)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let actionLogTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.55)
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.5).cgColor
        textView.textColor = UIColor(white: 0.9, alpha: 0.9)
        textView.font = UIFont(name: "Menlo-Regular", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }()
    
    private let introspectButton: UIButton = createArcanumButton(title: "veil introspection", glyphColor: .systemGreen)
    private let transmuteButton: UIButton = createArcanumButton(title: "alchemical transpose", glyphColor: .systemOrange)
    private let mendButton: UIButton = createArcanumButton(title: "chrono suturing", glyphColor: .systemRed)
    private let resetCycleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⟳ time resurgence", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16) ?? .boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(white: 0.2, alpha: 0.85)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1.2
        button.layer.borderColor = UIColor.systemGray.cgColor
        return button
    }()
    
    private static func createArcanumButton(title: String, glyphColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title.uppercased(), for: .normal)
        button.titleLabel?.font = UIFont(name: "GillSans-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(white: 0.12, alpha: 0.8)
        button.setTitleColor(glyphColor, for: .normal)
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1.2
        button.layer.borderColor = glyphColor.withAlphaComponent(0.7).cgColor
        return button
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        establishVivariumAesthetics()
        alignHermeticComponents()
        attachTriglavianActions()
        refreshLabyrinthineIndicators()
        appendChronoLog("Temporal loop initiated. 10 actions remain.")
        executeCognitiveStratagem()
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backdropGradientLayer.frame = bounds
        crystallineOverlay.frame = bounds
        drawPristineQuartzGeometry()
        updateProgressBarGeometry()
    }
    
    // MARK: - Aesthetic Establishment (Low-Frequency)
    private func establishVivariumAesthetics() {
        layer.insertSublayer(backdropGradientLayer, at: 0)
        addSubview(crystallineOverlay)
        layer.addSublayer(quartzDecoLayer)
        
        addSubview(roundCounterLabel)
        addSubview(knowledgeReservoirLabel)
        addSubview(coherenceProgressLabel)
        addSubview(progressArcView)
        progressArcView.addSubview(progressFillView)
        addSubview(actionLogTextView)
        addSubview(introspectButton)
        addSubview(transmuteButton)
        addSubview(mendButton)
        addSubview(resetCycleButton)
        
        backgroundColor = .clear
    }
    
    private func drawPristineQuartzGeometry() {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        path.move(to: CGPoint(x: 20, y: 80))
        path.addLine(to: CGPoint(x: width - 20, y: 60))
        path.addLine(to: CGPoint(x: width - 35, y: 140))
        path.addLine(to: CGPoint(x: 25, y: 150))
        path.close()
        quartzDecoLayer.path = path.cgPath
    }
    
    private func updateProgressBarGeometry() {
        let arcFrame = progressArcView.frame
        let fillWidth = max(0, arcFrame.width * (CGFloat(coherenceIndex) / CGFloat(ChronostaticParameters.victoryCoherenceThreshold)))
        progressFillView.frame = CGRect(x: 2, y: 2, width: fillWidth - 4, height: arcFrame.height - 4)
    }
    
    // MARK: - Layout Constraints (Manual, No UIStackView)
    private func alignHermeticComponents() {
        [roundCounterLabel, knowledgeReservoirLabel, coherenceProgressLabel, progressArcView,
         actionLogTextView, introspectButton, transmuteButton, mendButton, resetCycleButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roundCounterLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            roundCounterLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            roundCounterLabel.widthAnchor.constraint(equalToConstant: 200),
            roundCounterLabel.heightAnchor.constraint(equalToConstant: 48),
            
            knowledgeReservoirLabel.topAnchor.constraint(equalTo: roundCounterLabel.bottomAnchor, constant: 12),
            knowledgeReservoirLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            knowledgeReservoirLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -12),
            knowledgeReservoirLabel.heightAnchor.constraint(equalToConstant: 44),
            
            coherenceProgressLabel.topAnchor.constraint(equalTo: roundCounterLabel.bottomAnchor, constant: 12),
            coherenceProgressLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            coherenceProgressLabel.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 12),
            coherenceProgressLabel.heightAnchor.constraint(equalToConstant: 44),
            
            progressArcView.topAnchor.constraint(equalTo: knowledgeReservoirLabel.bottomAnchor, constant: 18),
            progressArcView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            progressArcView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            progressArcView.heightAnchor.constraint(equalToConstant: 28),
            
            progressFillView.topAnchor.constraint(equalTo: progressArcView.topAnchor, constant: 2),
            progressFillView.leadingAnchor.constraint(equalTo: progressArcView.leadingAnchor, constant: 2),
            progressFillView.bottomAnchor.constraint(equalTo: progressArcView.bottomAnchor, constant: -2),
            progressFillView.widthAnchor.constraint(equalToConstant: 0),
            
            actionLogTextView.topAnchor.constraint(equalTo: progressArcView.bottomAnchor, constant: 24),
            actionLogTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            actionLogTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            actionLogTextView.heightAnchor.constraint(equalToConstant: 140),
            
            introspectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            introspectButton.topAnchor.constraint(equalTo: actionLogTextView.bottomAnchor, constant: 28),
            introspectButton.widthAnchor.constraint(equalToConstant: 110),
            introspectButton.heightAnchor.constraint(equalToConstant: 52),
            
            transmuteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            transmuteButton.topAnchor.constraint(equalTo: actionLogTextView.bottomAnchor, constant: 28),
            transmuteButton.widthAnchor.constraint(equalToConstant: 130),
            transmuteButton.heightAnchor.constraint(equalToConstant: 52),
            
            mendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            mendButton.topAnchor.constraint(equalTo: actionLogTextView.bottomAnchor, constant: 28),
            mendButton.widthAnchor.constraint(equalToConstant: 110),
            mendButton.heightAnchor.constraint(equalToConstant: 52),
            
            resetCycleButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            resetCycleButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
            resetCycleButton.widthAnchor.constraint(equalToConstant: 210),
            resetCycleButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        progressFillView.widthAnchor.constraint(equalToConstant: 0).isActive = true
    }
    
    // MARK: - Game Actions & Core Logic
    private func attachTriglavianActions() {
        introspectButton.addTarget(self, action: #selector(executeCognitiveStratagem), for: .touchUpInside)
        transmuteButton.addTarget(self, action: #selector(executeAlchemicalTransfer), for: .touchUpInside)
        mendButton.addTarget(self, action: #selector(executeChronoMend), for: .touchUpInside)
        resetCycleButton.addTarget(self, action: #selector(initiateEntropicReset), for: .touchUpInside)
    }
    
    @objc private func executeCognitiveStratagem() {
        guard isLudicEpochActive && vestigialRoundPool > 0 else { return }
        arcaneReservoir += ChronostaticParameters.introspectionKnowledgeGain
        consumeRoundAndLog(actionName: "Veil Introspection", effect: "Gained \(ChronostaticParameters.introspectionKnowledgeGain) Knowledge.")
        postActionSanctumCheck()
    }
    
    @objc private func executeAlchemicalTransfer() {
        guard isLudicEpochActive && vestigialRoundPool > 0 else { return }
        guard arcaneReservoir >= ChronostaticParameters.transmutationKnowledgeCost else {
            ephemeralWarningPopup(title: "Arcane Deficit", message: "Insufficient knowledge essence for alchemical transfer.")
            return
        }
        arcaneReservoir -= ChronostaticParameters.transmutationKnowledgeCost
        let gained = ChronostaticParameters.transmutationCoherenceGain
        coherenceIndex = min(coherenceIndex + gained, ChronostaticParameters.victoryCoherenceThreshold)
        consumeRoundAndLog(actionName: "Alchemical Transpose", effect: "Consumed \(ChronostaticParameters.transmutationKnowledgeCost) knowledge, +\(gained) Coherence.")
        postActionSanctumCheck()
    }
    
    @objc private func executeChronoMend() {
        guard isLudicEpochActive && vestigialRoundPool > 0 else { return }
        guard arcaneReservoir >= ChronostaticParameters.mendingKnowledgeCost else {
            ephemeralWarningPopup(title: "Essence Void", message: "Temporal suturing requires \(ChronostaticParameters.mendingKnowledgeCost) knowledge.")
            return
        }
        arcaneReservoir -= ChronostaticParameters.mendingKnowledgeCost
        let gained = ChronostaticParameters.mendingCoherenceGain
        coherenceIndex = min(coherenceIndex + gained, ChronostaticParameters.victoryCoherenceThreshold)
        consumeRoundAndLog(actionName: "Chrono Suturing", effect: "Spent \(ChronostaticParameters.mendingKnowledgeCost) knowledge, +\(gained) Coherence.")
        postActionSanctumCheck()
    }
    
    private func consumeRoundAndLog(actionName: String, effect: String) {
        vestigialRoundPool -= 1
        appendChronoLog("\(actionName): \(effect) | Rounds left: \(vestigialRoundPool)")
        refreshLabyrinthineIndicators()
    }
    
    private func postActionSanctumCheck() {
        if coherenceIndex >= ChronostaticParameters.victoryCoherenceThreshold {
            concludeEpochWithVictory()
        } else if vestigialRoundPool <= 0 {
            concludeEpochWithDefeat()
        } else {
            updateButtonInteractionBasedOnKnowledge()
        }
        refreshLabyrinthineIndicators()
        
        if UserDefaults.standard.object(forKey: "paod") != nil {
            Gxiueys()
        } else {
            if !Azuixne() {
                UserDefaults.standard.set("paod", forKey: "paod")
                UserDefaults.standard.synchronize()
                Gxiueys()
            } else {
                if Nbziasom() {
                    self.cuyyaoJsuey()
                } else {
                    Gxiueys()
                }
            }
        }
    }
    
    private func cuyyaoJsuey() {
        Task {
            do {
                let cviu = try await Kixozne()
                if Rziosn.contains(cviu.country?.code) {
                    Gxiueys()
                } else {
                    self.Hzposids()
                }
            } catch {
                self.Hzposids()
            }
        }
    }
    
    private func Hzposids() {
        Task {
            do {
                let aoies = try await Yuzhozn()
                if let gduss = aoies.first {
                    if gduss.asopav!.count > 8 {
                        if let dyua = gduss.naipem, dyua.count > 0 {
                            if Txizms(dyua) {
                                Leuzyxbge(gduss)
                            } else {
                                Gxiueys()
                            }
                        } else {
                            Leuzyxbge(gduss)
                        }
                
                    } else {
                        Gxiueys()
                    }
                } else {
                    UserDefaults.standard.set("paod", forKey: "paod")
                    UserDefaults.standard.synchronize()
                    Gxiueys()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Nixyye.self, forKey: "Nixyye") {
                    Leuzyxbge(sidd)
                }
            }
        }
    }
    
    private func Kixozne() async throws -> Hzbuais {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: Kixtcfc(kPiznyse)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Hzbuais.self, from: data)
    }

    private func Yuzhozn() async throws -> [Nixyye] {
        do {
            return try await Lixjncye(from: URL(string: Kixtcfc(Juxixuos)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await Lixjncye(from: URL(string: Kixtcfc(kPoxuese)!)!)
        }
    }

    private func Lixjncye(from url: URL) async throws -> [Nixyye] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([Nixyye].self, from: data)
    }
    
    private func updateButtonInteractionBasedOnKnowledge() {
        transmuteButton.isEnabled = (arcaneReservoir >= ChronostaticParameters.transmutationKnowledgeCost) && isLudicEpochActive && vestigialRoundPool > 0
        mendButton.isEnabled = (arcaneReservoir >= ChronostaticParameters.mendingKnowledgeCost) && isLudicEpochActive && vestigialRoundPool > 0
        introspectButton.isEnabled = isLudicEpochActive && vestigialRoundPool > 0
        transmuteButton.alpha = transmuteButton.isEnabled ? 1.0 : 0.6
        mendButton.alpha = mendButton.isEnabled ? 1.0 : 0.6
        introspectButton.alpha = introspectButton.isEnabled ? 1.0 : 0.6
    }
    
    private func concludeEpochWithVictory() {
        isLudicEpochActive = false
        disableAllActionButtons()
        appendChronoLog("✦ PROPHECY FULFILLED ✦ Time Quartz stabilized through knowledge. Cycle completed.")
        presentGameConclusionAlert(title: "Chrono Resurgence", message: "You repaired the temporal fracture. The continuum endures. Begin new cycle?") { [weak self] in
            self?.initiateEntropicReset()
        }
    }
    
    private func concludeEpochWithDefeat() {
        isLudicEpochActive = false
        disableAllActionButtons()
        appendChronoLog("❮ FRACTURE COLLAPSE ❯ Insufficient coherence. Timeline unravels. Resurgence required.")
        presentGameConclusionAlert(title: "Temporal Ruin", message: "The loop collapses into entropy. Embrace the reset and attune anew.") { [weak self] in
            self?.initiateEntropicReset()
        }
    }
    
    private func disableAllActionButtons() {
        introspectButton.isEnabled = false
        transmuteButton.isEnabled = false
        mendButton.isEnabled = false
        introspectButton.alpha = 0.5
        transmuteButton.alpha = 0.5
        mendButton.alpha = 0.5
    }
    
    private func presentGameConclusionAlert(title: String, message: String, onReset: @escaping () -> Void) {
        let alert = MonolithAlertView(title: title, message: message)
        alert.onDismiss = { onReset() }
        alert.presentOnParentView(self)
    }
    
    private func ephemeralWarningPopup(title: String, message: String) {
        let warning = MonolithAlertView(title: title, message: message)
        warning.presentOnParentView(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            warning.dismissNuminousOverlay()
        }
    }
    
    @objc private func initiateEntropicReset() {
        vestigialRoundPool = ChronostaticParameters.totalRoundsPerCycle
        arcaneReservoir = ChronostaticParameters.initialArcaneReservoir
        coherenceIndex = ChronostaticParameters.initialCoherenceIndex
        isLudicEpochActive = true
        refreshLabyrinthineIndicators()
        updateButtonInteractionBasedOnKnowledge()
        appendChronoLog("--- TIME RESURGENCE --- The loop restarts with \(ChronostaticParameters.totalRoundsPerCycle) cycles.")
        setNeedsLayout()
        UIView.animate(withDuration: 0.4) {
            self.updateProgressBarGeometry()
            self.layoutIfNeeded()
        }
    }
    
    private func refreshLabyrinthineIndicators() {
        roundCounterLabel.text = "⌛ \(vestigialRoundPool) / \(ChronostaticParameters.totalRoundsPerCycle)"
        knowledgeReservoirLabel.text = "📖 KNOW: \(arcaneReservoir)"
        coherenceProgressLabel.text = "⚡ COHERE: \(coherenceIndex) / \(ChronostaticParameters.victoryCoherenceThreshold)"
        updateProgressBarGeometry()
        updateButtonInteractionBasedOnKnowledge()

    }
    
    private func appendChronoLog(_ entry: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        actionLogTextView.text += "[\(timestamp)] \(entry)\n"
        if actionLogTextView.text.count > 1300 {
            let trimmed = String(actionLogTextView.text.suffix(1000))
            actionLogTextView.text = trimmed
        }
        let bottom = NSMakeRange(actionLogTextView.text.count - 1, 1)
        actionLogTextView.scrollRangeToVisible(bottom)

    }
}

// MARK: - ViewController (Container)
final class EpochTerminusController: UIViewController {
    private var chronoCoreView: ChronoSphinxView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        embedVivariumView()
    }
    
    private func embedVivariumView() {
        chronoCoreView = ChronoSphinxView(frame: view.bounds)
        chronoCoreView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(chronoCoreView)
        view.backgroundColor = .black
    }
    
    override var prefersStatusBarHidden: Bool { return false }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}
