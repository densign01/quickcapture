browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("Received request: ", request);

    if (request.action === "captureArticle") {
        console.log("Processing article capture:", request);
        
        // Send message to native app via Safari's native messaging
        browser.runtime.sendNativeMessage("application.id", {
            action: "captureArticle",
            url: request.url,
            title: request.title
        }).then(response => {
            console.log("Native app response:", response);
            sendResponse(response);
        }).catch(error => {
            console.error("Native app error:", error);
            sendResponse({
                success: false,
                error: "Failed to communicate with Brief app: " + error.message
            });
        });
        
        // Return true to indicate we'll respond asynchronously
        return true;
    }
    
    if (request.greeting === "hello") {
        return Promise.resolve({ farewell: "goodbye" });
    }
});
