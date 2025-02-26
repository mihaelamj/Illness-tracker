import Foundation
import CloudKit
import UniformTypeIdentifiers

// Types of attachments
enum AttachmentType: String, Codable {
    case pdf
    case image
    case textNote
}

// Attachment model
struct Attachment: Identifiable, Codable, Equatable {
    var id = UUID()
    var illnessID: UUID
    var fileName: String
    var fileData: Data?
    var fileURL: URL?
    var type: AttachmentType
    var creationDate: Date
    var ckRecordID: String?
    var assetKey: String?
    
    static func == (lhs: Attachment, rhs: Attachment) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Convert to CloudKit record
    func toCloudKitRecord() -> CKRecord {
        let recordID = ckRecordID != nil ? CKRecord.ID(recordName: ckRecordID!) : CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: "Attachment", recordID: recordID)
        
        record["illnessID"] = illnessID.uuidString as CKRecordValue
        record["fileName"] = fileName as CKRecordValue
        record["type"] = type.rawValue as CKRecordValue
        record["creationDate"] = creationDate as CKRecordValue
        
        if let data = fileData {
            // Create and store the file asset
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString)
            
            do {
                try data.write(to: tempFileURL)
                let asset = CKAsset(fileURL: tempFileURL)
                record["fileAsset"] = asset
            } catch {
                print("Error creating asset: \(error)")
            }
        }
        
        return record
    }
    
    // Create from CloudKit record
    static func fromCloudKitRecord(_ record: CKRecord) -> Attachment? {
        guard let illnessIDString = record["illnessID"] as? String,
              let illnessID = UUID(uuidString: illnessIDString),
              let fileName = record["fileName"] as? String,
              let typeString = record["type"] as? String,
              let type = AttachmentType(rawValue: typeString),
              let creationDate = record["creationDate"] as? Date
        else { return nil }
        
        var attachment = Attachment(
            id: UUID(),
            illnessID: illnessID,
            fileName: fileName,
            type: type,
            creationDate: creationDate,
            ckRecordID: record.recordID.recordName
        )
        
        // Handle file asset
        if let asset = record["fileAsset"] as? CKAsset, let fileURL = asset.fileURL {
            do {
                attachment.fileData = try Data(contentsOf: fileURL)
                attachment.fileURL = fileURL
            } catch {
                print("Error reading asset data: \(error)")
            }
        }
        
        return attachment
    }
}
