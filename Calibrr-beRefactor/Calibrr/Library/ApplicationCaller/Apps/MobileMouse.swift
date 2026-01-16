//
//  MobileMouse.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct MobileMouse: ExternalApplication {
        
        public typealias ActionType = Applications.MobileMouse.Action
        
        public let scheme = "mobilemouse:"
        public let fallbackURL = "http://www.mobilemouse.com"
        public let appStoreId = "356395556"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.MobileMouse {
    
    enum Action {
        case open
    }
}

extension Applications.MobileMouse.Action: ExternalApplicationAction {
    
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
