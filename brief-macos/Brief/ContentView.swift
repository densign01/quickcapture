import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var url = ""
    @State private var title = ""
    @State private var context = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "doc.text")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("Brief")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Capture articles with AI summaries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 10)
            
            // URL Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Article URL")
                    .font(.headline)
                TextField("https://example.com/article", text: $url)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        analyzeURL()
                    }
                
                HStack {
                    Button("Analyze") {
                        analyzeURL()
                    }
                    .disabled(url.isEmpty || isLoading)
                    
                    Button("Paste from Clipboard") {
                        if let clipboardString = NSPasteboard.general.string(forType: .string) {
                            url = clipboardString
                            analyzeURL()
                        }
                    }
                    .disabled(isLoading)
                }
            }
            
            // Title Display
            if !title.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Article Title")
                        .font(.headline)
                    Text(title)
                        .textSelection(.enabled)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Context Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Personal Note (Optional)")
                    .font(.headline)
                TextEditor(text: $context)
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // AI Summary Options
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Toggle("AI Summary", isOn: $userPreferences.aiSummaryEnabled)
                        .font(.headline)
                    
                    Spacer()
                    
                    if userPreferences.aiSummaryEnabled {
                        Picker("Length", selection: $userPreferences.summaryLength) {
                            Text("Short").tag("short")
                            Text("Long").tag("long")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                }
                
                if userPreferences.aiSummaryEnabled {
                    Text("Generate bullet-point summaries using Claude AI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Send Button
            Button(action: sendArticle) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isLoading ? "Sending..." : "Send to Email")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(url.isEmpty || title.isEmpty || userPreferences.email.isEmpty || isLoading)
            
            Spacer()
        }
        .padding(20)
        .frame(width: 500, height: 600)
        .alert("Brief", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(userPreferences)
        }
    }
    
    private func analyzeURL() {
        guard !url.isEmpty else { return }
        
        // Extract title from URL for now - in a real app you'd fetch the page
        if let urlComponents = URLComponents(string: url) {
            title = urlComponents.host?.replacingOccurrences(of: "www.", with: "") ?? "Article"
        }
    }
    
    private func sendArticle() {
        isLoading = true
        
        let apiService = APIService()
        
        Task {
            do {
                let success = try await apiService.sendArticle(
                    url: url,
                    title: title,
                    email: userPreferences.email,
                    context: context.isEmpty ? nil : context,
                    aiSummary: userPreferences.aiSummaryEnabled,
                    summaryLength: userPreferences.summaryLength
                )
                
                await MainActor.run {
                    isLoading = false
                    if success {
                        alertMessage = "Article sent successfully!"
                        url = ""
                        title = ""
                        context = ""
                    } else {
                        alertMessage = "Failed to send article. Please try again."
                    }
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Error: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.headline)
                TextField("your@email.com", text: $userPreferences.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Your email is stored locally and used only for sending articles")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("API Endpoint")
                    .font(.headline)
                TextField("https://your-api.workers.dev", text: $userPreferences.apiEndpoint)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Your QuickCapture API endpoint")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserPreferences.shared)
}