//
//  Sonos.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Sonos: ExternalApplication {
        
        public typealias ActionType = Applications.Sonos.Action
        
        public let scheme = "sonos:"
        public let fallbackURL = "http://www.sonos.com/"
        public let appStoreId = "293523031"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Sonos {
    
    enum Action {
        case open
    }
}

extension Applications.Sonos.Action: ExternalApplicationAction {
    
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
