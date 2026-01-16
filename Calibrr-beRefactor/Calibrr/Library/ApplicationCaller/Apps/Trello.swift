//
//  Trello.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Trello: ExternalApplication {
        
        public typealias ActionType = Applications.Trello.Action
        
        public let scheme = "trello:"
        public let fallbackURL = "https://trello.com/"
        public let appStoreId = "461504587"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Trello {
    
    enum Action {
        case open
    }
}

extension Applications.Trello.Action: ExternalApplicationAction {
    
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
