//
//  Keeper.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Keeper: ExternalApplication {
        
        public typealias ActionType = Applications.Keeper.Action
        
        public let scheme = "keeper:"
        public let fallbackURL = "https://keepersecurity.com/"
        public let appStoreId = "287170072"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Keeper {
    
    enum Action {
        case open
    }
}

extension Applications.Keeper.Action: ExternalApplicationAction {
    
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
