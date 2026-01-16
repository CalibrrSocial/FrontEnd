//
//  Currency.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Currency: ExternalApplication {
        
        public typealias ActionType = Applications.Currency.Action
        
        public let scheme = "Currency:"
        public let fallbackURL = "http://www.xe.com/apps/iphone/"
        public let appStoreId = "315241195"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Currency {
    
    enum Action {
        case open
    }
}

extension Applications.Currency.Action: ExternalApplicationAction {
    
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

