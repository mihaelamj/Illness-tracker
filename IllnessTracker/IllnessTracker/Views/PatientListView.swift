import SwiftUI

struct PatientListView: View {
   @ObservedObject var illnessViewModel: IllnessViewModel
   @Binding var navigationPath: NavigationPath
   @State private var showingAddPatient = false
   @State private var newPatientName = ""
   
   init(navigationPath: Binding<NavigationPath>, illnessViewModel: IllnessViewModel) {
       self._navigationPath = navigationPath
       self.illnessViewModel = illnessViewModel
   }
   
   var uniquePatients: [String] {
       Array(Set(illnessViewModel.illnesses.map { $0.patientName })).sorted()
   }
   
   var body: some View {
       List {
           Section(header: Text("Patients")) {
               ForEach(uniquePatients, id: \.self) { patientName in
                   Button {
                       navigationPath.append(patientName)
                   } label: {
                       HStack {
                           Text(patientName)
                               .foregroundColor(.primary)
                           Spacer()
                           Text("\(illnessViewModel.illnesses.filter { $0.patientName == patientName }.count) records")
                               .foregroundColor(.secondary)
                           Image(systemName: "chevron.right")
                               .foregroundColor(.gray)
                               .font(.caption)
                       }
                   }
               }
           }
       }
       .navigationTitle("Patients")
       .toolbar {
           ToolbarItem(placement: .navigationBarTrailing) {
               Button {
                   showingAddPatient = true
               } label: {
                   Image(systemName: "plus")
               }
           }
           
           ToolbarItem(placement: .navigationBarLeading) {
               Button {
                   illnessViewModel.syncIllnesses()
               } label: {
                   Image(systemName: "arrow.clockwise")
               }
           }
       }
       .alert("Add New Patient", isPresented: $showingAddPatient) {
           TextField("Patient Name", text: $newPatientName)
           Button("Cancel", role: .cancel) {
               newPatientName = ""
           }
           Button("Add") {
               if !newPatientName.isEmpty {
                   let newIllness = Illness(
                       patientName: newPatientName,
                       startDate: Date()
                   )
                   illnessViewModel.newIllness = newIllness
                   navigationPath.append(NavigationDestination.addIllness(patientName: newPatientName))
                   newPatientName = ""
               }
           }
       } message: {
           Text("Enter the name of the patient to add.")
       }
       .overlay {
           if illnessViewModel.isLoading {
               ProgressView("Loading patients...")
                   .padding()
                   .background(Color(.systemBackground).opacity(0.8))
                   .cornerRadius(10)
           }
       }
   }
}
