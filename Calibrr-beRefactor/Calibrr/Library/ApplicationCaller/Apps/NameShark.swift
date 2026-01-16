//
//  NameShark.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct NameShark: ExternalApplication {
        
        public typealias ActionType = Applications.NameShark.Action
        
        public let scheme = "nameshark:"
        public let fallbackURL = "http://www.namesharkapp.com"
        public let appStoreId = "906531062"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.NameShark {
    
    enum Action {
        case open
    }
}

extension Applications.NameShark.Action: ExternalApplicationAction {
    
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
