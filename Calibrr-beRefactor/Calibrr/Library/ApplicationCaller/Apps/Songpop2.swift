//
//  Songpop2.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Songpop2: ExternalApplication {
        
        public typealias ActionType = Applications.Songpop2.Action
        
        public let scheme = "songpop:"
        public let fallbackURL = "https://www.songpop2.com"
        public let appStoreId = "975364678"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Songpop2 {
    
    enum Action {
        case open
    }
}

extension Applications.Songpop2.Action: ExternalApplicationAction {
    
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
