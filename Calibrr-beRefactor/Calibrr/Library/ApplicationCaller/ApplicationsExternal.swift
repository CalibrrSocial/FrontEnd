//
//  ApplicationsExternal.swift
//  Calibrr
//
//  Created by ZVN20210023 on 09/02/2023.
//  Copyright © 2023 Calibrr. All rights reserved.
//

import Foundation

// MARK: Tiktok
extension Applications {
    // Define your application as a type that
    // conforms to "ExternalApplication"
    struct TikTok: ExternalApplication {
        
        typealias ActionType = Applications.TikTok.Action
        
        public let scheme = "snssdk1180:"
        public let fallbackURL = "https://www.tiktok.com/"
        public let appStoreId = ""
//    snssdk1180://user/profile/6566932889707347969
    
    }
}
// Then, you define the actions your app supports
extension Applications.TikTok {
    
    enum Action: ExternalApplicationAction {
        
        case userName(String)
        
        // Each action should provide an app path and web path to be
        // added to the associated URL
        var paths: ActionPaths {
            
            switch self {
            case .userName(let userName):
                return ActionPaths(app: Path(pathComponents: ["user", "profile", userName],
                                             queryParameters: [:]),
                                   web: Path(pathComponents: ["@\(userName)"],
                                             queryParameters: [:]))
            }
        }
    }
}

// MARK: Twitter

extension Applications {
    // Define your application as a type that
    // conforms to "ExternalApplication"
    struct TwitterCustom: ExternalApplication {
        
        typealias ActionType = Applications.TwitterCustom.Action
        
        public let scheme = "twitter:"
        public let fallbackURL = "https://twitter.com/"
        public let appStoreId = "333903271"
    }
}
// Then, you define the actions your app supports
extension Applications.TwitterCustom {
    
    enum Action: ExternalApplicationAction {
        
        case userName(String)
        
        // Each action should provide an app path and web path to be
        // added to the associated URL
        var paths: ActionPaths {
            
            switch self {
            case .userName(let userName):
                return ActionPaths(
                    app: Path(
                        pathComponents: ["user"],
                        queryParameters: ["screen_name": userName]
                    ),
                    web: Path(
                        pathComponents: [userName],
                        queryParameters: [:]
                    )
                )
            }
        }
    }
}

// MARK: FacebookNew

extension Applications {
    // Define your application as a type that
    // conforms to "ExternalApplication"
    struct FacebookCustom: ExternalApplication {
        
        typealias ActionType = Applications.FacebookCustom.Action
        
        public let scheme = "fb:"
        public let fallbackURL = "https://www.facebook.com/"
        public let appStoreId = "284882215"
    }
}
// Then, you define the actions your app supports
extension Applications.FacebookCustom {
    
    enum Action: ExternalApplicationAction {
        // should user profile id to use deeplink
        case userName(String)
        
        // Each action should provide an app path and web path to be
        // added to the associated URL
        var paths: ActionPaths {
            
            switch self {
            case .userName(let userName):
                return ActionPaths(
                    app: Path(
                        pathComponents: ["profile", userName],
                        queryParameters: [:]
                    ),
                    web: Path(
                        pathComponents: [userName],
                        queryParameters: [:]
                    )
                )
            }
        }
    }
}


// MARK: VSCOCustom

extension Applications {
    // Define your application as a type that
    // conforms to "ExternalApplication"
    struct VSCOCustom: ExternalApplication {
        
        typealias ActionType = Applications.VSCOCustom.Action
        
        public let scheme = "vsco:"
        public let fallbackURL = "http://vsco.co/"
        public let appStoreId = "588013838"
    }
}

// Then, you define the actions your app supports
extension Applications.VSCOCustom {
    
    enum Action: ExternalApplicationAction {
        
        case userName(String)
        
        // Each action should provide an app path and web path to be
        // added to the associated URL
        var paths: ActionPaths {
            
            switch self {
            case .userName(let userName):
                return ActionPaths(
                    app: Path(
                        pathComponents: ["user", userName],
                        queryParameters: [:]
                    ),
                    web: Path(
                        pathComponents: [userName],
                        queryParameters: [:]
                    )
                )
            }
        }
    }
}

// MARK: SnapChat
extension Applications {
    // Define your application as a type that
    // conforms to "ExternalApplication"
    struct SnapChatCustom: ExternalApplication {
        
        typealias ActionType = Applications.SnapChatCustom.Action
        
        public let scheme = "snapchat:"
        public let fallbackURL = "https://www.snapchat.com"
        public let appStoreId = "447188370"
    }
}

// Then, you define the actions your app supports
extension Applications.SnapChatCustom {
    
    enum Action: ExternalApplicationAction {
        
        case userName(String)
        
        // Each action should provide an app path and web path to be
        // added to the associated URL
        var paths: ActionPaths {
            
            switch self {
            case .userName(let userName):
                return ActionPaths(app: Path(
                    pathComponents: ["add", userName],
                    queryParameters: [:]),
                                   web: Path(pathComponents: ["add", userName],
                                             queryParameters: [:])
                )
            }
        }
    }
}
