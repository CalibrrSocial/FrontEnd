//
//  GoogleSheets.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct GoogleSheets: ExternalApplication {
        
        public typealias ActionType = Applications.GoogleSheets.Action
        
        public let scheme = "googlesheets:"
        public let fallbackURL = "http://www.google.com/sheets/about/"
        public let appStoreId = "842849113"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.GoogleSheets {
    
    enum Action {
        case open
    }
}

extension Applications.GoogleSheets.Action: ExternalApplicationAction {
    
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
