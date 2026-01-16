//
//  ScannerPro.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct ScannerPro: ExternalApplication {
        
        public typealias ActionType = Applications.ScannerPro.Action
        
        public let scheme = "spprint:"
        public let fallbackURL = "https://readdle.com/products/scannerpro/"
        public let appStoreId = "333710667"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.ScannerPro {
    
    enum Action {
        case open
    }
}

extension Applications.ScannerPro.Action: ExternalApplicationAction {
    
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
