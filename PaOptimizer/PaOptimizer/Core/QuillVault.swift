import Foundation

final class QuillVault {
    static let shared = QuillVault()

    private let ledger = UserDefaults.standard
    private let cachedBlueprintKey = "quill.cachedBlueprint"

    private init() {}

    func store(_ blueprint: LoomBlueprint) {
        let glyphs: [[String: Any]] = blueprint.tokens.map {
            [
                "id": $0.id,
                "kind": $0.kind.rawValue,
                "baseWeight": $0.baseWeight,
                "isAdjustable": $0.isAdjustable
            ]
        }

        let payouts: [[String: Any]] = blueprint.payouts.map {
            ["symbol": $0.symbol, "trio": $0.trio, "quartet": $0.quartet, "quintet": $0.quintet]
        }

        let payload: [String: Any] = [
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

        ledger.set(payload, forKey: cachedBlueprintKey)
    }

    func restore() -> LoomBlueprint {
        guard let payload = ledger.dictionary(forKey: cachedBlueprintKey) else {
            return LoomBlueprint.canned()
        }

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
            return LoomBlueprint.canned()
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
}

