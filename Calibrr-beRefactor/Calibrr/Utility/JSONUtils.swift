//
//  JSONUtils.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

class JSONUtils
{
    static func ConvertToArray(data: Data) -> [Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        } catch {
        }
        //TODO: find out a way to get JSONSerialization.jsonObject to throw an Error (not ObjC Exception)
        return nil
    }
    static func ConvertToArray(json: String) -> [Any]? {
        if let data = json.data(using: .utf8) {
            return ConvertToArray(data: data)
        }
        return nil
    }
    static func ConvertToDictionary(data: Data) -> [String : Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
        }
        //TODO: find out a way to get JSONSerialization.jsonObject to throw an Error (not ObjC Exception)
        return nil
    }
    static func ConvertToDictionary(json: String) -> [String : Any]? {
        if let data = json.data(using: .utf8) {
            return ConvertToDictionary(data: data)
        }
        return nil
    }
    static func ConvertToData(json: [String : Any]) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json)
        } catch {
        }
        //TODO: find out a way to get JSONSerialization.jsonObject to throw an Error (not ObjC Exception)
        return nil
    }
    static func ConvertToJSONString(data: Data) -> String? {
        return String(data: data, encoding: String.Encoding.utf8)
    }
    static func ConvertToJSONString(json: [String : Any]) -> String? {
        if let data = ConvertToData(json: json) {
            return ConvertToJSONString(data: data)
        }
        return nil
    }
}
extension Dictionary where Key == String
{
    func toData() -> Data?
    {
        return JSONUtils.ConvertToData(json: self)
    }
    func toString() -> String?
    {
        return JSONUtils.ConvertToJSONString(json: self)
    }
}
extension String
{
    func toDictionary() -> [String : Any]? {
        return JSONUtils.ConvertToDictionary(json: self)
    }
    func toArray() -> [Any]? {
        return JSONUtils.ConvertToArray(json: self)
    }
}
extension Data
{
    func toDictionary() -> [String : Any]? {
        return JSONUtils.ConvertToDictionary(data: self)
    }
    func toArray() -> [Any]? {
        return JSONUtils.ConvertToArray(data: self)
    }
    func toJSONString() -> String? {
        return JSONUtils.ConvertToJSONString(data: self)
    }
}
