//
//  FindFriends.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct FindFriends: ExternalApplication {
        
        public typealias ActionType = Applications.FindFriends.Action
        
        public let scheme = "FindMyFriends:"
        public let fallbackURL = ""
        public let appStoreId = "466122094"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.FindFriends {
    
    enum Action {
        case open
    }
}

extension Applications.FindFriends.Action: ExternalApplicationAction {
    
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
        }
    }
}
