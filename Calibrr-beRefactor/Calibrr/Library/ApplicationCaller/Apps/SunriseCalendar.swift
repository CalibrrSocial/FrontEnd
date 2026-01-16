//
//  SunriseCalendar.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct SunriseCalendar: ExternalApplication {
        
        public typealias ActionType = Applications.SunriseCalendar.Action
        
        public let scheme = "sunrise:"
        public let fallbackURL = "https://calendar.sunrise.am"
        public let appStoreId = "599114150"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.SunriseCalendar {
    
    enum Action {
        case open
    }
}

extension Applications.SunriseCalendar.Action: ExternalApplicationAction {
    
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
