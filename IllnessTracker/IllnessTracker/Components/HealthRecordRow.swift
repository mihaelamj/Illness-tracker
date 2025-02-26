import SwiftUI

struct HealthRecordRow: View {
    let record: HealthRecord
    let onDelete: () -> Void
    
    var displayDate: String {
        if let date = record.sampleDate, let time = record.sampleTime {
            return "\(date) \(time)"
        } else {
            return record.formattedDate
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(displayDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let temp = record.temperature {
                    Text(record.formattedTemperature)
                        .bold()
                        .foregroundColor(record.highFever ? .red :
                                         record.hasFever ? .orange : .primary)
                }
            }
            
            if let treatment = record.treatment, !treatment.isEmpty {
                HStack {
                    Image(systemName: "pill")
                        .foregroundColor(.blue)
                    Text(treatment)
                        .foregroundColor(.blue)
                }
                .font(.subheadline)
            }
            
            if let symptoms = record.symptoms, !symptoms.isEmpty {
                HStack {
                    Image(systemName: "stethoscope")
                        .foregroundColor(.purple)
                    Text(symptoms)
                        .foregroundColor(.purple)
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 6)
        .swipeActions {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
