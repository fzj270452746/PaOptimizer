import UIKit

enum SigilGlyph: String, CaseIterable {
    case normal
    case wild
    case scatter
}

enum DriftGrade: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var varianceAim: Double {
        switch self {
        case .low:
            return 0.18
        case .medium:
            return 0.36
        case .high:
            return 0.58
        }
    }
}

enum LatticeFlavor: String, CaseIterable {
    case line = "Line Slot"
    case ways = "Ways Slot"
}

enum PulseCadence: String, CaseIterable {
    case brisk = "Quick"
    case exacting = "Precise"

    var iterationSpan: Int {
        switch self {
        case .brisk:
            return 240
        case .exacting:
            return 920
        }
    }
}

struct RuneToken {
    let id: String
    let kind: SigilGlyph
    let baseWeight: Double
    let isAdjustable: Bool
}

struct PayoutLoom {
    let symbol: String
    var trio: Double
    var quartet: Double
    var quintet: Double

    func mirroredValues() -> [Double] {
        [trio, quartet, quintet]
    }
}

struct ConstraintVeil {
    var floorPayout: Double
    var ceilingPayout: Double
    var ordinalRules: [String]
}

struct MetricTrio {
    var rtp: Double
    var hitRate: Double
    var variance: Double

    var driftCaption: String {
        switch variance {
        case ..<0.25:
            return "Low"
        case ..<0.46:
            return "Medium"
        default:
            return "High"
        }
    }
}

struct IterationPulse {
    let step: Int
    let rtp: Double
    let variance: Double
    let hitRate: Double
}

struct WinSlice {
    let band: String
    let legacy: Double
    let tuned: Double
}

struct LoomBlueprint {
    var reelCount: Int
    var reelLength: Int
    var lattice: LatticeFlavor
    var tokens: [RuneToken]
    var payouts: [PayoutLoom]
    var targetRTP: Double
    var targetHitRate: Double
    var targetDrift: DriftGrade
    var cadence: PulseCadence
    var constraints: ConstraintVeil

    static func canned() -> LoomBlueprint {
        LoomBlueprint(
            reelCount: 5,
            reelLength: 48,
            lattice: .ways,
            tokens: [
                RuneToken(id: "A", kind: .normal, baseWeight: 11, isAdjustable: true),
                RuneToken(id: "K", kind: .normal, baseWeight: 12, isAdjustable: true),
                RuneToken(id: "Q", kind: .normal, baseWeight: 13, isAdjustable: true),
                RuneToken(id: "J", kind: .normal, baseWeight: 14, isAdjustable: true),
                RuneToken(id: "W", kind: .wild, baseWeight: 6, isAdjustable: true),
                RuneToken(id: "S", kind: .scatter, baseWeight: 4, isAdjustable: false)
            ],
            payouts: [
                PayoutLoom(symbol: "A", trio: 8, quartet: 20, quintet: 90),
                PayoutLoom(symbol: "K", trio: 6, quartet: 16, quintet: 72),
                PayoutLoom(symbol: "Q", trio: 5, quartet: 14, quintet: 60),
                PayoutLoom(symbol: "J", trio: 4, quartet: 10, quintet: 46),
                PayoutLoom(symbol: "W", trio: 12, quartet: 40, quintet: 160),
                PayoutLoom(symbol: "S", trio: 3, quartet: 10, quintet: 36)
            ],
            targetRTP: 0.96,
            targetHitRate: 0.25,
            targetDrift: .medium,
            cadence: .exacting,
            constraints: ConstraintVeil(
                floorPayout: 2,
                ceilingPayout: 1000,
                ordinalRules: ["J < Q < K < A < W"]
            )
        )
    }
}

struct TuningChronicle {
    let blueprint: LoomBlueprint
    let initialMetrics: MetricTrio
    let optimizedMetrics: MetricTrio
    let optimizedPayouts: [PayoutLoom]
    let pulses: [IterationPulse]
    let slices: [WinSlice]
    let notes: [String]
}

struct ScribeSnapshot {
    let id: String
    let stamp: Date
    let label: String
    let summary: String
    let chronicle: TuningChronicle
}

struct AtelierProject {
    let id: String
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var blueprint: LoomBlueprint
    var snapshots: [ScribeSnapshot]
}

struct RivalScenario {
    let title: String
    let caption: String
    let chronicle: TuningChronicle
}
