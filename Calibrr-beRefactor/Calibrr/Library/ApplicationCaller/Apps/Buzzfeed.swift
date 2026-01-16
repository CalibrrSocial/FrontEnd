//
//  Buzzfeed.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Buzzfeed: ExternalApplication {
        
        public typealias ActionType = Applications.Buzzfeed.Action
        
        public let scheme = "buzzfeed:"
        public let fallbackURL = "http://www.buzzfeed.com"
        public let appStoreId = "352969997"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Buzzfeed {
    
    enum Action {
        case open
    }
}

extension Applications.Buzzfeed.Action: ExternalApplicationAction {
    
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
