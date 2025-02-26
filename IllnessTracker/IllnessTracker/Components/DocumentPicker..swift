import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    let illnessID: UUID
    var viewModel: AttachmentViewModel
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [
            .pdf,
            .text,
            .image
        ])
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = false
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let fileName = url.lastPathComponent
                
                // Determine attachment type
                var attachmentType: AttachmentType = .textNote
                if url.pathExtension.lowercased() == "pdf" {
                    attachmentType = .pdf
                } else if ["jpg", "jpeg", "png", "heic"].contains(url.pathExtension.lowercased()) {
                    attachmentType = .image
                }
                
                // Save the attachment
                DispatchQueue.main.async {
                    self.parent.viewModel.addAttachment(
                        data: data,
                        fileName: fileName,
                        type: attachmentType
                    )
                }
            } catch {
                print("Error loading file: \(error)")
            }
        }
    }
}
