//
//  HighlightEditorView.swift
//  HighlighterApp
//
//  Created by Andy Trinh on 12/26/25.
//

import SwiftUI
import CoreData

struct HighlightEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var highlight: Highlight
    @State private var text: String
    @State private var tags: String

    init(highlight: Highlight) {
        self.highlight = highlight
        _text = State(initialValue: highlight.text ?? "")
        _tags = State(initialValue: highlight.tags ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Highlight") {
                    TextEditor(text: $text)
                        .frame(minHeight: 160)
                }

                Section("Tags") {
                    TextField("comma,separated,tags", text: $tags)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Edit Highlight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        cancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
        }
    }

    private func cancel() {
        if highlight.isInserted {
            viewContext.delete(highlight)
        }
        dismiss()
    }

    private func save() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        highlight.text = trimmedText
        highlight.tags = tags.trimmingCharacters(in: .whitespacesAndNewlines)
        highlight.updatedAt = Date()

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let highlight = Highlight(context: context)
    highlight.id = UUID()
    highlight.text = "Preview highlight"
    highlight.createdAt = Date()
    return HighlightEditorView(highlight: highlight)
        .environment(\.managedObjectContext, context)
}
