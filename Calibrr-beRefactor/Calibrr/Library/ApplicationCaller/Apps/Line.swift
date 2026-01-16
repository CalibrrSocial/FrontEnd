//
//  Line.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Line: ExternalApplication {
        
        public typealias ActionType = Applications.Line.Action
        
        public let scheme = "line:"
        public let fallbackURL = "http://line.me/"
        public let appStoreId = "443904275"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Line {
    
    enum Action {
        case open
    }
}

extension Applications.Line.Action: ExternalApplicationAction {
    
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
