//
//  GoogleDocs.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct GoogleDocs: ExternalApplication {
        
        public typealias ActionType = Applications.GoogleDocs.Action
        
        public let scheme = "googledocs:"
        public let fallbackURL = "http://www.google.com/docs/about/"
        public let appStoreId = "842842640"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.GoogleDocs {
    
    enum Action {
        case open
    }
}

extension Applications.GoogleDocs.Action: ExternalApplicationAction {
    
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

