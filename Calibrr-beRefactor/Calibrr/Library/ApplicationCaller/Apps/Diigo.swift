//
//  Diigo.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Diigo: ExternalApplication {
        
        public typealias ActionType = Applications.Diigo.Action
        
        public let scheme = "diigo:"
        public let fallbackURL = "https://www.diigo.com"
        public let appStoreId = "933773981"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Diigo {
    
    enum Action {
        case open
    }
}

extension Applications.Diigo.Action: ExternalApplicationAction {
    
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
