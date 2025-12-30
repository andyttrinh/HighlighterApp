//
//  ShareViewController.swift
//  HighlighterShareExtension
//
//  Created by Andy Trinh on 12/26/25.
//

import UIKit
import CoreData
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    private let appGroupID = "group.com.andytrinh.HighlighterApp"
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HighlighterApp")
        let description = NSPersistentStoreDescription()
        if let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("HighlighterApp.sqlite") {
            description.url = storeURL
        }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                Self.resetPersistentStore(at: storeDescription.url)
                container.loadPersistentStores { _, reloadError in
                    if let reloadError = reloadError as NSError? {
                        fatalError("Unresolved error \(reloadError), \(reloadError.userInfo)")
                    }
                }
            }
        }
        return container
    }()

    private let textView = UITextView()
    private let tagsField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadSharedText()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "New Highlight"
        titleLabel.font = .preferredFont(forTextStyle: .headline)

        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true

        tagsField.font = .preferredFont(forTextStyle: .body)
        tagsField.placeholder = "comma,separated,tags"
        tagsField.borderStyle = .roundedRect
        tagsField.autocapitalizationType = .none
        tagsField.autocorrectionType = .no

        statusLabel.font = .preferredFont(forTextStyle: .caption1)
        statusLabel.textColor = .secondaryLabel
        statusLabel.text = "Loading shared text..."

        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, UIView(), saveButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            textView,
            tagsField,
            statusLabel,
            buttonStack
        ])
        stack.axis = .vertical
        stack.spacing = 12

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140)
        ])
    }

    private func loadSharedText() {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            statusLabel.text = "No shared content."
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
            let trimmed = capturedText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.textView.text = trimmed
            self.statusLabel.text = trimmed.isEmpty ? "No text found." : "Ready to save."
        }
    }

    @objc private func saveTapped() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            statusLabel.text = "Please enter text before saving."
            return
        }

        insertHighlight(text: text, tags: tagsField.text ?? "")
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    @objc private func cancelTapped() {
        extensionContext?.cancelRequest(withError: NSError(domain: "HighlighterApp.Share", code: 0))
    }

    private func insertHighlight(text: String, tags: String) {
        let context = persistentContainer.viewContext
        let highlight = Highlight(context: context)
        highlight.id = UUID()
        highlight.text = text
        highlight.tags = tags.trimmingCharacters(in: .whitespacesAndNewlines)
        highlight.createdAt = Date()
        highlight.sourceApp = nil

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
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
