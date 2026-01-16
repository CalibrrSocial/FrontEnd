//
//  Telegram.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Telegram: ExternalApplication {
        
        public typealias ActionType = Applications.Telegram.Action
        
        public let scheme = "tg:"
        public let fallbackURL = "https://t.me/"
        public let appStoreId = "686449807"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Telegram {
    
    enum Action {
        case open
        case msg(message: String, phone: String)
        case openFromID(username: String)
    }
}

extension Applications.Telegram.Action: ExternalApplicationAction {
    
    public var paths: ActionPaths {
        
        switch self {
        case .open:
            return ActionPaths(
                app: Path(
                    pathComponents: ["app"],
                    queryParameters: [:]
                ),
                web: Path()
            )
            
        case .msg(let message, let phone):
            return ActionPaths(
                app: Path(
                    pathComponents: ["msg"],
                    queryParameters: [
                        "text": message,
                        "to": phone,
                    ]
                ),
                web: Path()
            )
        case .openFromID(let username):
            return ActionPaths(
                app: Path(
                    pathComponents: ["resolve"],
                    queryParameters: ["domain":username]
                ),
                web: Path(
                    pathComponents: [username],
                    queryParameters: [:]
                )
            )
        }
    }
}
