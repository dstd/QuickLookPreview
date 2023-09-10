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

    @IBAction func associateWithFileTypes(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Do you really want to associate all supported file types with this application?", comment: "associate confirmation message")
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: NSLocalizedString("Yes", comment: "yes"))
        alert.addButton(withTitle: NSLocalizedString("No", comment: "no"))
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            for type in supportedTypes {
                associateWith(type: type)
            }
        }
    }

    @IBAction func unassociateWithFileTypes(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Do you really want to cancel association with supported file types?", comment: "unassociate confirmation message")
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: NSLocalizedString("Yes", comment: "yes"))
        alert.addButton(withTitle: NSLocalizedString("No", comment: "no"))
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            for type in supportedTypes {
                unassociateWith(type: type)
            }
        }
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

extension AppDelegate {
    private func associateWith(type: String) {
        guard let ownId = Bundle.main.bundleIdentifier else { return }

        let current = LSCopyDefaultRoleHandlerForContentType(type as CFString, .viewer)?.takeRetainedValue() as? String
        if let current, current.caseInsensitiveCompare(ownId) != .orderedSame, current != dummyId {
            UserDefaults.standard.setValue(current, forKey: keyForSavedType(type))
        }

        LSSetDefaultRoleHandlerForContentType(type as CFString, .viewer, ownId as CFString)
    }

    private func unassociateWith(type: String) {
        guard let ownId = Bundle.main.bundleIdentifier else { return }

        guard let current = LSCopyDefaultRoleHandlerForContentType(type as CFString, .viewer)?.takeRetainedValue() as? String else { return }
        guard current.caseInsensitiveCompare(ownId) == .orderedSame else { return }

        let prevHandler = UserDefaults.standard.string(forKey: keyForSavedType(type)) ?? dummyId
        LSSetDefaultRoleHandlerForContentType(type as CFString, .viewer, prevHandler as CFString)
    }
}

private func keyForSavedType(_ type: String) -> String { "saved." + type }

private let dummyId = ""
private let supportedTypes = [
    "com.adobe.pdf",
    "public.jpeg",
    "public.png",
    "com.microsoft.bmp",
    "com.compuserve.gif",
    "com.adobe.photoshop-image",
    "public.mpeg",
    "public.mpeg-2-video",
    "public.mpeg-4",
    "public.avi",

    "com.microsoft.waveform-audio",
    "public.mp3",
    "public.mpeg-4-audio",

    "public.plain-text",
    "public.rtf",

    "com.microsoft.word.doc",
    "org.openxmlformats.wordprocessingml.document",
    "org.oasis-open.opendocument.text",

    "com.microsoft.excel.xls",
    "org.openxmlformats.spreadsheetml.sheet",
    "org.oasis-open.opendocument.spreadsheet",

    "com.microsoft.powerpoint.ppt",
    "org.openxmlformats.presentationml.presentation",
    "org.oasis-open.opendocument.presentation",
]
