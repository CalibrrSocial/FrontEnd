//
//  Phone.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Phone: ExternalApplication {
        
        public typealias ActionType = Applications.Phone.Action
        
        public let scheme = "tel:"
        public let fallbackURL = ""
        public let appStoreId = ""
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Phone {
    
    enum Action {
        case open(number: String)
    }
}

extension Applications.Phone.Action: ExternalApplicationAction {
    
    public var paths: ActionPaths {
        
        switch self {
        case .open(let number):
            return ActionPaths(
                app: Path(
                    pathComponents: [number],
                    queryParameters: [:]
                ),
                web: Path()
            )
        }
    }
}
