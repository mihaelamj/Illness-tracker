import Foundation
import SwiftUI

// File importer utility
class DataImporter: ObservableObject {
    @Published var isImporting = false
    @Published var importProgress = 0.0
    @Published var importError: String?
    
    private let healthService: HealthRecordService
    private let illnessID: UUID
    
    init(healthService: HealthRecordService, illnessID: UUID) {
        self.healthService = healthService
        self.illnessID = illnessID
    }
    
    func importHealthData(from url: URL, completion: @escaping (Bool) -> Void) {
        isImporting = true
        importProgress = 0.0
        importError = nil
        
        // Check file type
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "csv":
            importCSV(from: url, completion: completion)
        case "xls", "xlsx":
            importError = "Excel import not implemented yet"
            isImporting = false
            completion(false)
        case "tsv", "tab":
            importTSV(from: url, completion: completion)
        default:
            importError = "Unsupported file format"
            isImporting = false
            completion(false)
        }
    }
    
    private func importCSV(from url: URL, completion: @escaping (Bool) -> Void) {
        do {
            let csvData = try String(contentsOf: url, encoding: .utf8)
            
            // Parse the CSV data
            let parser = CSVParser()
            parser.parseCSV(csvData) { [weak self] parsedRecords in
                guard let self = self else { return completion(false) }
                
                // Add illness ID to all records
                var recordsWithIllnessID = parsedRecords
                for i in 0..<recordsWithIllnessID.count {
                    recordsWithIllnessID[i].illnessID = self.illnessID
                }
                
                self.importRecords(recordsWithIllnessID, completion: completion)
            }
        } catch {
            importError = "Error reading CSV file: \(error.localizedDescription)"
            isImporting = false
            completion(false)
        }
    }
    
    private func importTSV(from url: URL, completion: @escaping (Bool) -> Void) {
        do {
            let tsvData = try String(contentsOf: url, encoding: .utf8)
            
            // Convert TSV to CSV by replacing tabs with commas
            let csvData = tsvData.replacingOccurrences(of: "\t", with: ",")
            
            // Parse using the CSV parser
            let parser = CSVParser()
            parser.parseCSV(csvData) { [weak self] parsedRecords in
                guard let self = self else { return completion(false) }
                
                // Add illness ID to all records
                var recordsWithIllnessID = parsedRecords
                for i in 0..<recordsWithIllnessID.count {
                    recordsWithIllnessID[i].illnessID = self.illnessID
                }
                
                self.importRecords(recordsWithIllnessID, completion: completion)
            }
        } catch {
            importError = "Error reading TSV file: \(error.localizedDescription)"
            isImporting = false
            completion(false)
        }
    }
    
    private func importRecords(_ records: [HealthRecord], completion: @escaping (Bool) -> Void) {
        let totalRecords = records.count
        
        if totalRecords == 0 {
            importError = "No valid records found in the file"
            isImporting = false
            completion(false)
            return
        }
        
        var importedCount = 0
        
        for record in records {
            healthService.saveRecord(record) { [weak self] savedRecord in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    importedCount += 1
                    self.importProgress = Double(importedCount) / Double(totalRecords)
                    
                    if importedCount == totalRecords {
                        self.isImporting = false
                        completion(true)
                    }
                }
            }
        }
    }
    
    // For testing or when file access isn't available
    func importSampleData(completion: @escaping (Bool) -> Void) {
        // Create sample data
        let records = createSampleHealthRecords()
        importRecords(records, completion: completion)
    }
    
    // Sample data for testing
    private func createSampleHealthRecords() -> [HealthRecord] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        return [
            HealthRecord(
                illnessID: illnessID,
                timestamp: dateFormatter.date(from: "19.02.2025 22:30")!,
                temperature: 38.2,
                treatment: "Ibuprofen 400",
                symptoms: "Throat ache",
                sampleDate: "19.02.2025.",
                sampleTime: "22:30"
            ),
            HealthRecord(
                illnessID: illnessID,
                timestamp: dateFormatter.date(from: "20.02.2025 01:58")!,
                temperature: 36.6,
                sampleDate: "20.02.2025.",
                sampleTime: "01:58"
            ),
            HealthRecord(
                illnessID: illnessID,
                timestamp: dateFormatter.date(from: "21.02.2025 14:14")!,
                temperature: 39.4,
                treatment: "Ibuprofen 3 x 200, elektroliti",
                symptoms: "Throat ache",
                sampleDate: "21.02.2025.",
                sampleTime: "14:14"
            ),
            HealthRecord(
                illnessID: illnessID,
                timestamp: dateFormatter.date(from: "22.02.2025 12:42")!,
                temperature: 38.4,
                treatment: "Ibuprofen 3 x 200, elektroliti",
                symptoms: "Throat ache, congested nose",
                sampleDate: "22.02.2025.",
                sampleTime: "12:42"
            )
        ]
    }
}
