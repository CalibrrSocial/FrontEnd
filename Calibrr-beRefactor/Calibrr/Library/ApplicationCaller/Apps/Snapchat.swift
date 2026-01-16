//
//  Snapchat.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Snapchat: ExternalApplication {
        
        public typealias ActionType = Applications.Snapchat.Action
        
        public let scheme = "snapchat:"
        public let fallbackURL = "https://www.snapchat.com"
        public let appStoreId = "447188370"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Snapchat {
    
    enum Action {
        case open
        case add(username: String)
    }
}

extension Applications.Snapchat.Action: ExternalApplicationAction {
    
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
        case .add(let Username):
            return ActionPaths(
                app: Path(
                    pathComponents: ["add", Username],
                    queryParameters: [:]
                ),
                web: Path()
            )
        }
    }
}
