//
//  APIKeys.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 03/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
//

public class APIKeys
{
//    public static let BASE_URL = "http://calibrr.com/"
    public static let BASE_URL = "https://calibrr.com/"              //"http://www.calibrr.com/"
//    public static let BASE_URL = "http://18.223.83.174/api/v1/"   //"http://www.calibrr.com/api/v1/"
    public static let BASE_API_URL = "https://api.calibrr.com/api"
    
//    OpenAPIClientAPI.customHeaders[APIKeys.HTTP_AUTHORIZATION_HEADER] = APIKeys.HTTP_AUTHORIZATION_PREFIX + databaseService.masterProfile.token!
    public static let HTTP_AUTHORIZATION_HEADER = "Authorization"
    public static let HTTP_AUTHORIZATION_PREFIX = "Bearer "
//    public static let HTTP_CLIENT_NAME = "ios-calibrr"
//    public static let HTTP_CLIENT_NAME_HEADER = "client-name"
//    public static let HTTP_CLIENT_VERSION_HEADER = "client-version"
//    public static let HTTP_API_VERSION_HEADER = "api-version"
//    public static let HTTP_API_VERSION = ReadAPIVersion()
    public static let URL_POLICY = "\(BASE_URL)legal"
    public static let URL_TERMS = "\(BASE_URL)legal"
    public static let URL_EULA = "\(BASE_URL)legal"
    public static let URL_APPSTORE = "itms-apps://apps.apple.com/us/app/calibrr/id1377015871"
    public static let URL_APPSTORE_REVIEW = "\(URL_APPSTORE)?action=write-review"
    public static let EMAIL_FEEDBACK = "contact@calibrr.com"
    
//    public static let HTTP_CODE_AUTHORIZATION_EXPIRED = 401
//    public static let HTTP_CODE_UNAUTHORIZED = 403
//    public static let HTTP_CODE_NOT_FOUND = 404
//    public static let HTTP_CODE_FORCE_UPDATE = 418
    
//    private static func ReadAPIVersion() -> String
//    {
//        var version : String? = nil
//        if let filepath = Bundle.main.path(forResource: "ApiVersion", ofType: "txt") {
//            version = try? String(contentsOfFile: filepath)
//            version = version?.trimmingCharacters(in: .whitespacesAndNewlines)
//        }
//        return version ?? ""
//    }
    
    
//    static let twitch_client_id = "30pqvtzqyxad5qvjlxbxc674kesrv"
//
//    static let twilioSID = "AC5205fb44d272955da6fcaab63ca3eedc"
//    static let twilioSecret = "7a560b69d93b9435d9a79337cff2b30b"
//    static let twiliofromNumber = "+61476855965".changePlusTo2B
    
//    static let twiliobaseurl = "https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages.json"
    
}
