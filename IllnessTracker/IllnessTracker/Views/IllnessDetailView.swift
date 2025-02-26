import SwiftUI

struct IllnessDetailView: View {
    let illness: Illness
    @Binding var navigationPath: NavigationPath
    @StateObject private var healthViewModel: HealthViewModel
    @StateObject private var attachmentViewModel: AttachmentViewModel
    @EnvironmentObject var illnessViewModel: IllnessViewModel
    
    init(illness: Illness, navigationPath: Binding<NavigationPath>) {
        self.illness = illness
        self._navigationPath = navigationPath
        self._healthViewModel = StateObject(wrappedValue: HealthViewModel(
            service: MockHealthRecordService(),
            illnessID: illness.id
        ))
        self._attachmentViewModel = StateObject(wrappedValue: AttachmentViewModel(
            service: MockAttachmentService(),
            illnessID: illness.id
        ))
    }
    
    var body: some View {
        List {
            Section(header: Text("Illness Details")) {
                HStack {
                    Text("Patient")
                    Spacer()
                    Text(illness.patientName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Start Date")
                    Spacer()
                    Text(formatDate(illness.startDate))
                        .foregroundColor(.secondary)
                }
                
                if let endDate = illness.endDate {
                    HStack {
                        Text("End Date")
                        Spacer()
                        Text(formatDate(endDate))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(daysBetween(start: illness.startDate, end: endDate)) days")
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                    }
                }
                
                if let notes = illness.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.headline)
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !healthViewModel.records.isEmpty {
                Section(header: Text("Temperature Chart")) {
                    TemperatureChartView(records: healthViewModel.records)
                        .frame(height: 200)
                }
            }
            
            Section(header:
                HStack {
                    Text("Health Records")
                    Spacer()
                    Button {
                        navigationPath.append(NavigationDestination.addRecord(illness: illness))
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption)
                    }
                }
            ) {
                if healthViewModel.records.isEmpty {
                    Text("No health records yet. Add your first record.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(healthViewModel.records) { record in
                        HealthRecordRow(record: record) {
                            healthViewModel.deleteRecord(record)
                        }
                    }
                }
            }
            
            Section(header: Text("Analytics")) {
                HStack {
                    Text("Max Temperature")
                    Spacer()
                    if let max = healthViewModel.maxTemperature {
                        Text(String(format: "%.1f°C", max))
                            .foregroundColor(max >= 38.0 ? .red : .secondary)
                    } else {
                        Text("N/A")
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Average Temperature")
                    Spacer()
                    if let avg = healthViewModel.averageTemperature {
                        Text(String(format: "%.1f°C", avg))
                            .foregroundColor(.secondary)
                    } else {
                        Text("N/A")
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Most Common Symptom")
                    Spacer()
                    if let symptom = healthViewModel.mostCommonSymptom {
                        Text(symptom)
                            .foregroundColor(.secondary)
                    } else {
                        Text("N/A")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section {
                Button {
                    navigationPath.append(NavigationDestination.viewAttachments(illness: illness))
                } label: {
                    HStack {
                        Image(systemName: "paperclip")
                        Text("Attachments")
                        Spacer()
                        Text("\(attachmentViewModel.attachments.count)")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Button {
                    navigationPath.append(NavigationDestination.importData(illness: illness))
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import Data")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                if illness.endDate == nil {
                    Button(role: .destructive) {
                        // Mark as complete
                        var updatedIllness = illness
                        updatedIllness.endDate = Date()
                        illnessViewModel.updateIllness(updatedIllness)
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Mark as Completed")
                        }
                    }
                }
            }
        }
        .navigationTitle("Illness Details")
        .refreshable {
            healthViewModel.loadRecords()
            attachmentViewModel.loadAttachments()
        }
        .overlay {
            if healthViewModel.isLoading {
                ProgressView("Loading records...")
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(10)
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
