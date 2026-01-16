//
//  DayCost.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct DayCost: ExternalApplication {
        
        public typealias ActionType = Applications.DayCost.Action
        
        public let scheme = "DayCost:"
        public let fallbackURL = "https://www.facebook.com/iDaycost/"
        public let appStoreId = "979953415"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.DayCost {
    
    enum Action {
        case open
    }
}

extension Applications.DayCost.Action: ExternalApplicationAction {
    
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
