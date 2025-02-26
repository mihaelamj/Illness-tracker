import Foundation
import CloudKit

// Define our core data model
struct HealthRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var illnessID: UUID
    var timestamp: Date
    var temperature: Double?
    var treatment: String?
    var symptoms: String?
    var ckRecordID: String?
    var sampleDate: String?
    var sampleTime: String?
    
    // Helper computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: timestamp)
    }
    
    var formattedTemperature: String {
        if let temp = temperature {
            return String(format: "%.1f°", temp)
        }
        return "N/A"
    }
    
    var hasFever: Bool {
        if let temp = temperature {
            return temp >= 37.5
        }
        return false
    }
    
    var highFever: Bool {
        if let temp = temperature {
            return temp >= 38.5
        }
        return false
    }
    
    static func == (lhs: HealthRecord, rhs: HealthRecord) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Convert to CloudKit record
    func toCloudKitRecord() -> CKRecord {
        let recordID = ckRecordID != nil ? CKRecord.ID(recordName: ckRecordID!) : CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: "HealthRecord", recordID: recordID)
        
        record["illnessID"] = illnessID.uuidString as CKRecordValue
        record["timestamp"] = timestamp as CKRecordValue
        if let temp = temperature {
            record["temperature"] = temp as CKRecordValue
        }
        if let treat = treatment {
            record["treatment"] = treat as CKRecordValue
        }
        if let symp = symptoms {
            record["symptoms"] = symp as CKRecordValue
        }
        if let date = sampleDate {
            record["sampleDate"] = date as CKRecordValue
        }
        if let time = sampleTime {
            record["sampleTime"] = time as CKRecordValue
        }
        
        return record
    }
    
    // Create from CloudKit record
    static func fromCloudKitRecord(_ record: CKRecord) -> HealthRecord? {
        guard let illnessIDString = record["illnessID"] as? String,
              let illnessID = UUID(uuidString: illnessIDString),
              let timestamp = record["timestamp"] as? Date
        else { return nil }
        
        let temperature = record["temperature"] as? Double
        let treatment = record["treatment"] as? String
        let symptoms = record["symptoms"] as? String
        let sampleDate = record["sampleDate"] as? String
        let sampleTime = record["sampleTime"] as? String
        
        return HealthRecord(
            id: UUID(),
            illnessID: illnessID,
            timestamp: timestamp,
            temperature: temperature,
            treatment: treatment,
            symptoms: symptoms,
            ckRecordID: record.recordID.recordName,
            sampleDate: sampleDate,
            sampleTime: sampleTime
        )
    }
}
