//
//  FaceTime.swift
//  Appz
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct FaceTime: ExternalApplication {
        
        public typealias ActionType = Applications.FaceTime.Action
        
        public let scheme = "facetime:"
        public let fallbackURL = ""
        public let appStoreId = ""
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.FaceTime {
    
    enum Action {
        case call(email: String)
    }
}

extension Applications.FaceTime.Action: ExternalApplicationAction {
    
    public var paths: ActionPaths {
        
        switch self {
        case .call(let email):
            return ActionPaths(
                app: Path(
                    pathComponents: [email],
                    queryParameters: [:]
                ),
                web: Path()
            )
        }
    }
}

