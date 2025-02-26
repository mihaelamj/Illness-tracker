import Foundation

// Mock service for health records (for development without CloudKit)
class MockHealthRecordService: HealthRecordService {
    private var records: [HealthRecord] = []
    private let defaults = UserDefaults.standard
    private let storageKey = "storedHealthRecords"
    
    init() {
        loadFromStorage()
    }
    
    private func loadFromStorage() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([HealthRecord].self, from: data) {
            records = decoded
        }
    }
    
    private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(records) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
    
    func loadRecords(forIllness illnessID: UUID?, completion: @escaping ([HealthRecord]) -> Void) {
        if let id = illnessID {
            let filteredRecords = records.filter { $0.illnessID == id }
            completion(filteredRecords)
        } else {
            completion(records)
        }
    }
    
    func saveRecord(_ record: HealthRecord, completion: @escaping (HealthRecord?) -> Void) {
        var newRecord = record
        
        // Add "mock" CloudKit record ID
        if newRecord.ckRecordID == nil {
            newRecord.ckRecordID = "mock-" + newRecord.id.uuidString
        }
        
        // Replace existing or add new
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = newRecord
        } else {
            records.append(newRecord)
        }
        
        saveToStorage()
        completion(newRecord)
    }
    
    func deleteRecord(_ record: HealthRecord, completion: @escaping (Bool) -> Void) {
        records.removeAll { $0.id == record.id }
        saveToStorage()
        completion(true)
    }
    
    func syncRecords(completion: @escaping () -> Void) {
        // No sync needed for mock service
        completion()
    }
}
