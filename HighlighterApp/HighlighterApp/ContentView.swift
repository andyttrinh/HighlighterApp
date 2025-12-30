//
//  ContentView.swift
//  HighlighterApp
//
//  Created by Andy Trinh on 12/26/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var activeHighlight: Highlight?
    @State private var isEditing = false
    @State private var refreshToken = UUID()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Highlight.createdAt, ascending: false)],
        animation: .default)
    private var highlights: FetchedResults<Highlight>

    var body: some View {
        NavigationStack {
            List {
                ForEach(highlights) { highlight in
                    Button {
                        beginEditing(highlight)
                    } label: {
                        HighlightRow(highlight: highlight)
                    }
                }
                .onDelete(perform: deleteHighlights)
            }
            .id(refreshToken)
            .refreshable {
                await refreshHighlights()
            }
            .navigationTitle("Highlights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addHighlight) {
                        Label("Add Highlight", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                if let highlight = activeHighlight {
                    HighlightEditorView(highlight: highlight)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    private func beginEditing(_ highlight: Highlight) {
        activeHighlight = highlight
        isEditing = true
    }

    private func addHighlight() {
        let highlight = Highlight(context: viewContext)
        highlight.id = UUID()
        highlight.text = ""
        highlight.createdAt = Date()
        beginEditing(highlight)
    }

    private func deleteHighlights(offsets: IndexSet) {
        withAnimation {
            offsets.map { highlights[$0] }.forEach(viewContext.delete)
            saveChanges()
        }
    }

    private func saveChanges() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func refreshHighlights() async {
        await PersistenceController.shared.processPersistentHistory()
        await MainActor.run {
            viewContext.refreshAllObjects()
            refreshToken = UUID()
        }
    }
}

private struct HighlightRow: View {
    @ObservedObject var highlight: Highlight

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(highlight.text ?? "")
                .font(.body)
                .lineLimit(2)
            HStack(spacing: 12) {
                Text(highlight.createdAt ?? Date(), formatter: dateFormatter)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let tags = highlight.tags, !tags.isEmpty {
                    Text(tags)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
