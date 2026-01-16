//
//  GroupeMe.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct GroupeMe: ExternalApplication {
        
        public typealias ActionType = Applications.GroupeMe.Action
        
        public let scheme = "groupme:"
        public let fallbackURL = "https://groupme.com"
        public let appStoreId = "392796698"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.GroupeMe {
    
    enum Action {
        case open
    }
}

extension Applications.GroupeMe.Action: ExternalApplicationAction {
    
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
