import Foundation
import CloudKit
import SwiftUI

// Illness tracking model
struct Illness: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var patientName: String
    var startDate: Date
    var endDate: Date?
    var notes: String?
    var ckRecordID: String?
    
    var isActive: Bool {
        return endDate == nil
    }
    
    static func == (lhs: Illness, rhs: Illness) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Convert to CloudKit record
    func toCloudKitRecord() -> CKRecord {
        let recordID = ckRecordID != nil ? CKRecord.ID(recordName: ckRecordID!) : CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: "Illness", recordID: recordID)
        
        record["patientName"] = patientName as CKRecordValue
        record["startDate"] = startDate as CKRecordValue
        if let end = endDate {
            record["endDate"] = end as CKRecordValue
        }
        if let illnessNotes = notes {
            record["notes"] = illnessNotes as CKRecordValue
        }
        
        return record
    }
    
    // Create from CloudKit record
    static func fromCloudKitRecord(_ record: CKRecord) -> Illness {
        let patientName = record["patientName"] as? String ?? "Unknown"
        let startDate = record["startDate"] as? Date ?? Date()
        let endDate = record["endDate"] as? Date
        let notes = record["notes"] as? String
        
        return Illness(
            id: UUID(),
            patientName: patientName,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            ckRecordID: record.recordID.recordName
        )
    }
}
