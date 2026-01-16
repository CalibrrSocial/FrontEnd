//
//  Flip­board.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Flip­board: ExternalApplication {
        
        public typealias ActionType = Applications.Flip­board.Action
        
        public let scheme = "Flipboard:"
        public let fallbackURL = "https://flipboard.com"
        public let appStoreId = "358801284"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Flip­board {
    
    enum Action {
        case open
    }
}

extension Applications.Flip­board.Action: ExternalApplicationAction {
    
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
