//
//  Linkedin.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Linkedin: ExternalApplication {
        
        public typealias ActionType = Applications.Linkedin.Action
        
        public let scheme = "linkedin:"
        public let fallbackURL = "http://www.linkedin.com/"
        public let appStoreId = "288429040"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Linkedin {
    
    enum Action {
        case open
    }
}

extension Applications.Linkedin.Action: ExternalApplicationAction {
    
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
