import Foundation

// Mock service for attachments (for development without CloudKit)
class MockAttachmentService: AttachmentService {
    private var attachments: [Attachment] = []
    private let defaults = UserDefaults.standard
    private let storageKey = "storedAttachments"
    
    init() {
        loadFromStorage()
    }
    
    private func loadFromStorage() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Attachment].self, from: data) {
            attachments = decoded
        }
    }
    
    private func saveToStorage() {
        // Note: This might not work well for large file data
        // You might want to save attachments to documents directory instead
        if let encoded = try? JSONEncoder().encode(attachments) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
    
    func loadAttachments(forIllness illnessID: UUID, completion: @escaping ([Attachment]) -> Void) {
        let filteredAttachments = attachments.filter { $0.illnessID == illnessID }
        completion(filteredAttachments)
    }
    
    func saveAttachment(_ attachment: Attachment, completion: @escaping (Attachment?) -> Void) {
        var newAttachment = attachment
        
        // Add "mock" CloudKit record ID
        if newAttachment.ckRecordID == nil {
            newAttachment.ckRecordID = "mock-" + newAttachment.id.uuidString
        }
        
        // Replace existing or add new
        if let index = attachments.firstIndex(where: { $0.id == attachment.id }) {
            attachments[index] = newAttachment
        } else {
            attachments.append(newAttachment)
        }
        
        saveToStorage()
        completion(newAttachment)
    }
    
    func deleteAttachment(_ attachment: Attachment, completion: @escaping (Bool) -> Void) {
        attachments.removeAll { $0.id == attachment.id }
        saveToStorage()
        completion(true)
    }
}
