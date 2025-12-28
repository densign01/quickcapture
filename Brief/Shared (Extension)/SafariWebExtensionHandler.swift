//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by Daniel Ensign on 8/14/25.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let profile: UUID?
        if #available(iOS 17.0, macOS 14.0, *) {
            profile = request?.userInfo?[SFExtensionProfileKey] as? UUID
        } else {
            profile = request?.userInfo?["profile"] as? UUID
        }

        let message: Any?
        if #available(iOS 15.0, macOS 11.0, *) {
            message = request?.userInfo?[SFExtensionMessageKey]
        } else {
            message = request?.userInfo?["message"]
        }

        os_log(.default, "Received message from browser: %@ (profile: %@)", String(describing: message), profile?.uuidString ?? "none")

        // Handle article capture requests
        if let messageDict = message as? [String: Any],
           let action = messageDict["action"] as? String,
           action == "captureArticle" {
            handleArticleCapture(message: messageDict, context: context)
        } else {
            // Default echo response
            let response = NSExtensionItem()
            if #available(iOS 15.0, macOS 11.0, *) {
                response.userInfo = [ SFExtensionMessageKey: [ "echo": message ] ]
            } else {
                response.userInfo = [ "message": [ "echo": message ] ]
            }
            context.completeRequest(returningItems: [ response ], completionHandler: nil)
        }
    }
    
    private func handleArticleCapture(message: [String: Any], context: NSExtensionContext) {
        guard let url = message["url"] as? String,
              let title = message["title"] as? String else {
            sendResponse(["error": "Missing URL or title"], context: context)
            return
        }
        
        // Get saved preferences
        let defaults = UserDefaults(suiteName: "group.com.danielensign.Brief") ?? UserDefaults.standard
        let email = defaults.string(forKey: "email") ?? ""
        let apiEndpoint = defaults.string(forKey: "apiEndpoint") ?? "https://quickcapture-api.daniel-ensign.workers.dev"
        let aiSummaryEnabled = defaults.bool(forKey: "aiSummaryEnabled")
        let summaryLength = defaults.string(forKey: "summaryLength") ?? "short"
        
        if email.isEmpty {
            sendResponse(["error": "Please set your email in the Brief app first"], context: context)
            return
        }
        
        // Capture context reference safely
        let capturedContext = context
        
        // Send article via API using compatible async approach
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.sendArticleToAPICompat(
                url: url,
                title: title,
                email: email,
                apiEndpoint: apiEndpoint,
                aiSummary: aiSummaryEnabled,
                summaryLength: summaryLength
            ) { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.sendResponse(["error": error.localizedDescription], context: capturedContext)
                    } else {
                        self.sendResponse([
                            "success": success,
                            "message": success ? "Article sent successfully!" : "Failed to send article"
                        ], context: capturedContext)
                    }
                }
            }
        }
    }
    
    private func sendResponse(_ data: [String: Any], context: NSExtensionContext) {
        let response = NSExtensionItem()
        if #available(iOS 15.0, macOS 11.0, *) {
            response.userInfo = [SFExtensionMessageKey: data]
        } else {
            response.userInfo = ["message": data]
        }
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
    
    private func sendArticleToAPICompat(
        url: String,
        title: String,
        email: String,
        apiEndpoint: String,
        aiSummary: Bool,
        summaryLength: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        
        guard let apiURL = URL(string: apiEndpoint) else {
            completion(false, NSError(domain: "BriefError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"]))
            return
        }
        
        let site = URL(string: url)?.host ?? ""
        
        let requestBody: [String: Any] = [
            "url": url,
            "title": title,
            "site": site,
            "email": email,
            "aiSummary": aiSummary,
            "summaryLength": summaryLength
        ]
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(false, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200, nil)
            } else {
                completion(false, NSError(domain: "BriefError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
        }
        
        task.resume()
    }
}
