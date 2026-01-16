//
//  ProfileAPI+BlockReport.swift
//  Calibrr
//
//  Created by Assistant on 23/08/2025.
//  Copyright © 2025 Calibrr. All rights reserved.
//

import Foundation
import PromiseKit
import OpenAPIClient

extension ProfileAPI {
    
    /**
     Block a user
     
     - parameter id: (path) Current user's ID
     - parameter userToBlockId: (path) ID of user to block
     - parameter reason: (body) Optional reason for blocking
     - returns: Promise<Void>
     */
    open class func blockUser(id: String, userToBlockId: String, reason: String?) -> Promise<Void> {
        let deferred = Promise<Void>.pending()
        blockUserWithRequestBuilder(id: id, userToBlockId: userToBlockId, reason: reason).execute { result in
            switch result {
            case .success(_):
                deferred.resolver.fulfill(())
            case let .failure(error):
                deferred.resolver.reject(error)
            }
        }
        return deferred.promise
    }
    
    /**
     Block a user
     - POST /profile/{userToBlockId}/block
     - API Key:
       - type: apiKey Authorization
       - name: CalibrrAuthorizer
     - parameter id: (path) Current user's ID
     - parameter userToBlockId: (path) ID of user to block
     - parameter reason: (body) Optional reason for blocking
     - returns: RequestBuilder<Void>
     */
    open class func blockUserWithRequestBuilder(id: String, userToBlockId: String, reason: String?) -> RequestBuilder<Void> {
        var localVariablePath = "/profile/\(userToBlockId)/block"
        let localVariableURLString = OpenAPIClientAPI.basePath + localVariablePath
        
        var localVariableParameters: [String: Any] = [:]
        if let reason = reason {
            localVariableParameters["reason"] = reason
        }
        
        let localVariableUrlComponents = URLComponents(string: localVariableURLString)
        
        let localVariableNillableHeaders: [String: Any?] = [
            "Content-Type": "application/json",
        ]
        
        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)
        
        let localVariableRequestBuilder: RequestBuilder<Void>.Type = OpenAPIClientAPI.requestBuilderFactory.getNonDecodableBuilder()
        
        return localVariableRequestBuilder.init(method: "POST", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: true)
    }
    
    /**
     Report and block a user
     
     - parameter id: (path) Current user's ID
     - parameter reportedUserId: (path) ID of user to report
     - parameter reason: (body) Reason for reporting
     - returns: Promise<Void>
     */
    open class func reportAndBlockUser(id: String, reportedUserId: String, reason: String) -> Promise<Void> {
        let deferred = Promise<Void>.pending()
        reportAndBlockUserWithRequestBuilder(id: id, reportedUserId: reportedUserId, reason: reason).execute { result in
            switch result {
            case .success(_):
                deferred.resolver.fulfill(())
            case let .failure(error):
                deferred.resolver.reject(error)
            }
        }
        return deferred.promise
    }
    
    /**
     Report and block a user
     - POST /profile/{reportedUserId}/report
     - API Key:
       - type: apiKey Authorization
       - name: CalibrrAuthorizer
     - parameter id: (path) Current user's ID
     - parameter reportedUserId: (path) ID of user to report
     - parameter reason: (body) Reason for reporting
     - returns: RequestBuilder<Void>
     */
    open class func reportAndBlockUserWithRequestBuilder(id: String, reportedUserId: String, reason: String) -> RequestBuilder<Void> {
        var localVariablePath = "/profile/\(reportedUserId)/report"
        let localVariableURLString = OpenAPIClientAPI.basePath + localVariablePath
        
        let localVariableParameters: [String: Any] = [
            "reason_category": reason
        ]
        
        let localVariableUrlComponents = URLComponents(string: localVariableURLString)
        
        let localVariableNillableHeaders: [String: Any?] = [
            "Content-Type": "application/json",
        ]
        
        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)
        
        let localVariableRequestBuilder: RequestBuilder<Void>.Type = OpenAPIClientAPI.requestBuilderFactory.getNonDecodableBuilder()
        
        return localVariableRequestBuilder.init(method: "POST", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: true)
    }
    
    /**
     Get blocked users list
     
     - parameter id: (path) Current user's ID
     - returns: Promise<[BlockedUser]>
     */
    open class func getBlockedUsers(id: String) -> Promise<[BlockedUser]> {
        let deferred = Promise<[BlockedUser]>.pending()
        getBlockedUsersWithRequestBuilder(id: id).execute { result in
            switch result {
            case let .success(response):
                deferred.resolver.fulfill(response.body)
            case let .failure(error):
                deferred.resolver.reject(error)
            }
        }
        return deferred.promise
    }
    
    /**
     Get blocked users list
     - GET /profile/{id}/blocked
     - API Key:
       - type: apiKey Authorization
       - name: CalibrrAuthorizer
     - parameter id: (path) Current user's ID
     - returns: RequestBuilder<[BlockedUser]>
     */
    open class func getBlockedUsersWithRequestBuilder(id: String) -> RequestBuilder<[BlockedUser]> {
        var localVariablePath = "/profile/\(id)/blocked"
        let localVariableURLString = OpenAPIClientAPI.basePath + localVariablePath
        let localVariableParameters: [String: Any]? = nil
        
        let localVariableUrlComponents = URLComponents(string: localVariableURLString)
        
        let localVariableNillableHeaders: [String: Any?] = [:]
        
        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)
        
        let localVariableRequestBuilder: RequestBuilder<[BlockedUser]>.Type = OpenAPIClientAPI.requestBuilderFactory.getBuilder()
        
        return localVariableRequestBuilder.init(method: "GET", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: true)
    }
    
    /**
     Unblock a user
     
     - parameter id: (path) Current user's ID
     - parameter userToUnblockId: (path) ID of user to unblock
     - returns: Promise<Void>
     */
    open class func unblockUser(id: String, userToUnblockId: String) -> Promise<Void> {
        let deferred = Promise<Void>.pending()
        unblockUserWithRequestBuilder(id: id, userToUnblockId: userToUnblockId).execute { result in
            switch result {
            case .success(_):
                deferred.resolver.fulfill(())
            case let .failure(error):
                deferred.resolver.reject(error)
            }
        }
        return deferred.promise
    }
    
    /**
     Unblock a user
     - DELETE /profile/{userToUnblockId}/block
     - API Key:
       - type: apiKey Authorization
       - name: CalibrrAuthorizer
     - parameter id: (path) Current user's ID
     - parameter userToUnblockId: (path) ID of user to unblock
     - returns: RequestBuilder<Void>
     */
    open class func unblockUserWithRequestBuilder(id: String, userToUnblockId: String) -> RequestBuilder<Void> {
        var localVariablePath = "/profile/\(userToUnblockId)/block"
        let localVariableURLString = OpenAPIClientAPI.basePath + localVariablePath
        let localVariableParameters: [String: Any]? = nil
        
        let localVariableUrlComponents = URLComponents(string: localVariableURLString)
        
        let localVariableNillableHeaders: [String: Any?] = [:]
        
        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)
        
        let localVariableRequestBuilder: RequestBuilder<Void>.Type = OpenAPIClientAPI.requestBuilderFactory.getNonDecodableBuilder()
        
        return localVariableRequestBuilder.init(method: "DELETE", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: true)
    }
    
    /**
     Report broken social media links for a user
     
     - parameter reporterId: (path) ID of the user reporting the broken links
     - parameter reportedUserId: (path) ID of the user whose links are broken
     - parameter platforms: (body) Array of platform names with broken links
     - parameter reporterName: (body) Name of the reporter
     - returns: Promise<Void>
     */
    open class func reportBrokenLinks(reporterId: String, reportedUserId: String, platforms: [String], reporterName: String) -> Promise<Void> {
        let deferred = Promise<Void>.pending()
        reportBrokenLinksWithRequestBuilder(reporterId: reporterId, reportedUserId: reportedUserId, platforms: platforms, reporterName: reporterName).execute { result in
            switch result {
            case .success(_):
                deferred.resolver.fulfill(())
            case let .failure(error):
                deferred.resolver.reject(error)
            }
        }
        return deferred.promise
    }
    
    /**
     Report broken social media links for a user
     - POST /profile/{reportedUserId}/report-broken-links
     - API Key:
       - type: apiKey Authorization
       - name: CalibrrAuthorizer
     - parameter reporterId: (path) ID of the user reporting the broken links
     - parameter reportedUserId: (path) ID of the user whose links are broken
     - parameter platforms: (body) Array of platform names with broken links
     - parameter reporterName: (body) Name of the reporter
     - returns: RequestBuilder<Void>
     */
    open class func reportBrokenLinksWithRequestBuilder(reporterId: String, reportedUserId: String, platforms: [String], reporterName: String) -> RequestBuilder<Void> {
        var localVariablePath = "/profile/\(reportedUserId)/report-broken-links"
        let localVariableURLString = OpenAPIClientAPI.basePath + localVariablePath
        
        let localVariableParameters: [String: Any] = [
            "reporter_id": reporterId,
            "platforms": platforms,
            "reporter_name": reporterName
        ]
        
        let localVariableUrlComponents = URLComponents(string: localVariableURLString)
        
        let localVariableNillableHeaders: [String: Any?] = [
            "Content-Type": "application/json",
        ]
        
        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)
        
        let localVariableRequestBuilder: RequestBuilder<Void>.Type = OpenAPIClientAPI.requestBuilderFactory.getNonDecodableBuilder()
        
        return localVariableRequestBuilder.init(method: "POST", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: true)
    }
}

// MARK: - BlockedUser Model

public struct BlockedUser: Codable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let avatarUrl: String?
    public let blockedAt: String
    public let reason: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case avatarUrl
        case blockedAt
        case reason
    }
}
