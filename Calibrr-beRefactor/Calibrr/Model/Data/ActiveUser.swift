//
//  ActiveUser.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import PromiseKit
import MapKit
import OpenAPIClient

class ActiveUser : NSObject, CLLocationManagerDelegate
{
    static let singleton = ActiveUser()
    
    lazy var userData = UserData.singleton
    lazy var databaseService = DatabaseService.singleton
    
    var loggedIn = false
    var currentLocation : CLLocation? = nil
    private var locationManager : CLLocationManager? = nil
    
    private let failActiveUserPromise : Promise<Void> = PromiseUtils.CreateFail("No such active user")
    
    func login(_ nav: CBRNavigator, _ username: String, _ password: String, _ method: String, _ token: String, _ tokenReceivedAt: Date, _ isAdmin: Bool, _ profile: User, _ firstTime: Bool = false) -> Promise<Void>
    {
        return PromiseUtils.CreateActionVoidPromise{
            if self.userData.storeCredentials(username, password, method) {
                self.processLogin(nav, username, token, tokenReceivedAt, isAdmin, profile, firstTime)
            }else{
                throw CBRError.GeneralError(message: "Couldn't store credentials!")
            }
        }
    }
    
    func showLoginError(_ nav: CBRNavigator, _ e: Error, completionHandler: CompletionHandlerClosureType? = nil)
    {
        // Check if this is a moderation error (banned/suspended)
        if let errorResponse = e as? ErrorResponse,
           case let .error(statusCode, data, _, _) = errorResponse,
           statusCode == 403,
           let data = data,
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let moderationState = json["moderation_state"] as? String {
            
            let moderationReason = json["moderation_reason"] as? String
            let suspensionEndsAt = json["suspension_ends_at"] as? String
            
            // Show moderation screen instead of alert
            let moderationPage = ModerationBlockedPage(
                moderationState: moderationState,
                moderationReason: moderationReason,
                suspensionEndsAt: suspensionEndsAt
            )
            nav.show(moderationPage, animated: false)
            return
        }
        
        Alert.Error(error: e.createCBR(), completionHandler: completionHandler)
    }
    
    func checkModerationStatus(_ nav: CBRNavigator, completion: @escaping (Bool) -> Void) {
        // Make a simple API call to check if user is still allowed to use the app
        // We'll use the profile endpoint as it's protected by the moderation middleware
        let userId = databaseService.getProfile().user.id
        
        ProfileAPI.getUser(id: userId).done { _ in
            // If successful, user is not banned/suspended
            completion(true)
        }.catch { error in
            // Check if this is a moderation error
            if let errorResponse = error as? ErrorResponse,
               case let .error(statusCode, data, _, _) = errorResponse,
               statusCode == 403,
               let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let moderationState = json["moderation_state"] as? String {
                
                let moderationReason = json["moderation_reason"] as? String
                let suspensionEndsAt = json["suspension_ends_at"] as? String
                
                // Show moderation screen
                let moderationPage = ModerationBlockedPage(
                    moderationState: moderationState,
                    moderationReason: moderationReason,
                    suspensionEndsAt: suspensionEndsAt
                )
                nav.show(moderationPage, animated: false)
                completion(false)
            } else {
                // Other error, allow user to continue
                completion(true)
            }
        }
    }
    
    func logOut()
    {
        loggedIn = false
        //TODO: fix at some point
        OpenAPIClientAPI.customHeaders.removeValue(forKey: APIKeys.HTTP_AUTHORIZATION_HEADER)
        
        databaseService.clean()
        userData.deleteActive()
    }
    
    private func processLogin(_ nav: CBRNavigator, _ username: String, _ token: String, _ payloadReceivedAt: Date, _ isAdmin: Bool, _ profile: User, _ firstTime: Bool)
    {
        databaseService.clean()
        databaseService.setupActiveProfile(profile, token, payloadReceivedAt)
        
        prepareServices(username, token)
        
        userData.setLoggedIn()
        loggedIn = true
        
        self.startLocationServices()
        
        showHome(nav, isAdmin, firstTime)
    }
    
    private func prepareServices(_ username: String, _ token: String)
    {
        BugTracking.SetupUser(username)
        Tracking.SetupUser(username)
        
        //TODO: fix at some point
        OpenAPIClientAPI.customHeaders[APIKeys.HTTP_AUTHORIZATION_HEADER] = APIKeys.HTTP_AUTHORIZATION_PREFIX + token
        
        startLocationServices()
    }
    
    private func showHome(_ nav: CBRNavigator, _ isAdmin: Bool, _ firstTime: Bool)
    {
        if isAdmin {
            //            nav.pushAsFirst(ReportUserListPage())
        }else if firstTime {
            let vc = ProfileEditPage()
            vc.isHiddenBack = true
            nav.pushAsFirst(vc, rootPage: SearchUsersByDistancePage(), animated: true)
            return
        }
        nav.show(SearchUsersByDistancePage(), animated: false)
    }
    
    public func startLocationServices()
    {
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestWhenInUseAuthorization()
    }
    
    public func startUpdateLocation() {
        self.startLocationServices()
        self.locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
            currentLocation = manager.location
        }else if status == .denied {
            Alert.SettingsAccessDenied(title: "Access to Location Services denied", message: "You have previously denied access to the Location Services. Please enable it in the Settings.\n\nOtherwise, we won't be able find nearby users.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = locations.first
        self.locationManager?.stopUpdatingLocation()
        updateUserLocation()
    }
    
    private func updateUserLocation() {
        var user = DatabaseService.singleton.getProfile().user
        
        if let location = currentLocation {
            user.location = Position(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        
        // Use the dedicated location update endpoint instead of full profile update
        // This prevents overwriting personalInfo and socialInfo fields
        ProfileAPI.updateUserLocation(id: user.id, user: user).thenInAction{ _ in }
    }
}
