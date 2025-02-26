import SwiftUI

struct AddIllnessView: View {
    let patientName: String
    @Binding var navigationPath: NavigationPath
    @ObservedObject var illnessViewModel: IllnessViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var startDate = Date()
    @State private var notes = ""
    
    init(navigationPath: Binding<NavigationPath>, illnessViewModel: IllnessViewModel, patientName: String) {
        self._navigationPath = navigationPath
        self.illnessViewModel = illnessViewModel
        self.patientName = patientName
    }
    
    var body: some View {
        Form {
            Section(header: Text("Illness Details")) {
                Text(patientName)
                    .foregroundColor(.secondary)
                
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                
                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button {
                    saveIllness()
                } label: {
                    Text("Save Illness")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fontWeight(.medium)
                }
                .disabled(patientName.isEmpty)
            }
        }
        .navigationTitle("Add New Illness")
        .onAppear {
            // Initialize with the patient name
            illnessViewModel.newIllness = Illness( // error
                patientName: patientName,
                startDate: startDate,
                notes: notes.isEmpty ? nil : notes
            )
        }
    }
    
    private func saveIllness() {
        illnessViewModel.newIllness.startDate = startDate
        illnessViewModel.newIllness.notes = notes.isEmpty ? nil : notes
        
        illnessViewModel.addIllness()
        
        // Navigate back to the illness list
        if let last = navigationPath.count > 0 ? navigationPath.removeLast() : nil {
            print("Removed \(last) from navigation stack")
        }
    }
}
