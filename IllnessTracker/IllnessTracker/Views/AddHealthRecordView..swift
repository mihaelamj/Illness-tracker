import SwiftUI

struct AddHealthRecordView: View {
    let illness: Illness
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: HealthViewModel
    @State private var temperatureString = ""
    @State private var treatment = ""
    @State private var symptoms = ""
    @State private var timestamp = Date()
    @State private var showingDatePicker = false
    
    init(illness: Illness, navigationPath: Binding<NavigationPath>) {
        self.illness = illness
        self._navigationPath = navigationPath
        self._viewModel = StateObject(wrappedValue: HealthViewModel(
            service: MockHealthRecordService(),
            illnessID: illness.id
        ))
    }
    
    var formIsValid: Bool {
        let tempValue = Double(temperatureString.replacingOccurrences(of: ",", with: "."))
        return tempValue != nil && !treatment.isEmpty && !symptoms.isEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("Date and Time")) {
                Button {
                    showingDatePicker.toggle()
                } label: {
                    HStack {
                        Text("Time")
                        Spacer()
                        Text(formatDate(timestamp))
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showingDatePicker) {
                    VStack {
                        DatePicker("Select Date and Time", selection: $timestamp)
                            .datePickerStyle(.graphical)
                            .padding()
                        
                        Button("Done") {
                            showingDatePicker = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom)
                    }
                    .presentationDetents([.medium])
                }
            }
            
            Section(header: Text("Temperature")) {
                HStack {
                    TextField("Temperature", text: $temperatureString)
                        .keyboardType(.decimalPad)
                    
                    Text("°C")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Treatment")) {
                TextField("Medications, etc.", text: $treatment)
                    .onChange(of: treatment) { _ in
                        updateRecord()
                    }
            }
            
            Section(header: Text("Symptoms")) {
                TextEditor(text: $symptoms)
                    .frame(height: 80)
                    .onChange(of: symptoms) { _ in
                        updateRecord()
                    }
            }
            
            if let error = viewModel.validationError {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section {
                Button {
                    saveRecord()
                } label: {
                    Text("Save Record")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fontWeight(.medium)
                }
                .disabled(!formIsValid)
            }
        }
        .navigationTitle("Add Health Record")
        .onAppear {
            updateRecord()
        }
    }
    
    private func updateRecord() {
        let tempValue = Double(temperatureString.replacingOccurrences(of: ",", with: "."))
        
        viewModel.newRecord.timestamp = timestamp
        viewModel.newRecord.temperature = tempValue
        viewModel.newRecord.treatment = treatment.isEmpty ? nil : treatment
        viewModel.newRecord.symptoms = symptoms.isEmpty ? nil : symptoms
        
        // Store original date formats
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy."
        viewModel.newRecord.sampleDate = dateFormatter.string(from: timestamp)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        viewModel.newRecord.sampleTime = timeFormatter.string(from: timestamp)
    }
    
    private func saveRecord() {
        updateRecord()
        viewModel.addRecord()
        
        // Navigate back to the illness detail view
        if let last = navigationPath.count > 0 ? navigationPath.removeLast() : nil {
            print("Removed \(last) from navigation stack")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}
