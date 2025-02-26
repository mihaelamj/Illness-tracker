import SwiftUI
import PDFKit

struct AttachmentListView: View {
    let illness: Illness
    @StateObject private var viewModel: AttachmentViewModel
    @State private var showingDocumentPicker = false
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var showingNoteEntry = false
    @State private var selectedAttachment: Attachment?
    
    init(illness: Illness) {
        self.illness = illness
        self._viewModel = StateObject(wrappedValue: AttachmentViewModel(
            service: MockAttachmentService(),
            illnessID: illness.id
        ))
    }
    
    var body: some View {
        List {
            if viewModel.attachments.isEmpty {
                Text("No attachments yet. Add attachments using the + button.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ForEach(viewModel.attachments) { attachment in
                    Button {
                        selectedAttachment = attachment
                    } label: {
                        AttachmentRow(attachment: attachment)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let attachment = viewModel.attachments[index]
                        viewModel.deleteAttachment(attachment)
                    }
                }
            }
        }
        .navigationTitle("Attachments")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingDocumentPicker = true
                    } label: {
                        Label("Add Document", systemImage: "doc")
                    }
                    
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                    
                    Button {
                        showingPhotoLibrary = true
                    } label: {
                        Label("Photo Library", systemImage: "photo")
                    }
                    
                    Button {
                        showingNoteEntry = true
                    } label: {
                        Label("Add Note", systemImage: "note.text")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(illnessID: illness.id, viewModel: viewModel)
        }
        .sheet(isPresented: $showingNoteEntry) {
            NoteEntryView(illnessID: illness.id, viewModel: viewModel, isPresented: $showingNoteEntry)
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            // In a complete app, you'd implement ImagePicker here
            Text("Photo library picker would appear here")
                .padding()
        }
        .sheet(isPresented: $showingCamera) {
            // In a complete app, you'd implement CameraPicker here
            Text("Camera would appear here")
                .padding()
        }
        .sheet(item: $selectedAttachment) { attachment in
            AttachmentDetailView(attachment: attachment)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading attachments...")
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(10)
            }
        }
        .refreshable {
            viewModel.loadAttachments()
        }
    }
}

struct AttachmentRow: View {
    let attachment: Attachment
    
    var body: some View {
        HStack {
            attachmentIcon
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(attachment.fileName)
                    .fontWeight(.medium)
                Text(formatDate(attachment.creationDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
    
    var attachmentIcon: some View {
        Group {
            switch attachment.type {
            case .pdf:
                Image(systemName: "doc.fill")
            case .image:
                Image(systemName: "photo.fill")
            case .textNote:
                Image(systemName: "note.text")
            }
        }
    }
    
    var iconColor: Color {
        switch attachment.type {
        case .pdf:
            return .red
        case .image:
            return .blue
        case .textNote:
            return .green
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AttachmentDetailView: View {
    let attachment: Attachment
    
    var body: some View {
        VStack {
            switch attachment.type {
            case .pdf:
                if let data = attachment.fileData {
                    PDFKitView(data: data)
                } else {
                    Text("Unable to load PDF data")
                        .foregroundColor(.red)
                }
            case .image:
                if let data = attachment.fileData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Unable to load image")
                        .foregroundColor(.red)
                }
            case .textNote:
                if let data = attachment.fileData, let noteText = String(data: data, encoding: .utf8) {
                    ScrollView {
                        Text(noteText)
                            .padding()
                    }
                } else {
                    Text("Unable to load note")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(attachment.fileName)
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if let pdfDocument = PDFDocument(data: data) {
            uiView.document = pdfDocument
        }
    }
}
