//
//  ShareViewController.swift
//  HighlighterShareExtension
//
//  Created by Andy Trinh on 12/26/25.
//

import UIKit
import Social
import CoreData
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    private let appGroupID = "group.com.andytrinh.HighlighterApp"
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HighlighterApp")
        let description = NSPersistentStoreDescription()
        if let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("HighlighterApp.sqlite") {
            description.url = storeURL
        }
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        saveSharedText {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

    private func saveSharedText(completion: @escaping () -> Void) {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completion()
            return
        }

        let providers = inputItems.flatMap { $0.attachments ?? [] }
        let group = DispatchGroup()
        var capturedText: String?

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, _ in
                    if capturedText == nil {
                        if let text = item as? String {
                            capturedText = text
                        } else if let url = item as? URL {
                            capturedText = url.absoluteString
                        }
                    }
                    group.leave()
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, _ in
                    if capturedText == nil, let url = item as? URL {
                        capturedText = url.absoluteString
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            if let text = capturedText?.trimmingCharacters(in: .whitespacesAndNewlines),
               !text.isEmpty {
                self.insertHighlight(text: text)
            }
            completion()
        }
    }

    private func insertHighlight(text: String) {
        let context = persistentContainer.viewContext
        let highlight = Highlight(context: context)
        highlight.id = UUID()
        highlight.text = text
        highlight.createdAt = Date()
        highlight.sourceApp = nil

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
