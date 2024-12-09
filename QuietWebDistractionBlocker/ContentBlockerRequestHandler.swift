//
//  ContentBlockerRequestHandler.swift
//  QuietWebDistractionBlocker
//
//  Created by Kevin Galarza on 8/15/24.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    let appGroupID = "group.com.galarza.QuietWeb"

    func beginRequest(with context: NSExtensionContext) {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?.appendingPathComponent("masterDistractionsBlocklist.json") else {
            print("Failed to get container URL for app group.")
            let error = NSError(domain: "ContentBlocker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get container URL for app group"])
            context.cancelRequest(withError: error)
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let attachment = NSItemProvider(item: data as NSSecureCoding, typeIdentifier: kUTTypeJSON as String)
            
            let item = NSExtensionItem()
            item.attachments = [attachment]
            
            context.completeRequest(returningItems: [item], completionHandler: nil)
        } catch {
            print("Failed to read blocklist: \(error)")
            let error = NSError(domain: "ContentBlocker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read blocklist"])
            context.cancelRequest(withError: error)
        }
    }
}
