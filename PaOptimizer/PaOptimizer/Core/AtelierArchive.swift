import Foundation

final class AtelierArchive {
    static let shared = AtelierArchive()

    private let ledger = UserDefaults.standard
    private let projectPayloadKey = "atelier.projectPayloadKey"
    private let currentProjectKey = "atelier.currentProjectKey"

    private init() {}

    func fetchProjects() -> [AtelierProject] {
        guard let payloads = ledger.array(forKey: projectPayloadKey) as? [[String: Any]] else {
            let seed = seededProjects()
            storeProjects(seed)
            ledger.set(seed.first?.id, forKey: currentProjectKey)
            return seed
        }

        let decoded = payloads.compactMap(project(from:))
        if decoded.isEmpty {
            let seed = seededProjects()
            storeProjects(seed)
            ledger.set(seed.first?.id, forKey: currentProjectKey)
            return seed
        }

        return decoded.sorted { $0.updatedAt > $1.updatedAt }
    }

    func fetchCurrentProject() -> AtelierProject {
        let projects = fetchProjects()
        guard let currentId = ledger.string(forKey: currentProjectKey),
              let current = projects.first(where: { $0.id == currentId }) else {
            let fallback = projects[0]
            ledger.set(fallback.id, forKey: currentProjectKey)
            return fallback
        }
        return current
    }

    func selectProject(id: String) {
        ledger.set(id, forKey: currentProjectKey)
    }

    func upsertProject(_ project: AtelierProject) {
        var projects = fetchProjects()
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.append(project)
        }
        storeProjects(projects.sorted { $0.updatedAt > $1.updatedAt })
    }

    func forgeProject(title: String, blueprint: LoomBlueprint) -> AtelierProject {
        let now = Date()
        return AtelierProject(
            id: UUID().uuidString,
            title: title,
            createdAt: now,
            updatedAt: now,
            blueprint: blueprint,
            snapshots: []
        )
    }

    func appendSnapshot(projectId: String, chronicle: TuningChronicle) -> AtelierProject? {
        var projects = fetchProjects()
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return nil }

        var project = projects[index]
        let stamp = Date()
        let label = "Run \(project.snapshots.count + 1)"
        let summary = "RTP \(percent(chronicle.optimizedMetrics.rtp)) · Hit \(percent(chronicle.optimizedMetrics.hitRate)) · Var \(chronicle.optimizedMetrics.driftCaption)"
        let snapshot = ScribeSnapshot(id: UUID().uuidString, stamp: stamp, label: label, summary: summary, chronicle: chronicle)
        project.snapshots.insert(snapshot, at: 0)
        project.updatedAt = stamp
        projects[index] = project
        storeProjects(projects.sorted { $0.updatedAt > $1.updatedAt })
        return project
    }

    private func storeProjects(_ projects: [AtelierProject]) {
        let payloads = projects.map(payload(from:))
        ledger.set(payloads, forKey: projectPayloadKey)
    }

    private func payload(from project: AtelierProject) -> [String: Any] {
        [
            "id": project.id,
            "title": project.title,
            "createdAt": project.createdAt.timeIntervalSince1970,
            "updatedAt": project.updatedAt.timeIntervalSince1970,
            "blueprint": payload(from: project.blueprint),
            "snapshots": project.snapshots.map(snapshotPayload(from:))
        ]
    }

    private func project(from payload: [String: Any]) -> AtelierProject? {
        guard let id = payload["id"] as? String,
              let title = payload["title"] as? String,
              let createdAtValue = payload["createdAt"] as? TimeInterval,
              let updatedAtValue = payload["updatedAt"] as? TimeInterval,
              let blueprintPayload = payload["blueprint"] as? [String: Any],
              let blueprint = blueprint(from: blueprintPayload) else {
            return nil
        }

        let snapshotPayloads = payload["snapshots"] as? [[String: Any]] ?? []
        let snapshots = snapshotPayloads.compactMap(snapshot(from:))

        return AtelierProject(
            id: id,
            title: title,
            createdAt: Date(timeIntervalSince1970: createdAtValue),
            updatedAt: Date(timeIntervalSince1970: updatedAtValue),
            blueprint: blueprint,
            snapshots: snapshots
        )
    }

    private func payload(from blueprint: LoomBlueprint) -> [String: Any] {
        let glyphs: [[String: Any]] = blueprint.tokens.map {
            ["id": $0.id, "kind": $0.kind.rawValue, "baseWeight": $0.baseWeight, "isAdjustable": $0.isAdjustable]
        }
        let payouts: [[String: Any]] = blueprint.payouts.map {
            ["symbol": $0.symbol, "trio": $0.trio, "quartet": $0.quartet, "quintet": $0.quintet]
        }

        return [
            "reelCount": blueprint.reelCount,
            "reelLength": blueprint.reelLength,
            "lattice": blueprint.lattice.rawValue,
            "tokens": glyphs,
            "payouts": payouts,
            "targetRTP": blueprint.targetRTP,
            "targetHitRate": blueprint.targetHitRate,
            "targetDrift": blueprint.targetDrift.rawValue,
            "cadence": blueprint.cadence.rawValue,
            "floorPayout": blueprint.constraints.floorPayout,
            "ceilingPayout": blueprint.constraints.ceilingPayout,
            "ordinalRules": blueprint.constraints.ordinalRules
        ]
    }

    private func blueprint(from payload: [String: Any]) -> LoomBlueprint? {
        let glyphs = (payload["tokens"] as? [[String: Any]] ?? []).compactMap { node -> RuneToken? in
            guard let id = node["id"] as? String,
                  let kindRaw = node["kind"] as? String,
                  let kind = SigilGlyph(rawValue: kindRaw),
                  let weight = node["baseWeight"] as? Double,
                  let adjustable = node["isAdjustable"] as? Bool else {
                return nil
            }
            return RuneToken(id: id, kind: kind, baseWeight: weight, isAdjustable: adjustable)
        }
        let payouts = (payload["payouts"] as? [[String: Any]] ?? []).compactMap { node -> PayoutLoom? in
            guard let symbol = node["symbol"] as? String,
                  let trio = node["trio"] as? Double,
                  let quartet = node["quartet"] as? Double,
                  let quintet = node["quintet"] as? Double else {
                return nil
            }
            return PayoutLoom(symbol: symbol, trio: trio, quartet: quartet, quintet: quintet)
        }
        guard let latticeRaw = payload["lattice"] as? String,
              let lattice = LatticeFlavor(rawValue: latticeRaw),
              let driftRaw = payload["targetDrift"] as? String,
              let drift = DriftGrade(rawValue: driftRaw),
              let cadenceRaw = payload["cadence"] as? String,
              let cadence = PulseCadence(rawValue: cadenceRaw) else {
            return nil
        }

        return LoomBlueprint(
            reelCount: payload["reelCount"] as? Int ?? 5,
            reelLength: payload["reelLength"] as? Int ?? 48,
            lattice: lattice,
            tokens: glyphs.isEmpty ? LoomBlueprint.canned().tokens : glyphs,
            payouts: payouts.isEmpty ? LoomBlueprint.canned().payouts : payouts,
            targetRTP: payload["targetRTP"] as? Double ?? 0.96,
            targetHitRate: payload["targetHitRate"] as? Double ?? 0.25,
            targetDrift: drift,
            cadence: cadence,
            constraints: ConstraintVeil(
                floorPayout: payload["floorPayout"] as? Double ?? 2,
                ceilingPayout: payload["ceilingPayout"] as? Double ?? 1000,
                ordinalRules: payload["ordinalRules"] as? [String] ?? ["J < Q < K < A < W"]
            )
        )
    }

    private func snapshotPayload(from snapshot: ScribeSnapshot) -> [String: Any] {
        let chronicle = snapshot.chronicle
        return [
            "id": snapshot.id,
            "stamp": snapshot.stamp.timeIntervalSince1970,
            "label": snapshot.label,
            "summary": snapshot.summary,
            "blueprint": payload(from: chronicle.blueprint),
            "initialMetrics": metricsPayload(from: chronicle.initialMetrics),
            "optimizedMetrics": metricsPayload(from: chronicle.optimizedMetrics),
            "optimizedPayouts": chronicle.optimizedPayouts.map { ["symbol": $0.symbol, "trio": $0.trio, "quartet": $0.quartet, "quintet": $0.quintet] },
            "pulses": chronicle.pulses.map { ["step": $0.step, "rtp": $0.rtp, "variance": $0.variance, "hitRate": $0.hitRate] },
            "slices": chronicle.slices.map { ["band": $0.band, "legacy": $0.legacy, "tuned": $0.tuned] },
            "notes": chronicle.notes
        ]
    }

    private func snapshot(from payload: [String: Any]) -> ScribeSnapshot? {
        guard let id = payload["id"] as? String,
              let stampValue = payload["stamp"] as? TimeInterval,
              let label = payload["label"] as? String,
              let summary = payload["summary"] as? String,
              let blueprintPayload = payload["blueprint"] as? [String: Any],
              let blueprint = blueprint(from: blueprintPayload),
              let initialPayload = payload["initialMetrics"] as? [String: Any],
              let optimizedPayload = payload["optimizedMetrics"] as? [String: Any],
              let initialMetrics = metrics(from: initialPayload),
              let optimizedMetrics = metrics(from: optimizedPayload) else {
            return nil
        }

        let optimizedPayouts = (payload["optimizedPayouts"] as? [[String: Any]] ?? []).compactMap { node -> PayoutLoom? in
            guard let symbol = node["symbol"] as? String,
                  let trio = node["trio"] as? Double,
                  let quartet = node["quartet"] as? Double,
                  let quintet = node["quintet"] as? Double else {
                return nil
            }
            return PayoutLoom(symbol: symbol, trio: trio, quartet: quartet, quintet: quintet)
        }

        let pulses = (payload["pulses"] as? [[String: Any]] ?? []).compactMap { node -> IterationPulse? in
            guard let step = node["step"] as? Int,
                  let rtp = node["rtp"] as? Double,
                  let variance = node["variance"] as? Double,
                  let hitRate = node["hitRate"] as? Double else {
                return nil
            }
            return IterationPulse(step: step, rtp: rtp, variance: variance, hitRate: hitRate)
        }

        let slices = (payload["slices"] as? [[String: Any]] ?? []).compactMap { node -> WinSlice? in
            guard let band = node["band"] as? String,
                  let legacy = node["legacy"] as? Double,
                  let tuned = node["tuned"] as? Double else {
                return nil
            }
            return WinSlice(band: band, legacy: legacy, tuned: tuned)
        }

        let chronicle = TuningChronicle(
            blueprint: blueprint,
            initialMetrics: initialMetrics,
            optimizedMetrics: optimizedMetrics,
            optimizedPayouts: optimizedPayouts,
            pulses: pulses,
            slices: slices,
            notes: payload["notes"] as? [String] ?? []
        )

        return ScribeSnapshot(id: id, stamp: Date(timeIntervalSince1970: stampValue), label: label, summary: summary, chronicle: chronicle)
    }

    private func metricsPayload(from metrics: MetricTrio) -> [String: Any] {
        ["rtp": metrics.rtp, "hitRate": metrics.hitRate, "variance": metrics.variance]
    }

    private func metrics(from payload: [String: Any]) -> MetricTrio? {
        guard let rtp = payload["rtp"] as? Double,
              let hitRate = payload["hitRate"] as? Double,
              let variance = payload["variance"] as? Double else {
            return nil
        }
        return MetricTrio(rtp: rtp, hitRate: hitRate, variance: variance)
    }

    private func seededProjects() -> [AtelierProject] {
        let optimizer = FluxOptimizer()
        let primary = forgeProject(title: "Flagship Ways", blueprint: LoomBlueprint.canned())
        var mellowBlueprint = LoomBlueprint.canned()
        mellowBlueprint.targetRTP = 0.942
        mellowBlueprint.targetHitRate = 0.31
        mellowBlueprint.targetDrift = .low
        let mellow = forgeProject(title: "Soft Session", blueprint: mellowBlueprint)

        let lineup = [primary, mellow]
        return lineup.map { project in
            var mutable = project
            let chronicle = optimizer.tune(project.blueprint)
            let summary = "RTP \(percent(chronicle.optimizedMetrics.rtp)) · Hit \(percent(chronicle.optimizedMetrics.hitRate)) · Var \(chronicle.optimizedMetrics.driftCaption)"
            mutable.snapshots = [ScribeSnapshot(id: UUID().uuidString, stamp: Date(), label: "Seed Run", summary: summary, chronicle: chronicle)]
            mutable.updatedAt = Date()
            return mutable
        }
    }

    private func percent(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }
}
