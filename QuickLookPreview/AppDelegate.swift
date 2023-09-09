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
        showPreview(uri: NSURL(fileURLWithPath: filename))
        return true
    }

    private var previewUri: NSURL?
}

extension AppDelegate {
    func showPreview(uri: NSURL) {
        guard let panel = QLPreviewPanel.shared() else { return }
        self.previewUri = uri
        panel.makeKeyAndOrderFront(self)
    }
}

extension AppDelegate: QLPreviewPanelDataSource {
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return 1
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return previewUri
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

        NSApplication.shared.terminate(nil)
    }
}
