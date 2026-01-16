//
//  KakaoTalk.swift
//  Pods
//
//
//  Copyright © kitz. All rights reserved.
//

public extension Applications {
    
    struct KakaoTalk: ExternalApplication {
        
        public typealias ActionType = Applications.KakaoTalk.Action
        
        public let scheme = "kakaotalk:"
        public let fallbackURL = "http://www.kakao.com/talk"
        public let appStoreId = "362057947"
        
        public init() {}
    }
}

// MARK: - Actions

public extension Applications.KakaoTalk {
    
    enum Action {
        case open
    }
}

extension Applications.KakaoTalk.Action: ExternalApplicationAction {
    
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
