import Foundation

// Mock service for illness management (for development without CloudKit)
class MockIllnessService: IllnessService {
    private var illnesses: [Illness] = []
    private let defaults = UserDefaults.standard
    private let storageKey = "storedIllnesses"
    
    init() {
        loadFromStorage()
    }
    
    private func loadFromStorage() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Illness].self, from: data) {
            illnesses = decoded
        }
    }
    
    private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(illnesses) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
    
    func loadIllnesses(completion: @escaping ([Illness]) -> Void) {
        completion(illnesses)
    }
    
    func saveIllness(_ illness: Illness, completion: @escaping (Illness?) -> Void) {
        var newIllness = illness
        
        // Add "mock" CloudKit record ID
        if newIllness.ckRecordID == nil {
            newIllness.ckRecordID = "mock-" + newIllness.id.uuidString
        }
        
        // Replace existing or add new
        if let index = illnesses.firstIndex(where: { $0.id == illness.id }) {
            illnesses[index] = newIllness
        } else {
            illnesses.append(newIllness)
        }
        
        saveToStorage()
        completion(newIllness)
    }
    
    func deleteIllness(_ illness: Illness, completion: @escaping (Bool) -> Void) {
        illnesses.removeAll { $0.id == illness.id }
        saveToStorage()
        completion(true)
    }
    
    func syncIllnesses(completion: @escaping () -> Void) {
        // No sync needed for mock service
        completion()
    }
}
