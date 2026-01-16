//
//  RunKeeper.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct RunKeeper: ExternalApplication {
        
        public typealias ActionType = Applications.RunKeeper.Action
        
        public let scheme = "RunKeeper:"
        public let fallbackURL = "https://runkeeper.com/index"
        public let appStoreId = "300235330"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.RunKeeper {
    
    enum Action {
        case open
    }
}

extension Applications.RunKeeper.Action: ExternalApplicationAction {
    
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
