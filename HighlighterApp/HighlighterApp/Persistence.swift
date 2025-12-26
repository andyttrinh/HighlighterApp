//
//  Persistence.swift
//  HighlighterApp
//
//  Created by Andy Trinh on 12/26/25.
//

import CoreData

private let appGroupID = "group.com.andytrinh.HighlighterApp"

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let highlight = Highlight(context: viewContext)
            highlight.id = UUID()
            highlight.text = "Sample highlight"
            highlight.createdAt = Date()
            highlight.tags = "sample,preview"
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let container = NSPersistentContainer(name: "HighlighterApp")
        self.container = container
        let description = NSPersistentStoreDescription()
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else if let storeURL = PersistenceController.storeURL() {
            description.url = storeURL
        }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                if !inMemory {
                    PersistenceController.resetPersistentStore(at: storeDescription.url)
                    container.loadPersistentStores { _, reloadError in
                        if let reloadError = reloadError as NSError? {
                            fatalError("Unresolved error \(reloadError), \(reloadError.userInfo)")
                        }
                    }
                } else {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func storeURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("HighlighterApp.sqlite")
    }

    private static func resetPersistentStore(at url: URL?) {
        guard let url else { return }
        let fm = FileManager.default
        let base = url.deletingPathExtension().path
        let files = [
            url.path,
            base + "-shm",
            base + "-wal"
        ]
        for path in files {
            try? fm.removeItem(atPath: path)
        }
    }
}
