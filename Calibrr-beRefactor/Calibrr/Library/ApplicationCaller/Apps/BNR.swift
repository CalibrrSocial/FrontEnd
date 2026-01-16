//
//  BNR.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct BNR: ExternalApplication {
        
        public typealias ActionType = Applications.BNR.Action
        
        public let scheme = "bnr:"
        public let fallbackURL = "http://www.bnr.nl"
        public let appStoreId = "433128088"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.BNR {
    
    enum Action {
        case open
    }
}

extension Applications.BNR.Action: ExternalApplicationAction {
    
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
