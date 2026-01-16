//
//  WordPress.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct WordPress: ExternalApplication {
        
        public typealias ActionType = Applications.WordPress.Action
        
        public let scheme = "wordpress:"
        public let fallbackURL = "https://apps.wordpress.org"
        public let appStoreId = "335703880"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.WordPress {
    
    enum Action {
        case open
    }
}

extension Applications.WordPress.Action: ExternalApplicationAction {
    
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
