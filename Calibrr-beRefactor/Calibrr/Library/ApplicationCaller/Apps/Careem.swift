//
//  Careem.swift
//  Appz
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Careem: ExternalApplication {
        
        public typealias ActionType = Applications.Careem.Action
        
        public let scheme = "careem:"
        public let fallbackURL = "https://www.careem.com/dubai/node"
        public let appStoreId = "592978487"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Careem {
    
    enum Action {
        case open
    }
}

extension Applications.Careem.Action: ExternalApplicationAction {
    
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
