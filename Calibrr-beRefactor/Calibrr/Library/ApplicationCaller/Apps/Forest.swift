//
//  Forest.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Forest: ExternalApplication {
        
        public typealias ActionType = Applications.Forest.Action
        
        public let scheme = "Forest:"
        public let fallbackURL = "https://www.forestapp.cc/en/"
        public let appStoreId = "866450515"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Forest {
    
    enum Action {
        case open
    }
}

extension Applications.Forest.Action: ExternalApplicationAction {
    
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
