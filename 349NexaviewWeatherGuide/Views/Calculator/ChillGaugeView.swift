import SwiftUI

struct ChillGaugeView: View {
    let chill: Double
    let units: PreferredUnits
    let isValid: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Palette.purple)
            Circle()
                .stroke(Palette.gold, lineWidth: 10)
                .padding(7)
            Circle()
                .stroke(Palette.stroke, lineWidth: 1)
                .padding(20)
            tickMarks
            needle
            Circle()
                .fill(Palette.gold)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .fill(Palette.ink)
                        .frame(width: 6, height: 6)
                )
            VStack(spacing: 4) {
                Text("WIND CHILL")
                    .font(ThemeMetrics.plate(10, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(2.2)
                Text(isValid ? WindChillMath.formatted(chill) : "—")
                    .font(ThemeMetrics.instrument(46, weight: .bold))
                    .foregroundColor(Palette.ivory)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(units.temperatureSymbol)
                    .font(ThemeMetrics.plate(14, weight: .semibold))
                    .foregroundColor(Palette.gold)
            }
            .offset(y: 10)
        }
        .frame(width: ThemeMetrics.gaugeSize, height: ThemeMetrics.gaugeSize)
        .shadow(color: Palette.gold.opacity(0.22), radius: 16, x: 0, y: 8)
    }

    private var tickMarks: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 28
            for index in 0...27 {
                let angle = startAngle - (Double(index) / 27.0) * sweep
                let radians = angle * Double.pi / 180
                let outer = CGPoint(
                    x: center.x + CGFloat(cos(radians)) * radius,
                    y: center.y - CGFloat(sin(radians)) * radius
                )
                let innerRadius = index.isMultiple(of: 3) ? radius - 14 : radius - 8
                let inner = CGPoint(
                    x: center.x + CGFloat(cos(radians)) * innerRadius,
                    y: center.y - CGFloat(sin(radians)) * innerRadius
                )
                var path = Path()
                path.move(to: inner)
                path.addLine(to: outer)
                context.stroke(
                    path,
                    with: .color(index.isMultiple(of: 3) ? Color("PaletteGold") : Color("PaletteStroke")),
                    lineWidth: index.isMultiple(of: 3) ? 2.2 : 1
                )
            }
        }
    }

    private var needle: some View {
        Capsule()
            .fill(Palette.gold)
            .frame(width: 5, height: ThemeMetrics.gaugeSize * 0.34)
            .offset(y: -ThemeMetrics.gaugeSize * 0.17)
            .rotationEffect(.degrees(needleDegrees), anchor: .center)
            .animation(.easeInOut(duration: 0.45), value: chill)
            .opacity(isValid ? 1 : 0.28)
    }

    private var startAngle: Double { 225 }
    private var sweep: Double { 270 }

    private var needleDegrees: Double {
        let bounds = gaugeBounds
        let clamped = min(max(chill, bounds.lowerBound), bounds.upperBound)
        let progress = (clamped - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return -135 + progress * sweep
    }

    private var gaugeBounds: ClosedRange<Double> {
        switch units {
        case .metric:
            return -40...20
        case .imperial:
            return -40...50
        }
    }
}
