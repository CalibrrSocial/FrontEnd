//
//  Flickr.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Flickr: ExternalApplication {
        
        public typealias ActionType = Applications.Flickr.Action
        
        public let scheme = "Flickr:"
        public let fallbackURL = "https://www.flickr.com/"
        public let appStoreId = "328407587"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Flickr {
    
    enum Action {
        case open
    }
}

extension Applications.Flickr.Action: ExternalApplicationAction {
    
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
