import Foundation
import CloudKit

// Service protocol for health records
protocol HealthRecordService {
    func loadRecords(forIllness illnessID: UUID?, completion: @escaping ([HealthRecord]) -> Void)
    func saveRecord(_ record: HealthRecord, completion: @escaping (HealthRecord?) -> Void)
    func deleteRecord(_ record: HealthRecord, completion: @escaping (Bool) -> Void)
    func syncRecords(completion: @escaping () -> Void)
}

// CloudKit implementation for HealthRecord
class CloudHealthRecordService: HealthRecordService {
    private let container: CKContainer
    private let database: CKDatabase
    
    init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
    }
    
    func loadRecords(forIllness illnessID: UUID?, completion: @escaping ([HealthRecord]) -> Void) {
        var predicate: NSPredicate
        
        if let id = illnessID {
            predicate = NSPredicate(format: "illnessID == %@", id.uuidString)
        } else {
            predicate = NSPredicate(value: true)
        }
        
        let query = CKQuery(recordType: "HealthRecord", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        database.perform(query, inZoneWith: nil) { [weak self] (records, error) in
            guard self != nil else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let records = records else {
                    completion([])
                    return
                }
                
                let healthRecords = records.compactMap { HealthRecord.fromCloudKitRecord($0) }
                completion(healthRecords)
            }
        }
    }
    
    func saveRecord(_ record: HealthRecord, completion: @escaping (HealthRecord?) -> Void) {
        let cloudRecord = record.toCloudKitRecord()
        
        database.save(cloudRecord) { (savedRecord, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit save error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let savedRecord = savedRecord else {
                    completion(nil)
                    return
                }
                
                if let healthRecord = HealthRecord.fromCloudKitRecord(savedRecord) {
                    completion(healthRecord)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func deleteRecord(_ record: HealthRecord, completion: @escaping (Bool) -> Void) {
        guard let ckRecordID = record.ckRecordID else {
            completion(false)
            return
        }
        
        let recordID = CKRecord.ID(recordName: ckRecordID)
        
        database.delete(withRecordID: recordID) { (recordID, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit delete error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    func syncRecords(completion: @escaping () -> Void) {
        loadRecords(forIllness: nil) { _ in
            completion()
        }
    }
}
