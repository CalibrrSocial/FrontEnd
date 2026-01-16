//
//  Wallet.swift
//  Appz
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct Wallet: ExternalApplication {
        
        public typealias ActionType = Applications.Wallet.Action
        
        public let scheme = "shoebox:"
        public let fallbackURL = ""
        public let appStoreId = ""
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.Wallet {
    
    enum Action {
        case open
    }
}


extension Applications.Wallet.Action: ExternalApplicationAction {
    
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

