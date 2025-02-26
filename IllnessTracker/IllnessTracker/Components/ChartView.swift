import SwiftUI
import Charts // Requires iOS 16+

struct TemperatureChartView: View {
    let records: [HealthRecord]
    
    var chartData: [(Date, Double)] {
        records.compactMap { record in
            if let temp = record.temperature {
                return (record.timestamp, temp)
            }
            return nil
        }
        .sorted(by: { $0.0 < $1.0 })
    }
    
    var body: some View {
        VStack {
            if chartData.isEmpty {
                Text("No temperature data to display")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            } else if #available(iOS 16.0, macOS 13.0, *) {
                ChartView(data: chartData)
                    .frame(height: 200)
            } else {
                // Fallback for older versions
                Text("Temperature chart requires iOS 16+ or macOS 13+")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct ChartView: View {
    let data: [(Date, Double)]
    
    var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { index in
                let point = data[index]
                LineMark(
                    x: .value("Time", point.0),
                    y: .value("Temperature", point.1)
                )
                .foregroundStyle(chartLineColor(temp: point.1))
                
                PointMark(
                    x: .value("Time", point.0),
                    y: .value("Temperature", point.1)
                )
                .foregroundStyle(chartPointColor(temp: point.1))
            }
            
            RuleMark(y: .value("Normal", 37.0))
                .foregroundStyle(.green.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            
            RuleMark(y: .value("Fever", 38.0))
                .foregroundStyle(.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
        }
        .chartYScale(domain: 35...41)
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 6))
        }
    }
    
    func chartLineColor(temp: Double) -> Color {
        if temp >= 38.5 {
            return .red
        } else if temp >= 37.5 {
            return .orange
        } else {
            return .green
        }
    }
    
    func chartPointColor(temp: Double) -> Color {
        if temp >= 38.5 {
            return .red
        } else if temp >= 37.5 {
            return .orange
        } else {
            return .green
        }
    }
}
