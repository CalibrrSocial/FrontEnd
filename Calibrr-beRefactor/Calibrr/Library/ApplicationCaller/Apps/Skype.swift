//
//  Skype.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Skype: ExternalApplication {
        
        public typealias ActionType = Applications.Skype.Action
        
        public let scheme = "Skype:"
        public let fallbackURL = "http://www.skype.com/"
        public let appStoreId = "304878510"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Skype {
    
    enum Action {
        case open
    }
}

extension Applications.Skype.Action: ExternalApplicationAction {
    
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
