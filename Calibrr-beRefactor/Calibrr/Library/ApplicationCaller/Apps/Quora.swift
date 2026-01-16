//
//  Quora.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Quora: ExternalApplication {
        
        public typealias ActionType = Applications.Quora.Action
        
        public let scheme = "Quora:"
        public let fallbackURL = "https://www.quora.com/"
        public let appStoreId = "456034437"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Quora {
    
    enum Action {
        case open
    }
}

extension Applications.Quora.Action: ExternalApplicationAction {
    
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
