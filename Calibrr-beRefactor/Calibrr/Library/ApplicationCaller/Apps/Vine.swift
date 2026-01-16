//
//  Vine.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Vine: ExternalApplication {
        
        public typealias ActionType = Applications.Vine.Action
        
        public let scheme = "vine:"
        public let fallbackURL = "https://vine.co"
        public let appStoreId = "592447445"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Vine {
    
    enum Action {
        case open
        case timelinesPopular
    }
}

extension Applications.Vine.Action: ExternalApplicationAction {
    
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
            
        case .timelinesPopular:
            return ActionPaths(
                app: Path(
                    pathComponents: ["timelines", "popular"],
                    queryParameters: [:]
                ),
                web: Path(
                    pathComponents: ["popular-now"],
                    queryParameters: [:]
                )
            )
        }
    }
}
