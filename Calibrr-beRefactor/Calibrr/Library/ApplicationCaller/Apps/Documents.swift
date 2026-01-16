//
//  Documents.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Documents: ExternalApplication {
        
        public typealias ActionType = Applications.Documents.Action
        
        public let scheme = "rdocs:"
        public let fallbackURL = "https://readdle.com/products/documents/"
        public let appStoreId = "364901807"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Documents {
    
    enum Action {
        case open
    }
}

extension Applications.Documents.Action: ExternalApplicationAction {
    
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
