//
//  EmptyDocumentViewController.swift
//  Subler
//
//  Created by Antigravity on 05/06/2026.
//

import Cocoa

protocol EmptyDocumentViewControllerDelegate: AnyObject {
    @MainActor func emptyDocumentViewControllerDidRequestBrowseFiles(_ controller: EmptyDocumentViewController)
    @MainActor func emptyDocumentViewController(_ controller: EmptyDocumentViewController, didDropFiles files: [URL])
}

final class EmptyDocumentViewController: NSViewController {
    
    weak var delegate: EmptyDocumentViewControllerDelegate?
    
    private let containerView = NSView()
    private let titleLabel = NSTextField(labelWithString: "Drag & Drop Files Here")
    private let subtitleLabel = NSTextField(labelWithString: "Supports MP4, MKV, M4V, AAC, SRT, etc.")
    private let browseButton = NSButton()
    private let boxView = NSBox()
    
    override func loadView() {
        let effectView = NSVisualEffectView()
        effectView.blendingMode = .withinWindow
        effectView.material = .windowBackground
        effectView.state = .active
        self.view = effectView
        
        // Register view for dragging
        effectView.registerForDraggedTypes([.fileURL])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        boxView.translatesAutoresizingMaskIntoConstraints = false
        boxView.boxType = .custom
        boxView.borderType = .lineBorder
        boxView.borderColor = NSColor.separatorColor
        boxView.borderWidth = 2
        boxView.cornerRadius = 16
        boxView.fillColor = NSColor.controlBackgroundColor.withAlphaComponent(0.2)
        containerView.addSubview(boxView)
        
        let iconView: NSImageView
        if #available(macOS 11.0, *) {
            let icon = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: "Import files")
            iconView = NSImageView(image: icon ?? NSImage())
            iconView.contentTintColor = NSColor.secondaryLabelColor
        } else {
            iconView = NSImageView(image: NSImage(named: NSImage.addTemplateName) ?? NSImage())
        }
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyUpOrDown
        boxView.addSubview(iconView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = NSColor.labelColor
        titleLabel.alignment = .center
        boxView.addSubview(titleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = NSColor.secondaryLabelColor
        subtitleLabel.alignment = .center
        boxView.addSubview(subtitleLabel)
        
        browseButton.translatesAutoresizingMaskIntoConstraints = false
        browseButton.title = "Choose Files..."
        browseButton.bezelStyle = .rounded
        browseButton.target = self
        browseButton.action = #selector(browseClicked)
        browseButton.controlSize = .large
        boxView.addSubview(browseButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 400),
            containerView.heightAnchor.constraint(equalToConstant: 300),
            
            boxView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            boxView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            boxView.topAnchor.constraint(equalTo: containerView.topAnchor),
            boxView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconView.centerXAnchor.constraint(equalTo: boxView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: boxView.topAnchor, constant: 40),
            iconView.widthAnchor.constraint(equalToConstant: 64),
            iconView.heightAnchor.constraint(equalToConstant: 64),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: boxView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: boxView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: boxView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: boxView.trailingAnchor, constant: -20),
            
            browseButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            browseButton.centerXAnchor.constraint(equalTo: boxView.centerXAnchor),
            browseButton.bottomAnchor.constraint(lessThanOrEqualTo: boxView.bottomAnchor, constant: -40)
        ])
    }
    
    @objc private func browseClicked() {
        delegate?.emptyDocumentViewControllerDidRequestBrowseFiles(self)
    }
}

// MARK: - NSDraggingDestination Extension
extension EmptyDocumentViewController {
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard let types = sender.draggingPasteboard.types,
              types.contains(.fileURL) else { return [] }
        
        boxView.borderColor = NSColor.controlAccentColor
        boxView.fillColor = NSColor.controlBackgroundColor.withAlphaComponent(0.4)
        return .copy
    }
    
    func draggingExited(_ sender: NSDraggingInfo?) {
        boxView.borderColor = NSColor.separatorColor
        boxView.fillColor = NSColor.controlBackgroundColor.withAlphaComponent(0.2)
    }
    
    func draggingEnded(_ sender: NSDraggingInfo) {
        boxView.borderColor = NSColor.separatorColor
        boxView.fillColor = NSColor.controlBackgroundColor.withAlphaComponent(0.2)
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        guard let items = pasteboard.readObjects(forClasses: [NSURL.classForCoder()], options: [:]) as? [URL] else { return false }
        
        delegate?.emptyDocumentViewController(self, didDropFiles: items)
        return true
    }
}
