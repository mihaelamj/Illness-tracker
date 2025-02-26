import Foundation
import CloudKit

// Service protocol for attachments
protocol AttachmentService {
    func loadAttachments(forIllness illnessID: UUID, completion: @escaping ([Attachment]) -> Void)
    func saveAttachment(_ attachment: Attachment, completion: @escaping (Attachment?) -> Void)
    func deleteAttachment(_ attachment: Attachment, completion: @escaping (Bool) -> Void)
}

// CloudKit implementation for Attachment
class CloudAttachmentService: AttachmentService {
    private let container: CKContainer
    private let database: CKDatabase
    
    init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
    }
    
    func loadAttachments(forIllness illnessID: UUID, completion: @escaping ([Attachment]) -> Void) {
        let predicate = NSPredicate(format: "illnessID == %@", illnessID.uuidString)
        let query = CKQuery(recordType: "Attachment", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
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
                
                let attachments = records.compactMap { Attachment.fromCloudKitRecord($0) }
                completion(attachments)
            }
        }
    }
    
    func saveAttachment(_ attachment: Attachment, completion: @escaping (Attachment?) -> Void) {
        let cloudRecord = attachment.toCloudKitRecord()
        
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
                
                let attachment = Attachment.fromCloudKitRecord(savedRecord)
                completion(attachment)
            }
        }
    }
    
    func deleteAttachment(_ attachment: Attachment, completion: @escaping (Bool) -> Void) {
        guard let ckRecordID = attachment.ckRecordID else {
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
}
