//
//  Remote.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Remote: ExternalApplication {
        
        public typealias ActionType = Applications.Remote.Action
        
        public let scheme = "remote:"
        public let fallbackURL = ""
        public let appStoreId = "284417350"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Remote {
    
    enum Action {
        case open
    }
}

extension Applications.Remote.Action: ExternalApplicationAction {
    
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
