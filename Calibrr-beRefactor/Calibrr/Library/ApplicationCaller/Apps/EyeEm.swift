//
//  EyeEm.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct EyeEm: ExternalApplication {
        
        public typealias ActionType = Applications.EyeEm.Action
        
        public let scheme = "eyeem:"
        public let fallbackURL = "https://www.eyeem.com/community"
        public let appStoreId = "445638931"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.EyeEm {
    
    enum Action {
        case open
    }
}

extension Applications.EyeEm.Action: ExternalApplicationAction {
    
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
