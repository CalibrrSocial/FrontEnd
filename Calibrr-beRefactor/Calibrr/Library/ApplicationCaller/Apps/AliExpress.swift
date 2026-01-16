//
//  AliExpress.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct AliExpress: ExternalApplication {
        
        public typealias ActionType = Applications.AliExpress.Action
        
        public let scheme = "aliexpress:"
        public let fallbackURL = "http://www.aliexpress.com"
        public let appStoreId = "436672029"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.AliExpress {
    
    enum Action {
        case open
    }
}

extension Applications.AliExpress.Action: ExternalApplicationAction {
    
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
