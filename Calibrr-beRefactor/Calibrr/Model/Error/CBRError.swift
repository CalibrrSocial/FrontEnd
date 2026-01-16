//
//  CBRError.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 03/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
//

import UIKit

enum CBRError : LocalizedError, CustomStringConvertible, Equatable
{
    case GeneralError(message: String)
    case NetworkError(code: Int, json: [String : Any], error: Error, request: String, parameters: [String:Any]?)
    
    func logAndPresent(_ from: UIViewController? = nil)
    {
        log()
        present(from)
    }
    
    func log()
    {
        if shouldLog() {
            BugTracking.Track(self)
        }
    }
    
    func present(_ from: UIViewController? = nil)
    {
        if shouldPresent() {
            Alert.Error(error: self, from: from, completionHandler: nil)
        }
    }
    
    func shouldLog() -> Bool
    {
        switch self {
            
        case .NetworkError(let code, _, let error, _, _):
            switch code {
            case 500:
                switch error {
                case URLError.notConnectedToInternet,
                     URLError.networkConnectionLost,
                     URLError.cannotFindHost,
                     URLError.cannotConnectToHost:
                    return false
                default:
                    return true
                }
            default:
                return true
            }
        default:
            return true
        }
    }
    
    func shouldPresent() -> Bool
    {
        return true
    }
    
    var description: String
    {
        return errorDescription!
    }
    
    var title: String? {
        switch self {
        case .NetworkError(let code, let json, let error, _, _):
            switch code {
            case 500:
                switch error {
                case URLError.timedOut:
                    return "Request timed out."
                case URLError.notConnectedToInternet,
                     URLError.networkConnectionLost:
                    return "Error"
                case URLError.cannotFindHost,
                     URLError.cannotConnectToHost:
                    return "Error"
                default:
                    if let title = json["message"] as? String {
                        return title
                    }
                    return "Error"
                }
            default:
                if let message = json["message"] as? String {
                    return message
                }
                return "Error"
            }
        default:
            return "Error"
        }
    }
    
    var errorDescription: String?
    {
        switch self {
        case .GeneralError(let message):
            return message
        case .NetworkError(let code, let json, let error, _, _):
            switch code {
            case 500:
                switch error {
                case URLError.timedOut:
                    return "There was a problem connecting with our servers.\n\nPlease try again."
                case URLError.notConnectedToInternet,
                     URLError.networkConnectionLost:
                    return "No internet connection.\n\nPlease try again after connecting."
                case URLError.cannotFindHost,
                     URLError.cannotConnectToHost:
                    return "There was a problem connecting with our servers.\n\nPlease try again later."
                default:
                    if let message = json["details"] as? String {
                        return message
                    }
                    return "Internal server error"
                }
            default:
                if let message = json["details"] as? String {
                    return message
                }
                return "Please try again."
            }
        }
    }
}

func ==(lhs: CBRError, rhs: CBRError) -> Bool {
    switch (lhs, rhs) {
    case (let .GeneralError(message1), let .GeneralError(message2)):
        return message1 == message2
    case (let .NetworkError(code1, json1, error1, request1, parameters1), let .NetworkError(code2, json2, error2, request2, parameters2)):
        return code1 == code2 && json1 == json2 && error1.localizedDescription == error2.localizedDescription && request1 == request2 && "\(parameters1 ?? [:])" == "\(parameters2 ?? [:])"
    default:
        return false
    }
}
