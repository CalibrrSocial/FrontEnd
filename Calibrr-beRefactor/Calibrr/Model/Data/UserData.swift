//
//  UserData.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class UserData
{
    static let singleton = UserData()
    
    private struct Keys
    {
        //user specific
        static let USERNAME = "username"
        static let PASSWORD = "password"
        static let METHOD = "method"
        static let WAS_LOGGED_IN = "wasLoggedIn"
        
        //device specific
        static let ASKED_FOR_PERMISSIONS = "askedForPermission"
    }
    
    static func getDeviceID() -> String
    {
        return UIDevice.current.identifierForVendor?.uuidString ?? "unidentified"
    }
    
    func deleteActive()
    {
        deleteCredentials()
        
        deleteObject(Keys.WAS_LOGGED_IN)
    }
    
    func storeCredentials(_ username: String, _ password: String, _ method: String) -> Bool
    {
        return KeychainWrapper.standard.set(username, forKey: Keys.USERNAME)
            && KeychainWrapper.standard.set(password, forKey: Keys.PASSWORD)
            && KeychainWrapper.standard.set(method, forKey: Keys.METHOD)
    }
    
    func getCredentials() -> (String, String, String)?
    {
        if let username = KeychainWrapper.standard.string(forKey: Keys.USERNAME), let password = KeychainWrapper.standard.string(forKey: Keys.PASSWORD), let method = KeychainWrapper.standard.string(forKey: Keys.METHOD) {
            return (username, password, method)
        }
        return nil
    }
    
    func hasCredentials() -> Bool
    {
        return getCredentials() != nil
    }
    
    func deleteCredentials()
    {
        let _ = KeychainWrapper.standard.removeAllKeys()
    }
    
    func wasLoggedIn() -> Bool
    {
        return getObject(Keys.WAS_LOGGED_IN) as? Bool == true
    }
    
    func setLoggedIn()
    {
        setObject(true, forKey: Keys.WAS_LOGGED_IN)
    }
    
    func isAskedForPermissionsOn() -> Bool
    {
        return getObject(Keys.ASKED_FOR_PERMISSIONS) as? Bool ?? false
    }
    
    func setAskedForPermissionsOn(_ value: Bool)
    {
        setObject(value, forKey: Keys.ASKED_FOR_PERMISSIONS)
    }
    
    private func getObject(_ key: String) -> Any?
    {
        return getUserDefaults().object(forKey: key)
    }
    
    private func setObject(_ object: Any, forKey: String)
    {
        getUserDefaults().set(object, forKey: forKey)
        getUserDefaults().synchronize()
    }
    
    private func deleteObject(_ key: String)
    {
        getUserDefaults().removeObject(forKey: key)
        getUserDefaults().synchronize()
    }
    
    internal func getUserDefaults() -> UserDefaults
    {
        return UserDefaults.standard
    }
}
