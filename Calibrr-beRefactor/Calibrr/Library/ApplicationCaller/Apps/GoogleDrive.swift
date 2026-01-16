//
//  GoogleDrive.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct GoogleDrive: ExternalApplication {
        
        public typealias ActionType = Applications.GoogleDrive.Action
        
        public let scheme = "googledrive:"
        public let fallbackURL = "https://www.google.com/drive/"
        public let appStoreId = "507874739"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.GoogleDrive {
    
    enum Action {
        case open
    }
}

extension Applications.GoogleDrive.Action: ExternalApplicationAction {
    
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
