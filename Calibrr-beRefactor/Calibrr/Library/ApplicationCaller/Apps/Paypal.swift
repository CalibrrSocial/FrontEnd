//
//  Paypal.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Paypal: ExternalApplication {
        
        public typealias ActionType = Applications.Paypal.Action
        
        public let scheme = "paypal:"
        public let fallbackURL = "https://paypal.com/"
        public let appStoreId = "283646709"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Paypal {
    
    enum Action {
        case open
    }
}

extension Applications.Paypal.Action: ExternalApplicationAction {
    
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
