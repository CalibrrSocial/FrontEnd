//
//  Vimeo.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Vimeo: ExternalApplication {
        
        public typealias ActionType = Applications.Vimeo.Action
        
        public let scheme = "vimeo:"
        public let fallbackURL = "https://vimeo.com/everywhere"
        public let appStoreId = "425194759"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Vimeo {
    
    enum Action {
        case open
    }
}

extension Applications.Vimeo.Action: ExternalApplicationAction {
    
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

