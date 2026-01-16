//
//  FileApp.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct FileApp: ExternalApplication {
        
        public typealias ActionType = Applications.FileApp.Action
        
        public let scheme = "fileapp:"
        public let fallbackURL = "http://fileapp.com"
        public let appStoreId = "297804694"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.FileApp {
    
    enum Action {
        case open
    }
}

extension Applications.FileApp.Action: ExternalApplicationAction {
    
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

