//
//  FlippsTV.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct FlippsTV: ExternalApplication {
        
        public typealias ActionType = Applications.FlippsTV.Action
        
        public let scheme = "flippshd:"
        public let fallbackURL = "http://www.flipps.com"
        public let appStoreId = "348147113"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.FlippsTV {
    
    enum Action {
        case open
    }
}

extension Applications.FlippsTV.Action: ExternalApplicationAction {
    
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
