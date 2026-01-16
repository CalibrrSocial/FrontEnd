//
//  ExternalApplication.swift
//  Appz
//
//
//  Copyright © kitz. All rights reserved.
//

/** Protocol for grouping the external application functionality.
    For now, it's as simple as calling openURL
 */
public protocol ExternalApplication {
    
    associatedtype ActionType: ExternalApplicationAction

    
    var scheme: String { get }
    var fallbackURL: String { get }
    var appStoreId: String { get }
}

public struct ActionPaths {
    
    public var app = Path()
    public var web = Path()
    
    public init() {}
    
    public init(app: Path, web: Path) {
        
        self.app = app
        self.web = web
    }
}

public protocol ExternalApplicationAction {
    var paths: ActionPaths { get }
}
