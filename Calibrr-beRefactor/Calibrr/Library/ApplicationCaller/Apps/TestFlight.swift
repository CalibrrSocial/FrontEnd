//
//  TestFlight.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct TestFlight: ExternalApplication {
        
        public typealias ActionType = Applications.TestFlight.Action
        
        public let scheme = "itms-beta:"
        public let fallbackURL = ""
        public let appStoreId = "899247664"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.TestFlight {
    
    enum Action {
        case open
    }
}

extension Applications.TestFlight.Action: ExternalApplicationAction {
    
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
