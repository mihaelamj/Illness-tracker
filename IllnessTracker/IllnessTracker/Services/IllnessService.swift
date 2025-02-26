import Foundation
import CloudKit

// Service protocol for illness management
protocol IllnessService {
    func loadIllnesses(completion: @escaping ([Illness]) -> Void)
    func saveIllness(_ illness: Illness, completion: @escaping (Illness?) -> Void)
    func deleteIllness(_ illness: Illness, completion: @escaping (Bool) -> Void)
    func syncIllnesses(completion: @escaping () -> Void)
}

// CloudKit implementation for Illness
class CloudIllnessService: IllnessService {
    private let container: CKContainer
    private let database: CKDatabase
    
    init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
    }
    
    func loadIllnesses(completion: @escaping ([Illness]) -> Void) {
        let query = CKQuery(recordType: "Illness", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
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
                
                let illnesses = records.compactMap { Illness.fromCloudKitRecord($0) }
                completion(illnesses)
            }
        }
    }
    
    func saveIllness(_ illness: Illness, completion: @escaping (Illness?) -> Void) {
        let cloudRecord = illness.toCloudKitRecord()
        
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
                
                let illness = Illness.fromCloudKitRecord(savedRecord)
                completion(illness)
            }
        }
    }
    
    func deleteIllness(_ illness: Illness, completion: @escaping (Bool) -> Void) {
        guard let ckRecordID = illness.ckRecordID else {
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
    
    func syncIllnesses(completion: @escaping () -> Void) {
        loadIllnesses { _ in
            completion()
        }
    }
}
