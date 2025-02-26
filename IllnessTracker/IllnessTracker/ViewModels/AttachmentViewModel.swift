import Foundation
import SwiftUI
import Combine

// ViewModel for attachments
class AttachmentViewModel: ObservableObject {
    @Published var attachments: [Attachment] = []
    @Published var isLoading: Bool = false
    
    private let service: AttachmentService
    private let illnessID: UUID
    
    init(service: AttachmentService, illnessID: UUID) {
        self.service = service
        self.illnessID = illnessID
        loadAttachments()
    }
    
    func loadAttachments() {
        isLoading = true
        service.loadAttachments(forIllness: illnessID) { [weak self] loadedAttachments in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.attachments = loadedAttachments
                self.isLoading = false
            }
        }
    }
    
    func addAttachment(data: Data, fileName: String, type: AttachmentType) {
        let attachment = Attachment(
            illnessID: illnessID,
            fileName: fileName,
            fileData: data,
            type: type,
            creationDate: Date()
        )
        
        service.saveAttachment(attachment) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadAttachments()
            }
        }
    }
    
    func deleteAttachment(_ attachment: Attachment) {
        service.deleteAttachment(attachment) { [weak self] success in
            guard let self = self, success else { return }
            DispatchQueue.main.async {
                self.loadAttachments()
            }
        }
    }
}
