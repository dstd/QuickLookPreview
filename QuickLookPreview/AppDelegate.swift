//
//  AppDelegate.swift
//  QuickLookPreview
//
//  Created by Denis Stanishevskiy on 08.09.2023.
//

import Cocoa
import QuickLookUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        showPreview(uris: [NSURL(fileURLWithPath: filename)])
        return true
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        showPreview(uris: filenames.map { NSURL(fileURLWithPath: $0) })
    }

    private var previewUris = [NSURL]()
}

extension AppDelegate {
    func showPreview(uris: [NSURL]) {
        guard let panel = QLPreviewPanel.shared() else { return }
        self.previewUris = uris
        panel.makeKeyAndOrderFront(self)
    }
}

extension AppDelegate: QLPreviewPanelDataSource {
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return previewUris.count
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return previewUris[index]
    }

    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        return true
    }

    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.delegate = self
        panel.dataSource = self
    }

    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.delegate = nil
        panel.dataSource = nil
        previewUris = []

        NSApplication.shared.terminate(nil)
    }
}
