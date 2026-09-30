import Charts
import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: ChillStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                TrailBanner(kind: .trends, eyebrow: "COLD TRENDS", title: "Your exposure pattern")
                if snapshot.points.isEmpty {
                    InstrumentPlate {
                        Text("Save a few chill checks and your exposure trend will draw here.")
                            .font(ThemeMetrics.plate(15))
                            .foregroundColor(Palette.ivory)
                    }
                } else {
                    summaryPlate
                    chillChartPlate
                    windChartPlate
                    if let coldest = snapshot.coldest {
                        coldestPlate(coldest)
                    }
                }
            }
            .padding(.horizontal, ThemeMetrics.pagePadding)
            .padding(.bottom, 28)
        }
    }

    private var snapshot: LogSnapshot {
        LogSnapshot(entries: store.windChillEntries, units: store.preferredUnits)
    }

    private var summaryPlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 12) {
                Text("SUMMARY")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    metricCell(title: "READINGS", value: "\(snapshot.readingCount)")
                    metricCell(
                        title: "AVG CHILL",
                        value: "\(WindChillMath.formatted(snapshot.averageChill)) \(store.preferredUnits.temperatureSymbol)"
                    )
                    metricCell(
                        title: "COLDEST",
                        value: "\(WindChillMath.formatted(snapshot.coldestChill)) \(store.preferredUnits.temperatureSymbol)"
                    )
                    metricCell(title: "EXTREME", value: "\(snapshot.extremeCount)")
                }
            }
        }
    }

    private var chillChartPlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 12) {
                Text("WIND CHILL")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                Chart(snapshot.chartPoints) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Chill", point.chill)
                    )
                    .foregroundStyle(Palette.gold.opacity(0.18))
                    .interpolationMethod(.catmullRom)
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Chill", point.chill)
                    )
                    .foregroundStyle(Palette.gold)
                    .lineStyle(StrokeStyle(lineWidth: 2.4))
                    .interpolationMethod(.catmullRom)
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Chill", point.chill)
                    )
                    .foregroundStyle(point.isExtreme ? Palette.danger : Palette.ivory)
                    .symbolSize(48)
                }
                .chartYScale(domain: snapshot.chillDomain)
                .chartXAxis { chartAxis }
                .chartYAxis { chartAxis }
                .frame(height: 196)
            }
        }
    }

    private var windChartPlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 12) {
                Text("WIND SPEED")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                Text("Last \(snapshot.recentPoints.count) logs, oldest to newest.")
                    .font(ThemeMetrics.plate(12))
                    .foregroundColor(Palette.ivory.opacity(0.7))
                Chart(snapshot.recentPoints) { point in
                    BarMark(
                        x: .value("When", point.barLabel),
                        y: .value("Wind", point.wind)
                    )
                    .foregroundStyle(Palette.gold.opacity(0.88))
                }
                .chartXAxis { chartAxis }
                .chartYAxis { chartAxis }
                .frame(height: 168)
            }
        }
    }

    private func coldestPlate(_ entry: WindChillEntry) -> some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 8) {
                Text("COLDEST READING")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                Text("\(WindChillMath.formatted(entry.chill(in: store.preferredUnits))) \(store.preferredUnits.temperatureSymbol)")
                    .font(ThemeMetrics.instrument(28, weight: .bold))
                    .foregroundColor(Palette.ivory)
                Text(entry.locationNote.isEmpty ? DateStamp.medium(entry.date) : entry.locationNote)
                    .font(ThemeMetrics.plate(14, weight: .medium))
                    .foregroundColor(Palette.ivory.opacity(0.75))
                Text(ClothingAdvice.line(chill: entry.chill, units: entry.units, activity: store.activity))
                    .font(ThemeMetrics.plate(14))
                    .foregroundColor(Palette.ivory)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func metricCell(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(ThemeMetrics.plate(10, weight: .bold))
                .foregroundColor(Palette.gold)
                .tracking(1.1)
            Text(value)
                .font(ThemeMetrics.instrument(18, weight: .semibold))
                .foregroundColor(Palette.ivory)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chartAxis: some AxisContent {
        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                .foregroundStyle(Palette.stroke.opacity(0.28))
            AxisValueLabel()
                .foregroundStyle(Palette.ivory.opacity(0.72))
                .font(ThemeMetrics.plate(10))
        }
    }
}

private struct LogSnapshot {
    struct Point: Identifiable {
        let id: UUID
        let date: Date
        let chill: Double
        let wind: Double
        let isExtreme: Bool
        let barLabel: String
    }

    let points: [Point]
    let readingCount: Int
    let averageChill: Double
    let coldestChill: Double
    let extremeCount: Int
    let coldest: WindChillEntry?

    var chartPoints: [Point] {
        Array(points.suffix(30))
    }

    var recentPoints: [Point] {
        Array(points.suffix(8)).enumerated().map { index, point in
            Point(
                id: point.id,
                date: point.date,
                chill: point.chill,
                wind: point.wind,
                isExtreme: point.isExtreme,
                barLabel: "\(index + 1)"
            )
        }
    }

    var chillDomain: ClosedRange<Double> {
        let values = chartPoints.map(\.chill)
        guard let minValue = values.min(), let maxValue = values.max() else {
            return -10...10
        }
        if abs(maxValue - minValue) < 0.4 {
            return (minValue - 5)...(maxValue + 5)
        }
        let pad = max(1.5, (maxValue - minValue) * 0.14)
        return (minValue - pad)...(maxValue + pad)
    }

    init(entries: [WindChillEntry], units: PreferredUnits) {
        readingCount = entries.count
        extremeCount = entries.filter(\.isExtreme).count
        coldest = entries.min { lhs, rhs in
            lhs.chill(in: .metric) < rhs.chill(in: .metric)
        }
        let sorted = entries.sorted { $0.date < $1.date }
        points = sorted.enumerated().map { index, entry in
            Point(
                id: entry.id,
                date: entry.date,
                chill: entry.chill(in: units),
                wind: entry.windSpeed(in: units),
                isExtreme: entry.isExtreme,
                barLabel: "\(index + 1)"
            )
        }
        if points.isEmpty {
            averageChill = 0
            coldestChill = 0
        } else {
            let chills = points.map(\.chill)
            averageChill = chills.reduce(0, +) / Double(chills.count)
            coldestChill = chills.min() ?? 0
        }
    }
}
