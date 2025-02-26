import SwiftUI

struct NoteEntryView: View {
    let illnessID: UUID
    var viewModel: AttachmentViewModel
    @Binding var isPresented: Bool
    
    @State private var noteTitle = ""
    @State private var noteContent = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Title")) {
                    TextField("Title", text: $noteTitle)
                }
                
                Section(header: Text("Note Content")) {
                    TextEditor(text: $noteContent)
                        .frame(minHeight: 200)
                }
                
                Section {
                    Button {
                        saveNote()
                    } label: {
                        Text("Save Note")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fontWeight(.medium)
                    }
                    .disabled(noteTitle.isEmpty || noteContent.isEmpty)
                }
            }
            .navigationTitle("Add Note")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveNote()
                }
                .disabled(noteTitle.isEmpty || noteContent.isEmpty)
            )
        }
    }
    
    private func saveNote() {
        guard !noteTitle.isEmpty && !noteContent.isEmpty else { return }
        
        // Create a text note
        let noteText = "# \(noteTitle)\n\n\(noteContent)"
        if let data = noteText.data(using: .utf8) {
            viewModel.addAttachment(
                data: data,
                fileName: "\(noteTitle).txt",
                type: .textNote
            )
        }
        
        isPresented = false
    }
}
