//
//  LogService.swift
//  Calibrr
//
//  Created by Leon on 31/07/2022.
//  Copyright © 2022 Calibrr. All rights reserved.
//

import Foundation


public class LogService {
    static let share = LogService()
    
    func log(request: URLRequest) {
        let urlString = request.url?.absoluteString ?? ""
        
        // Only log attribute-like related requests
        guard shouldLogRequest(urlString: urlString) else { return }
        
        let components = NSURLComponents(string: urlString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod!)": ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"
        
        var requestLog = "\n---------- REQUEST ---------->\n"
        requestLog += "\(urlString)"
        requestLog += "\n\n"
        requestLog += "\(method) \(path)?\(query) HTTP/1.1\n"
        requestLog += "Host: \(host)\n"
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\(key): \(value)\n"
        }
        if let body = request.httpBody{
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded";
            requestLog += "\n\(bodyString)\n"
        }
        
        requestLog += "\n------------------------->\n";
        print(requestLog)
    }
    
    func log(data: Data?, response: HTTPURLResponse?, error: Error?){
        let urlString = response?.url?.absoluteString ?? ""
        
        // Only log attribute-like related responses
        guard shouldLogRequest(urlString: urlString) else { return }
        
        let components = NSURLComponents(string: urlString)
        
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        
        var responseLog = "\n<---------- RESPONSE ----------\n"
        responseLog += "\(urlString)"
        responseLog += "\n\n"
        
        if let statusCode =  response?.statusCode{
            responseLog += "HTTP \(statusCode) \(path)?\(query)\n"
        }
        if let host = components?.host{
            responseLog += "Host: \(host)\n"
        }
        for (key,value) in response?.allHeaderFields ?? [:] {
            responseLog += "\(key): \(value)\n"
        }
        if let body = data{
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded";
            responseLog += "\n\(bodyString)\n"
        }
        if let error = error{
            responseLog += "\nError: \(error.localizedDescription)\n"
        }
        
        responseLog += "<------------------------\n";
        print(responseLog)
    }
    
    private func shouldLogRequest(urlString: String) -> Bool {
        // Only log requests related to attribute likes or profile viewing issues
        return urlString.contains("/attributes/") || 
               urlString.contains("/profile/") && !urlString.contains("/location")
    }
}


