document.addEventListener('DOMContentLoaded', function() {
    const captureButton = document.getElementById('captureButton');
    const status = document.getElementById('status');
    
    captureButton.addEventListener('click', function() {
        captureButton.disabled = true;
        status.textContent = 'Capturing article...';
        
        // Get current tab info
        browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
            const currentTab = tabs[0];
            console.log('Current tab:', currentTab);
            
            // Send message to background script which communicates with native app
            browser.runtime.sendMessage({
                action: "captureArticle",
                url: currentTab.url,
                title: currentTab.title
            }, function(response) {
                console.log('Response received:', response);
                captureButton.disabled = false;
                
                if (browser.runtime.lastError) {
                    console.error('Runtime error:', browser.runtime.lastError);
                    status.textContent = 'Extension communication error';
                    status.className = 'error';
                    return;
                }
                
                if (response && response.success) {
                    status.textContent = response.message || 'Article sent successfully!';
                    status.className = 'success';
                    // Close popup after success
                    setTimeout(() => {
                        window.close();
                    }, 1500);
                } else {
                    status.textContent = response?.error || response?.message || 'Failed to capture article';
                    status.className = 'error';
                }
            });
        });
    });
});
