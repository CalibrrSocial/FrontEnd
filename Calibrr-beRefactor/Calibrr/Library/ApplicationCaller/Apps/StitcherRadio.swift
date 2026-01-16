//
//  StitcherRadio.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct StitcherRadio: ExternalApplication {
        
        public typealias ActionType = Applications.StitcherRadio.Action
        
        public let scheme = "stitcher:"
        public let fallbackURL = "http://www.stitcher.com"
        public let appStoreId = "288087905"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.StitcherRadio {
    
    enum Action {
        case open
    }
}

extension Applications.StitcherRadio.Action: ExternalApplicationAction {
    
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
