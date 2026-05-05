import UIKit

final class ArcTrendView: UIView {
    private var entries: [CGFloat] = []
    private var tintLine: UIColor = PrismPalette.mint

    func infuse(values: [Double], tint: UIColor) {
        entries = values.map { CGFloat($0) }
        tintLine = tint
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard entries.count > 1, let ctx = UIGraphicsGetCurrentContext() else { return }

        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 18)
        UIColor.white.withAlphaComponent(0.03).setFill()
        path.fill()

        let maxValue = entries.max() ?? 1
        let minValue = entries.min() ?? 0
        let span = max(maxValue - minValue, 0.0001)
        let insetRect = bounds.insetBy(dx: 14, dy: 14)

        let line = UIBezierPath()
        for (index, entry) in entries.enumerated() {
            let progress = CGFloat(index) / CGFloat(max(entries.count - 1, 1))
            let x = insetRect.minX + progress * insetRect.width
            let normalized = (entry - minValue) / span
            let y = insetRect.maxY - (normalized * insetRect.height)

            if index == 0 {
                line.move(to: CGPoint(x: x, y: y))
            } else {
                line.addLine(to: CGPoint(x: x, y: y))
            }
        }

        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: 12, color: tintLine.withAlphaComponent(0.6).cgColor)
        tintLine.setStroke()
        line.lineWidth = 3
        line.lineCapStyle = .round
        line.stroke()
        ctx.restoreGState()
    }
}

