//
//  BlockUsersPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import PromiseKit
import OpenAPIClient

class BlockUsersPage : APage, UITableViewDelegate
{
    @IBOutlet var resultsTable : CBRTableView!
    
    private let datasource = BlockUsersDatasource()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Blocked Users"
        print("📱 [BLOCKED USERS PAGE] viewDidLoad - Page initialized")
        
        resultsTable.dataSource = datasource
        resultsTable.delegate = self
        
        // Listen for data updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataUpdated),
            name: NSNotification.Name("BlockedUsersDataUpdated"),
            object: nil
        )
        
        hideKeyboardWhenTappedAround()
    }
    
    @objc private func onDataUpdated() {
        print("📱 [BLOCKED USERS PAGE] Data updated notification received, reloading table")
        print("📱 [BLOCKED USERS PAGE] Datasource has \(datasource.items.count) items")
        resultsTable.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📱 [BLOCKED USERS PAGE] viewWillAppear - Page about to appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("📱 [BLOCKED USERS PAGE] viewDidAppear - Page appeared, triggering refresh")
        refreshUI()
    }
    
    override func refreshUI()
    {
        super.refreshUI()
        
        print("🔄 [BLOCKED USERS PAGE] refreshUI called - Starting data reload")
        datasource.reload()
        resultsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let user = datasource.itemAt(indexPath) else { return }
        showUnblockConfirmation(for: user)
    }
    
    private func showUnblockConfirmation(for user: User) {
        let userName = "\(user.firstName) \(user.lastName)".trimmingCharacters(in: .whitespaces)
        let displayName = userName.isEmpty ? "this user" : userName
        
        let alert = UIAlertController(
            title: "Unblock \(displayName)?",
            message: "You will be able to see \(displayName) again and they will be able to see you.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Unblock", style: .destructive) { [weak self] _ in
            self?.unblockUser(user)
        })
        
        present(alert, animated: true)
    }
    
    private func unblockUser(_ user: User) {
        let myId = DatabaseService.singleton.getProfile().user.id
        let userToUnblockId = user.id
        guard !myId.isEmpty, !userToUnblockId.isEmpty else { return }
        
        let loadingAlert = UIAlertController(title: "Unblocking user...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        unblockUserAPI(myId: myId, userToUnblockId: userToUnblockId).done { [weak self] in
            loadingAlert.dismiss(animated: true) {
                self?.showSuccessAlert(message: "User unblocked successfully.") {
                    self?.refreshUI() // Refresh the list
                    
                    // Notify other parts of the app that a user has been unblocked
                    NotificationCenter.default.post(name: NSNotification.Name("UserUnblocked"), object: nil, userInfo: ["unblockedUserId": userToUnblockId])
                }
            }
        }.catch { [weak self] error in
            loadingAlert.dismiss(animated: true) {
                self?.showErrorAlert(message: "Failed to unblock user. Please try again.")
            }
        }
    }
    
    private func unblockUserAPI(myId: String, userToUnblockId: String) -> Promise<Void> {
        return Promise { seal in
            let url = "\(APIKeys.BASE_API_URL)/profile/\(userToUnblockId)/block"
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "DELETE"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // Add authorization header
            let token = DatabaseService.singleton.getProfile().token
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Add empty body for consistency
            request.httpBody = "".data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Unblock API Error: \(error)")
                        seal.reject(error)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Unblock API Response Code: \(httpResponse.statusCode)")
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("Unblock API Response Body: \(responseString)")
                        }
                        
                        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                            seal.fulfill(())
                        } else {
                            let errorMessage = "Failed to unblock user (HTTP \(httpResponse.statusCode))"
                            seal.reject(NSError(domain: "UnblockUserError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                        }
                    } else {
                        seal.reject(NSError(domain: "UnblockUserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"]))
                    }
                }
            }
            task.resume()
        }
    }
    
    private func showSuccessAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
