//
//  Workflow.swift
//  Appz
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Workflow: ExternalApplication {
        
        public typealias ActionType = Applications.Workflow.Action
        
        public let scheme = "workflow:"
        public let fallbackURL = "https://workflow.is"
        public let appStoreId = "915249334"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Workflow {
    
    enum Action {
        case open
    }
}

extension Applications.Workflow.Action: ExternalApplicationAction {
    
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

