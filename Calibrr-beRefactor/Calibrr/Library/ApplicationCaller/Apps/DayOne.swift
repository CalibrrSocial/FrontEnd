//
//  DayOne.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct DayOne: ExternalApplication {
        
        public typealias ActionType = Applications.DayOne.Action
        
        public let scheme = "dayone:"
        public let fallbackURL = "http://dayoneapp.com/"
        public let appStoreId = "421706526"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.DayOne {
    
    enum Action {
        case open
    }
}

extension Applications.DayOne.Action: ExternalApplicationAction {
    
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
