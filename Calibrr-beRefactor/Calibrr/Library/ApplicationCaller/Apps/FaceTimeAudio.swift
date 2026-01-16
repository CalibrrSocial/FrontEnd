//
//  FaceTimeAudio.swift
//  Appz
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct FaceTimeAudio: ExternalApplication {
        
        public typealias ActionType = Applications.FaceTimeAudio.Action
        
        public let scheme = "facetime-audio:"
        public let fallbackURL = ""
        public let appStoreId = ""
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.FaceTimeAudio {
    
    enum Action {
        case call(email: String)
    }
}

extension Applications.FaceTimeAudio.Action: ExternalApplicationAction {
    
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
