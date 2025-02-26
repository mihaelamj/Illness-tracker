import SwiftUI

struct IllnessListView: View {
    let patientName: String
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var illnessViewModel: IllnessViewModel
    
    var patientIllnesses: [Illness] {
        illnessViewModel.illnesses
            .filter { $0.patientName == patientName }
            .sorted(by: { $0.startDate > $1.startDate })
    }
    
    var body: some View {
        List {
            Section(header: Text("Illnesses")) {
                ForEach(patientIllnesses) { illness in
                    Button {
                        navigationPath.append(illness)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(formatDate(illness.startDate))
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                if illness.isActive {
                                    Text("Active")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(4)
                                } else if let endDate = illness.endDate {
                                    Text("\(daysBetween(start: illness.startDate, end: endDate)) days")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                            
                            if let notes = illness.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let illness = patientIllnesses[index]
                        illnessViewModel.deleteIllness(illness)
                    }
                }
            }
        }
        .navigationTitle("\(patientName)'s Illnesses")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigationPath.append(NavigationDestination.addIllness(patientName: patientName))
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func daysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
}
