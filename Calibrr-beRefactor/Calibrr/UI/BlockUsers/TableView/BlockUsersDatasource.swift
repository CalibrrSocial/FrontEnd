//
//  BlockUsersDatasource.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation
import OpenAPIClient
import PromiseKit

class BlockUsersDatasource : AStandardItemsDatasource<SearchUserCell, User>
{
    override var noContentMessage: String { get { return "You haven't blocked anyone yet." }
        set {
            self.noContentMessage = newValue
        }
    }
    
    override func reload()
    {
        let myId = DatabaseService.singleton.getProfile().user.id
        print("🔵 [BLOCKED USERS] Starting reload for user ID: \(myId)")
        
        guard !myId.isEmpty else {
            print("❌ [BLOCKED USERS] User ID is empty, aborting")
            self.items = []
            return
        }
        
        // Call the blocked users API
        getBlockedUsersAPI(myId: myId).done { [weak self] blockedUsers in
            DispatchQueue.main.async {
                print("✅ [BLOCKED USERS] API call successful, received \(blockedUsers.count) blocked users")
                
                if blockedUsers.isEmpty {
                    print("ℹ️ [BLOCKED USERS] No blocked users found")
                } else {
                    for (index, blockedUser) in blockedUsers.enumerated() {
                        print("👤 [BLOCKED USERS] [\(index)] ID: \(blockedUser.id), Name: \(blockedUser.firstName) \(blockedUser.lastName)")
                    }
                }
                
                // Convert BlockedUser objects to User objects for display
                let users = blockedUsers.map { blockedUser in
                    return User(
                        id: String(blockedUser.id),
                        email: nil,
                        phone: nil,
                        firstName: blockedUser.firstName,
                        lastName: blockedUser.lastName,
                        ghostMode: nil,
                        subscription: nil,
                        location: nil,
                        locationTimestamp: nil,
                        pictureProfile: blockedUser.avatarUrl,
                        pictureCover: nil,
                        personalInfo: UserPersonalInfo(
                            dob: nil,
                            gender: nil,
                            bio: nil,
                            education: nil,
                            politics: nil,
                            religion: nil,
                            occupation: nil,
                            sexuality: nil,
                            relationship: nil,
                            city: nil,
                            greekLife: nil,
                            favoriteTV: nil,
                            favoriteGame: nil,
                            studying: nil,
                            favoriteMusic: nil,
                            club: nil,
                            classYear: nil,
                            campus: nil,
                            careerAspirations: nil,
                            postgraduate: nil,
                            postgraduatePlans: nil,
                            hometown: nil,
                            highSchool: nil
                        ),
                        socialInfo: UserSocialInfo(
                            facebook: nil,
                            instagram: nil,
                            snapchat: nil,
                            tiktok: nil,
                            twitter: nil,
                            linkedIn: nil,
                            vsco: nil
                        )
                    )
                }
                
                print("🔄 [BLOCKED USERS] Converted to \(users.count) User objects, updating UI")
                self?.items = users
                
                // Notify that data has been updated
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("BlockedUsersDataUpdated"), object: nil)
                }
            }
        }.catch { [weak self] error in
            DispatchQueue.main.async {
                print("❌ [BLOCKED USERS] API call failed: \(error)")
                self?.items = []
            }
        }
    }
    
    private func getBlockedUsersAPI(myId: String) -> Promise<[BlockedUser]> {
        return Promise { seal in
            let url = "\(APIKeys.BASE_API_URL)/profile/\(myId)/blocked"
            print("🌐 [BLOCKED USERS API] Making request to: \(url)")
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
            
            // Add authorization header
            let token = DatabaseService.singleton.getProfile().token
            let tokenPrefix = String(token.prefix(20))
            print("🔑 [BLOCKED USERS API] Using token: \(tokenPrefix)...")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ [BLOCKED USERS API] Network error: \(error)")
                        seal.reject(error)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("📡 [BLOCKED USERS API] Response code: \(httpResponse.statusCode)")
                        
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("📄 [BLOCKED USERS API] Response body: \(responseString)")
                        }
                        
                        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                            if let data = data {
                                do {
                                    let response = try JSONDecoder().decode(BlockedUsersResponse.self, from: data)
                                    print("✅ [BLOCKED USERS API] Successfully decoded response")
                                    print("📊 [BLOCKED USERS API] Message: \(response.message)")
                                    print("📊 [BLOCKED USERS API] Data count: \(response.data?.count ?? 0)")
                                    seal.fulfill(response.data ?? [])
                                } catch {
                                    print("❌ [BLOCKED USERS API] JSON decode error: \(error)")
                                    if let responseString = String(data: data, encoding: .utf8) {
                                        print("❌ [BLOCKED USERS API] Raw response: \(responseString)")
                                    }
                                    seal.reject(error)
                                }
                            } else {
                                print("⚠️ [BLOCKED USERS API] No data in response, returning empty array")
                                seal.fulfill([])
                            }
                        } else {
                            print("❌ [BLOCKED USERS API] HTTP error \(httpResponse.statusCode)")
                            let errorMessage = "Failed to fetch blocked users (HTTP \(httpResponse.statusCode))"
                            seal.reject(NSError(domain: "BlockedUsersError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                        }
                    } else {
                        print("❌ [BLOCKED USERS API] No HTTP response received")
                        seal.reject(NSError(domain: "BlockedUsersError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"]))
                    }
                }
            }
            task.resume()
        }
    }
}

// Define the response structures
struct BlockedUsersResponse: Codable {
    let message: String
    let data: [BlockedUser]?
}

struct BlockedUser: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let avatarUrl: String?
    let blockedAt: String
    let reason: String?
}
