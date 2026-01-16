//
//  INRIXTraffic.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct INRIXTraffic: ExternalApplication {
        
        public typealias ActionType = Applications.INRIXTraffic.Action
        
        public let scheme = "inrixtraffic:"
        public let fallbackURL = "http://inrix.com/inrix-traffic-app/"
        public let appStoreId = "324384027"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.INRIXTraffic {
    
    enum Action {
        case open
    }
}

extension Applications.INRIXTraffic.Action: ExternalApplicationAction {
    
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
