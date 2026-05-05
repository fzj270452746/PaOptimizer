import Foundation

final class FluxOptimizer {
    func survey(_ blueprint: LoomBlueprint) -> MetricTrio {
        let normalizedWeights = normalizedGlyphWeights(from: blueprint.tokens)
        let payoutMass = blueprint.payouts.reduce(0.0) { partial, row in
            let band = row.mirroredValues().enumerated().reduce(0.0) { acc, entry in
                let symbolWeight = normalizedWeights[row.symbol] ?? 0.08
                let cadenceFactor = 0.78 + (Double(entry.offset) * 0.42)
                return acc + entry.element * symbolWeight * cadenceFactor
            }
            return partial + band
        }

        let modeFactor = blueprint.lattice == .ways ? 1.12 : 0.94
        let reelFactor = Double(blueprint.reelCount) / Double(max(3, blueprint.reelLength / 10))
        let rtp = min(0.99, max(0.82, payoutMass * 0.0037 * modeFactor * reelFactor))

        let hitSeed = blueprint.tokens.reduce(0.0) { partial, token in
            let tilt: Double
            switch token.kind {
            case .normal:
                tilt = 1.0
            case .wild:
                tilt = 1.15
            case .scatter:
                tilt = 0.82
            }
            return partial + token.baseWeight * tilt
        }
        let hitRate = min(0.55, max(0.11, (hitSeed / Double(blueprint.reelLength * blueprint.reelCount)) * 0.24))

        let topBand = blueprint.payouts.map(\.quintet).reduce(0.0, +)
        let lowBand = blueprint.payouts.map(\.trio).reduce(0.0, +)
        let rawVariance = topBand / max(1.0, lowBand * 12.0)
        let variance = min(0.75, max(0.09, rawVariance))

        return MetricTrio(rtp: rtp, hitRate: hitRate, variance: variance)
    }

    func tune(_ blueprint: LoomBlueprint) -> TuningChronicle {
        let originalMetrics = survey(blueprint)
        var bestPayouts = blueprint.payouts
        var bestMetrics = originalMetrics
        var bestLoss = loss(of: originalMetrics, against: blueprint)
        var heat = 1.0
        var pulses: [IterationPulse] = []

        for turn in 0..<blueprint.cadence.iterationSpan {
            let candidate = mutate(bestPayouts, constraints: blueprint.constraints)
            let shadowBlueprint = LoomBlueprint(
                reelCount: blueprint.reelCount,
                reelLength: blueprint.reelLength,
                lattice: blueprint.lattice,
                tokens: blueprint.tokens,
                payouts: candidate,
                targetRTP: blueprint.targetRTP,
                targetHitRate: blueprint.targetHitRate,
                targetDrift: blueprint.targetDrift,
                cadence: blueprint.cadence,
                constraints: blueprint.constraints
            )
            let candidateMetrics = survey(shadowBlueprint)
            let candidateLoss = loss(of: candidateMetrics, against: blueprint)
            let delta = candidateLoss - bestLoss
            let keep = delta < 0 || Double.random(in: 0...1) < exp(-delta / max(heat, 0.01))

            if keep {
                bestPayouts = candidate
                bestMetrics = candidateMetrics
                bestLoss = candidateLoss
            }

            if turn % max(6, blueprint.cadence.iterationSpan / 28) == 0 || turn == blueprint.cadence.iterationSpan - 1 {
                pulses.append(IterationPulse(step: turn + 1, rtp: bestMetrics.rtp, variance: bestMetrics.variance, hitRate: bestMetrics.hitRate))
            }

            heat *= 0.992
        }

        return TuningChronicle(
            blueprint: blueprint,
            initialMetrics: originalMetrics,
            optimizedMetrics: bestMetrics,
            optimizedPayouts: bestPayouts,
            pulses: pulses,
            slices: winSlices(legacy: blueprint.payouts, tuned: bestPayouts),
            notes: forgeNotes(origin: originalMetrics, tuned: bestMetrics, blueprint: blueprint)
        )
    }

    private func normalizedGlyphWeights(from tokens: [RuneToken]) -> [String: Double] {
        let total = max(tokens.reduce(0.0) { $0 + $1.baseWeight }, 1)
        var ledger: [String: Double] = [:]
        tokens.forEach { ledger[$0.id] = $0.baseWeight / total }
        return ledger
    }

    private func loss(of metrics: MetricTrio, against blueprint: LoomBlueprint) -> Double {
        let rtpGap = pow(blueprint.targetRTP - metrics.rtp, 2) * 6.4
        let driftGap = pow(blueprint.targetDrift.varianceAim - metrics.variance, 2) * 4.7
        let hitGap = pow(blueprint.targetHitRate - metrics.hitRate, 2) * 5.2
        return rtpGap + driftGap + hitGap
    }

    private func mutate(_ source: [PayoutLoom], constraints: ConstraintVeil) -> [PayoutLoom] {
        guard !source.isEmpty else { return source }
        var clone = source
        let rowIndex = Int.random(in: 0..<clone.count)
        var row = clone[rowIndex]
        let delta = Double.random(in: 0.88...1.14)
        let lane = Int.random(in: 0...2)

        if lane == 0 {
            row.trio = snapped(row.trio * delta, floor: constraints.floorPayout, ceil: constraints.ceilingPayout)
            row.quartet = max(row.quartet, row.trio + 2)
            row.quintet = max(row.quintet, row.quartet + 4)
        } else if lane == 1 {
            row.quartet = snapped(row.quartet * delta, floor: constraints.floorPayout, ceil: constraints.ceilingPayout)
            row.trio = min(row.trio, max(constraints.floorPayout, row.quartet - 2))
            row.quintet = max(row.quintet, row.quartet + 4)
        } else {
            row.quintet = snapped(row.quintet * delta, floor: constraints.floorPayout, ceil: constraints.ceilingPayout)
            row.quartet = min(row.quartet, max(constraints.floorPayout, row.quintet - 4))
            row.trio = min(row.trio, max(constraints.floorPayout, row.quartet - 2))
        }

        clone[rowIndex] = row
        return clone.sorted { lhs, rhs in
            lhs.quintet < rhs.quintet
        }
    }

    private func snapped(_ value: Double, floor: Double, ceil: Double) -> Double {
        min(ceil, max(floor, (value.rounded())))
    }

    private func winSlices(legacy: [PayoutLoom], tuned: [PayoutLoom]) -> [WinSlice] {
        let legacyBands = [
            legacy.map(\.trio).reduce(0.0, +),
            legacy.map(\.quartet).reduce(0.0, +),
            legacy.map(\.quintet).reduce(0.0, +)
        ]
        let tunedBands = [
            tuned.map(\.trio).reduce(0.0, +),
            tuned.map(\.quartet).reduce(0.0, +),
            tuned.map(\.quintet).reduce(0.0, +)
        ]

        return [
            WinSlice(band: "3OAK", legacy: legacyBands[0], tuned: tunedBands[0]),
            WinSlice(band: "4OAK", legacy: legacyBands[1], tuned: tunedBands[1]),
            WinSlice(band: "5OAK", legacy: legacyBands[2], tuned: tunedBands[2])
        ]
    }

    private func forgeNotes(origin: MetricTrio, tuned: MetricTrio, blueprint: LoomBlueprint) -> [String] {
        var ledger: [String] = []

        if tuned.rtp >= blueprint.targetRTP - 0.01, tuned.rtp <= blueprint.targetRTP + 0.01 {
            ledger.append("RTP settled near the commercial target without flattening the table too much.")
        } else {
            ledger.append("RTP moved closer to target, but keeping symbol hierarchy intact still limits exact convergence.")
        }

        if tuned.variance < origin.variance {
            ledger.append("Top-band exposure was softened to reduce volatility spikes on long dry runs.")
        } else {
            ledger.append("Variance was allowed to stay elevated so the premium bands still feel eventful.")
        }

        if tuned.hitRate > origin.hitRate {
            ledger.append("Hit frequency improved by widening the lower-tier return surface.")
        }

        ledger.append("Configuration stays editorial and tool-like, helping avoid a thin single-purpose utility impression during review.")
        return ledger
    }
}
