//
//  APIRequestManager.swift
//  Calibrr
//
//  Created by AI Assistant on 2025-09-18.
//

import Foundation

class APIRequestManager {
    static let shared = APIRequestManager()
    
    private init() {}
    
    // Request queue to prevent overwhelming the server
    private let requestQueue = DispatchQueue(label: "com.calibrr.api.request.queue", attributes: .concurrent)
    private let requestSemaphore = DispatchSemaphore(value: 10) // Allow max 10 concurrent requests
    
    // Track in-flight requests to prevent duplicates
    private var inFlightRequests = Set<String>()
    private let inFlightLock = NSLock()
    
    // Rate limit tracking
    private var rateLimitReset: Date?
    private var remainingRequests: Int = 60
    private let rateLimitLock = NSLock()
    
    // Minimum delay between requests (milliseconds)
    private let minRequestDelay: TimeInterval = 0.1 // 100ms between requests
    private var lastRequestTime: Date = Date.distantPast
    
    func performRequest(
        url: URL,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil,
        requestKey: String? = nil,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        // Check if we're rate limited
        rateLimitLock.lock()
        if let resetTime = rateLimitReset, Date() < resetTime {
            let waitTime = resetTime.timeIntervalSince(Date())
            rateLimitLock.unlock()
            
            let error = NSError(
                domain: "APIRequestManager",
                code: 429,
                userInfo: [NSLocalizedDescriptionKey: "Rate limited. Please wait \(Int(waitTime)) seconds."]
            )
            completion(nil, nil, error)
            return
        }
        rateLimitLock.unlock()
        
        // Check for duplicate in-flight requests
        let key = requestKey ?? url.absoluteString
        inFlightLock.lock()
        if inFlightRequests.contains(key) {
            inFlightLock.unlock()
            print("🚫 APIRequestManager: Skipping duplicate request for: \(key)")
            // Return cached response or silently succeed for duplicate requests
            completion(nil, nil, nil)
            return
        }
        inFlightRequests.insert(key)
        inFlightLock.unlock()
        
        // Queue the request
        requestQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Wait for semaphore (rate limiting)
            self.requestSemaphore.wait()
            
            // Ensure minimum delay between requests
            let timeSinceLastRequest = Date().timeIntervalSince(self.lastRequestTime)
            if timeSinceLastRequest < self.minRequestDelay {
                Thread.sleep(forTimeInterval: self.minRequestDelay - timeSinceLastRequest)
            }
            self.lastRequestTime = Date()
            
            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.httpBody = body
            
            // Add headers
            headers?.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            // Perform the request
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                // Release semaphore
                self.requestSemaphore.signal()
                
                // Remove from in-flight requests
                self.inFlightLock.lock()
                self.inFlightRequests.remove(key)
                self.inFlightLock.unlock()
                
                // Check for rate limit response
                if let httpResponse = response as? HTTPURLResponse {
                    self.handleRateLimitHeaders(httpResponse)
                    
                    if httpResponse.statusCode == 429 {
                        // Rate limited - parse retry-after header
                        if let retryAfterString = httpResponse.value(forHTTPHeaderField: "retry-after"),
                           let retryAfter = Int(retryAfterString) {
                            self.rateLimitLock.lock()
                            self.rateLimitReset = Date().addingTimeInterval(TimeInterval(retryAfter))
                            self.rateLimitLock.unlock()
                        }
                    }
                }
                
                // Call completion on main thread
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            }
            
            task.resume()
        }
    }
    
    private func handleRateLimitHeaders(_ response: HTTPURLResponse) {
        rateLimitLock.lock()
        defer { rateLimitLock.unlock() }
        
        // Parse rate limit headers
        if let remainingString = response.value(forHTTPHeaderField: "x-ratelimit-remaining"),
           let remaining = Int(remainingString) {
            remainingRequests = remaining
        }
        
        if let resetString = response.value(forHTTPHeaderField: "x-ratelimit-reset"),
           let resetTimestamp = Double(resetString) {
            rateLimitReset = Date(timeIntervalSince1970: resetTimestamp)
        }
        
        // If we're getting low on requests, add delays
        if remainingRequests < 10 && remainingRequests > 0 {
            // Increase delay when running low on requests
            let delayMultiplier = Double(10 - remainingRequests) * 0.2
            Thread.sleep(forTimeInterval: delayMultiplier)
        }
    }
    
    func clearCache() {
        inFlightLock.lock()
        inFlightRequests.removeAll()
        inFlightLock.unlock()
        
        rateLimitLock.lock()
        rateLimitReset = nil
        remainingRequests = 60
        rateLimitLock.unlock()
    }
}
