//
//  GoogleMail.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct GoogleMail: ExternalApplication {
        
        public typealias ActionType = Applications.GoogleMail.Action
        
        public let scheme = "googlegmail:"
        public let fallbackURL = "https://mail.google.com/"
        public let appStoreId = "422689480"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.GoogleMail {
    
    enum Action {
        case open
    }
}

extension Applications.GoogleMail.Action: ExternalApplicationAction {
    
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
