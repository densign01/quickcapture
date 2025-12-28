import Cocoa
import Social
import UniformTypeIdentifiers

class ShareViewController: NSViewController {
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var urlLabel: NSTextField!
    @IBOutlet weak var contextTextView: NSTextView!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var aiSummaryCheckbox: NSButton!
    @IBOutlet weak var summaryLengthSegmented: NSSegmentedControl!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    private var pageURL: String = ""
    private var pageTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extractSharedContent()
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.stringValue = pageTitle
        urlLabel.stringValue = pageURL
        
        // Load preferences
        let defaults = UserDefaults(suiteName: "group.com.quickcapture.brief")
        aiSummaryCheckbox.state = (defaults?.bool(forKey: "aiSummaryEnabled") ?? false) ? .on : .off
        let summaryLength = defaults?.string(forKey: "summaryLength") ?? "short"
        summaryLengthSegmented.selectedSegment = summaryLength == "short" ? 0 : 1
        
        progressIndicator.isHidden = true
    }
    
    private func extractSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }
        
        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (url, error) in
                        if let url = url as? URL {
                            DispatchQueue.main.async {
                                self?.pageURL = url.absoluteString
                                self?.urlLabel.stringValue = url.absoluteString
                            }
                        }
                    }
                }
                
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (text, error) in
                        if let title = text as? String {
                            DispatchQueue.main.async {
                                self?.pageTitle = title
                                self?.titleLabel.stringValue = title
                            }
                        }
                    }
                }
                
                // Try to get title from URL if not provided
                if attachment.hasItemConformingToTypeIdentifier("public.url-name") {
                    attachment.loadItem(forTypeIdentifier: "public.url-name", options: nil) { [weak self] (title, error) in
                        if let title = title as? String {
                            DispatchQueue.main.async {
                                self?.pageTitle = title
                                self?.titleLabel.stringValue = title
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendButtonClicked(_ sender: NSButton) {
        guard !pageURL.isEmpty else {
            showError("No URL found")
            return
        }
        
        // Get email from shared preferences
        let defaults = UserDefaults(suiteName: "group.com.quickcapture.brief")
        guard let email = defaults?.string(forKey: "email"), !email.isEmpty else {
            showError("Please set your email in the main Brief app first")
            return
        }
        
        guard let apiEndpoint = defaults?.string(forKey: "apiEndpoint"), !apiEndpoint.isEmpty else {
            showError("Please set your API endpoint in the main Brief app first")
            return
        }
        
        // Save current preferences
        defaults?.set(aiSummaryCheckbox.state == .on, forKey: "aiSummaryEnabled")
        defaults?.set(summaryLengthSegmented.selectedSegment == 0 ? "short" : "long", forKey: "summaryLength")
        
        sendButton.isEnabled = false
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        
        Task {
            await sendArticle(
                url: pageURL,
                title: pageTitle.isEmpty ? "Shared Article" : pageTitle,
                email: email,
                apiEndpoint: apiEndpoint,
                context: contextTextView.string.isEmpty ? nil : contextTextView.string,
                aiSummary: aiSummaryCheckbox.state == .on,
                summaryLength: summaryLengthSegmented.selectedSegment == 0 ? "short" : "long"
            )
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: NSButton) {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    private func sendArticle(
        url: String,
        title: String,
        email: String,
        apiEndpoint: String,
        context: String?,
        aiSummary: Bool,
        summaryLength: String
    ) async {
        do {
            guard let apiURL = URL(string: apiEndpoint) else {
                await showErrorOnMain("Invalid API URL")
                return
            }
            
            let site = URL(string: url)?.host ?? ""
            
            let requestBody = [
                "url": url,
                "title": title,
                "site": site,
                "email": email,
                "context": context as Any,
                "aiSummary": aiSummary,
                "summaryLength": summaryLength
            ] as [String: Any]
            
            var request = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                await MainActor.run {
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            } else {
                await showErrorOnMain("Failed to send article")
            }
            
        } catch {
            await showErrorOnMain("Error: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Brief"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
        
        sendButton.isEnabled = true
        progressIndicator.stopAnimation(nil)
        progressIndicator.isHidden = true
    }
    
    private func showErrorOnMain(_ message: String) async {
        await MainActor.run {
            showError(message)
        }
    }
}