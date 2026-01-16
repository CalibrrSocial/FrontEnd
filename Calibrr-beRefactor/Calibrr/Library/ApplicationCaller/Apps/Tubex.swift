//
//  Tubex.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Tubex: ExternalApplication {
        
        public typealias ActionType = Applications.Tubex.Action
        
        public let scheme = "tubex:"
        public let fallbackURL = "https://www.facebook.com/Tubex-744986562245828/"
        public let appStoreId = "939906112"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Tubex {
    
    enum Action {
        case open
    }
}

extension Applications.Tubex.Action: ExternalApplicationAction {
    
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

