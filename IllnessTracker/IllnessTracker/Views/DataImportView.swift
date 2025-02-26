import SwiftUI
import UniformTypeIdentifiers

struct DataImportView: View {
    let illness: Illness
    @StateObject private var importer: DataImporter
    @State private var showingFilePicker = false
    
    init(illness: Illness) {
        self.illness = illness
        self._importer = StateObject(wrappedValue: DataImporter(
            healthService: MockHealthRecordService(),
            illnessID: illness.id
        ))
    }
    
    var body: some View {
        List {
            Section(header: Text("Import Health Data")) {
                Button {
                    showingFilePicker = true
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .foregroundColor(.blue)
                        Text("Select File to Import")
                    }
                }
                
                Button {
                    // For testing when file picker is not available
                    importer.importSampleData { success in
                        if success {
                            print("Sample data imported successfully")
                        } else {
                            print("Failed to import sample data")
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.orange)
                        Text("Import Sample Data")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Supported File Types:")
                        .font(.headline)
                    
                    Group {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.green)
                            Text("CSV (Comma Separated Values)")
                        }
                        
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.orange)
                            Text("TSV (Tab Separated Values)")
                        }
                        
                        HStack {
                            Image(systemName: "doc.richtext")
                                .foregroundColor(.blue)
                            Text("Excel (XLS, XLSX)")
                        }
                    }
                    .font(.subheadline)
                    .padding(.leading)
                }
                .padding(.vertical, 8)
            }
            
            if let error = importer.importError {
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            
            if importer.isImporting {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Importing data...")
                            .font(.headline)
                        
                        ProgressView(value: importer.importProgress)
                            .progressViewStyle(.linear)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Expected Format")) {
                Text("The import file should contain columns for Date, Time, Temperature, Treatment, and Symptoms. Time and date should be in separate columns.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Example CSV: Date,Time,Temperature,Treatment,Symptoms")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Import Data")
        .sheet(isPresented: $showingFilePicker) {
            // In a complete app, you'd implement a document picker here
            // Since we can't do that in this interface, we provide a sample data option
            Text("File picker would appear here. Use the sample data option for testing.")
                .padding()
        }
    }
}

// In a complete app, this would be a UIViewControllerRepresentable for UIDocumentPickerViewController
// For simplicity, we're just providing a mock implementation with sample data
