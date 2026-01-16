//
//  ErrorExtensions.swift
//  Calibrr
//
//

import Foundation
import OpenAPIClient

extension Error
{
    func createCBR() -> CBRError
    {
        let error : Error = self
        
        if error is CBRError {
            return error as! CBRError
        }
        switch error {
        case ErrorResponse.error(let code, let data, let request, let e):
            var json = [String : Any]()
            if let data = data {
                do{
                    let jsonObject = try JSONSerialization.jsonObject(with: data)
                    if let jsonData = jsonObject as? [String : Any] {
                        json = jsonData
                    }else{
                        json["data"] = jsonObject
                    }
                }catch{
                    json["messageString"] = String(data: data, encoding: .utf8)
                }
            }
            return CBRError.NetworkError(code: code, json: json, error: e, request: request?.url?.absoluteString ?? "", parameters: nil)
        case is URLError:
            let e = error as! URLError
            return CBRError.NetworkError(code: e.errorCode, json: e.errorUserInfo, error: e, request: e.failureURLString ?? "unknown", parameters: nil)
        default:
            return CBRError.GeneralError(message: "\(error)")
        }
    }
}
