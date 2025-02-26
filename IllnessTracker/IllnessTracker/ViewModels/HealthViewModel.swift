import Foundation
import SwiftUI
import Combine

// ViewModel for health records
class HealthViewModel: ObservableObject {
    @Published var records: [HealthRecord] = []
    @Published var newRecord: HealthRecord
    @Published var isLoading: Bool = false
    @Published var isSyncing: Bool = false
    @Published var validationError: String?
    
    private let service: HealthRecordService
    private let illnessID: UUID
    
    init(service: HealthRecordService, illnessID: UUID) {
        self.service = service
        self.illnessID = illnessID
        self.newRecord = HealthRecord(illnessID: illnessID, timestamp: Date())
        loadRecords()
    }
    
    // Check if all required fields are filled
    var isFormValid: Bool {
        guard let temperature = newRecord.temperature, temperature > 0 else {
            validationError = "Temperature is required"
            return false
        }
        
        if newRecord.treatment?.isEmpty ?? true {
            validationError = "Treatment information is required"
            return false
        }
        
        if newRecord.symptoms?.isEmpty ?? true {
            validationError = "Symptoms information is required"
            return false
        }
        
        validationError = nil
        return true
    }
    
    func loadRecords() {
        isLoading = true
        service.loadRecords(forIllness: illnessID) { [weak self] loadedRecords in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.records = loadedRecords
                self.isLoading = false
            }
        }
    }
    
    func addRecord() {
        guard isFormValid else { return }
        
        service.saveRecord(newRecord) { [weak self] savedRecord in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.newRecord = HealthRecord(illnessID: self.illnessID, timestamp: Date())
                self.loadRecords()
            }
        }
    }
    
    func deleteRecord(_ record: HealthRecord) {
        service.deleteRecord(record) { [weak self] success in
            guard let self = self, success else { return }
            DispatchQueue.main.async {
                self.loadRecords()
            }
        }
    }
    
    func updateRecord(_ record: HealthRecord) {
        service.saveRecord(record) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadRecords()
            }
        }
    }
    
    func syncRecords() {
        isSyncing = true
        service.syncRecords { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadRecords()
                self.isSyncing = false
            }
        }
    }
    
    // Analytics
    var maxTemperature: Double? {
        records.compactMap { $0.temperature }.max()
    }
    
    var averageTemperature: Double? {
        let temps = records.compactMap { $0.temperature }
        guard !temps.isEmpty else { return nil }
        return temps.reduce(0, +) / Double(temps.count)
    }
    
    var mostCommonSymptom: String? {
        let allSymptoms = records.compactMap { $0.symptoms }
            .flatMap { $0.components(separatedBy: ",") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var symptomCount: [String: Int] = [:]
        for symptom in allSymptoms {
            symptomCount[symptom, default: 0] += 1
        }
        
        return symptomCount.max(by: { $0.value < $1.value })?.key
    }
}
