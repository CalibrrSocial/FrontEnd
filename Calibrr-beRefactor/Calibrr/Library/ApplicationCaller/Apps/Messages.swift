//
//  Messages.swift
//  Appz
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Messages: ExternalApplication {
        
        public typealias ActionType = Applications.Messages.Action

        public let scheme = "sms:"
        public let fallbackURL = ""
        public let appStoreId = ""
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Messages {
    
    enum Action {
        
        case sms(phone: String)
    }
}

extension Applications.Messages.Action: ExternalApplicationAction {
    
    public var paths: ActionPaths {
        
        switch self {
        case .sms(let phone):
            return ActionPaths(
                app: Path(
                    pathComponents: [phone],
                    queryParameters: [:]
                ),
                web: Path()
            )
        }
    }
}
