//
//  AppleMaps.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct AppleMaps: ExternalApplication {
        
        public typealias ActionType = Applications.AppleMaps.Action
        
        public let scheme = "maps:"
        public let fallbackURL = ""
        public let appStoreId = ""
        
        public init() {}
    }
}

// MARK: - Actions

//Direction mod should be ("d" -> For driving, "w"-> for foot, "r"-> for public transit)

public extension Applications.AppleMaps {
    
    enum Action {
        case open
        case displayDirections(saddr: String,
            daddr: String,
            directionsmode: String)
    }
}

extension Applications.AppleMaps.Action: ExternalApplicationAction {
    
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
        case .displayDirections(let saddr, let daddr, let directionsmode):
            return ActionPaths(
                app: Path(
                    pathComponents: ["app"],
                    queryParameters: [
                        "saddr": saddr,
                        "daddr": daddr,
                        "dirflg": directionsmode,
                    ]
                ),
                web: Path()
            )
        }
    }
}
