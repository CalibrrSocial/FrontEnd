# ProfileAPI

All URIs are relative to *https://x1oyeepmz2.execute-api.us-east-1.amazonaws.com/prod*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getLikes**](ProfileAPI.md#getlikes) | **GET** /profile/{id}/likes | Gets the number of likes a user&#39;s profile has
[**getRelationship**](ProfileAPI.md#getrelationship) | **GET** /profile/{id}/relationships/{friendId} | Gets the relationship
[**getUser**](ProfileAPI.md#getuser) | **GET** /profile/{id} | Get a user&#39;s profile
[**getUserRelationships**](ProfileAPI.md#getuserrelationships) | **GET** /profile/{id}/relationships | Gets user&#39;s relationships
[**getUserReports**](ProfileAPI.md#getuserreports) | **GET** /profile/{id}/reports | Gets the reports that were submitted by the user
[**likeProfile**](ProfileAPI.md#likeprofile) | **POST** /profile/{id}/likes | Like user profile
[**reportUser**](ProfileAPI.md#reportuser) | **PUT** /profile/{id}/reports | Report a user
[**requestFriend**](ProfileAPI.md#requestfriend) | **PUT** /profile/{id}/relationships/{friendId} | Request user as friend
[**unblockUser**](ProfileAPI.md#unblockuser) | **DELETE** /profile/{id}/relationships/{friendId} | Unblock user&#39;s friend - removing their relationship
[**unlikeProfile**](ProfileAPI.md#unlikeprofile) | **DELETE** /profile/{id}/likes | Unlike user profile
[**updateFriend**](ProfileAPI.md#updatefriend) | **POST** /profile/{id}/relationships/{friendId} | Update user&#39;s friend status - accept/reject/block
[**updateUserLocation**](ProfileAPI.md#updateuserlocation) | **POST** /profile/{id}/location | Update a user&#39;s location
[**updateUserProfile**](ProfileAPI.md#updateuserprofile) | **POST** /profile/{id} | Update a user&#39;s personalInfo and socialInfo


# **getLikes**
```swift
    open class func getLikes( id: String) -> Promise<Int>
```

Gets the number of likes a user's profile has

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Gets the number of likes a user's profile has
ProfileAPI.getLikes(id: id).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 

### Return type

**Int**

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRelationship**
```swift
    open class func getRelationship( id: String,  friendId: String) -> Promise<Relationship>
```

Gets the relationship

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let friendId = "friendId_example" // String | 

// Gets the relationship
ProfileAPI.getRelationship(id: id, friendId: friendId).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **friendId** | **String** |  | 

### Return type

[**Relationship**](Relationship.md)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUser**
```swift
    open class func getUser( id: String) -> Promise<User>
```

Get a user's profile

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Get a user's profile
ProfileAPI.getUser(id: id).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 

### Return type

[**User**](User.md)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserRelationships**
```swift
    open class func getUserRelationships( id: String) -> Promise<[Relationship]>
```

Gets user's relationships

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Gets user's relationships
ProfileAPI.getUserRelationships(id: id).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 

### Return type

[**[Relationship]**](Relationship.md)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserReports**
```swift
    open class func getUserReports( id: String) -> Promise<[UserReport]>
```

Gets the reports that were submitted by the user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Gets the reports that were submitted by the user
ProfileAPI.getUserReports(id: id).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 

### Return type

[**[UserReport]**](UserReport.md)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **likeProfile**
```swift
    open class func likeProfile( id: String,  profileLikedId: String) -> Promise<Void>
```

Like user profile

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let profileLikedId = "profileLikedId_example" // String | 

// Like user profile
ProfileAPI.likeProfile(id: id, profileLikedId: profileLikedId).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **profileLikedId** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportUser**
```swift
    open class func reportUser( id: String,  userReport: UserReport) -> Promise<Void>
```

Report a user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let userReport = UserReport(userId: "userId_example", info: "info_example", dateCreated: Date()) // UserReport | 

// Report a user
ProfileAPI.reportUser(id: id, userReport: userReport).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **userReport** | [**UserReport**](UserReport.md) |  | 

### Return type

Void (empty response body)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestFriend**
```swift
    open class func requestFriend( id: String,  friendId: String) -> Promise<Void>
```

Request user as friend

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let friendId = "friendId_example" // String | 

// Request user as friend
ProfileAPI.requestFriend(id: id, friendId: friendId).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **friendId** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unblockUser**
```swift
    open class func unblockUser( id: String,  friendId: String) -> Promise<Void>
```

Unblock user's friend - removing their relationship

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let friendId = "friendId_example" // String | 

// Unblock user's friend - removing their relationship
ProfileAPI.unblockUser(id: id, friendId: friendId).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **friendId** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unlikeProfile**
```swift
    open class func unlikeProfile( id: String,  profileLikedId: String) -> Promise<Void>
```

Unlike user profile

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let profileLikedId = "profileLikedId_example" // String | 

// Unlike user profile
ProfileAPI.unlikeProfile(id: id, profileLikedId: profileLikedId).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **profileLikedId** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateFriend**
```swift
    open class func updateFriend( id: String,  friendId: String) -> Promise<Void>
```

Update user's friend status - accept/reject/block

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let friendId = "friendId_example" // String | 

// Update user's friend status - accept/reject/block
ProfileAPI.updateFriend(id: id, friendId: friendId).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **friendId** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUserLocation**
```swift
    open class func updateUserLocation( id: String,  user: User) -> Promise<User>
```

Update a user's location

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let user = User(id: "id_example", email: "email_example", phone: "phone_example", firstName: "firstName_example", lastName: "lastName_example", ghostMode: false, subscription: "subscription_example", location: Position(latitude: 123, longitude: 123), locationTimestamp: Date(), pictureProfile: "pictureProfile_example", pictureCover: "pictureCover_example", personalInfo: UserPersonalInfo(dob: Date(), gender: "gender_example", bio: "bio_example", education: "education_example", politics: "politics_example", religion: "religion_example", occupation: "occupation_example", sexuality: "sexuality_example", relationship: "relationship_example"), socialInfo: UserSocialInfo(facebook: "facebook_example", instagram: "instagram_example", snapchat: "snapchat_example", linkedIn: "linkedIn_example", twitter: "twitter_example", resume: "resume_example", coverLetter: "coverLetter_example", email: "email_example", website: "website_example", contact: "contact_example"), liked: false, likeCount: 123, visitCount: 123) // User | 

// Update a user's location
ProfileAPI.updateUserLocation(id: id, user: user).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **user** | [**User**](User.md) |  | 

### Return type

[**User**](User.md)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUserProfile**
```swift
    open class func updateUserProfile( id: String,  user: User) -> Promise<User>
```

Update a user's personalInfo and socialInfo

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 
let user = User(id: "id_example", email: "email_example", phone: "phone_example", firstName: "firstName_example", lastName: "lastName_example", ghostMode: false, subscription: "subscription_example", location: Position(latitude: 123, longitude: 123), locationTimestamp: Date(), pictureProfile: "pictureProfile_example", pictureCover: "pictureCover_example", personalInfo: UserPersonalInfo(dob: Date(), gender: "gender_example", bio: "bio_example", education: "education_example", politics: "politics_example", religion: "religion_example", occupation: "occupation_example", sexuality: "sexuality_example", relationship: "relationship_example"), socialInfo: UserSocialInfo(facebook: "facebook_example", instagram: "instagram_example", snapchat: "snapchat_example", linkedIn: "linkedIn_example", twitter: "twitter_example", resume: "resume_example", coverLetter: "coverLetter_example", email: "email_example", website: "website_example", contact: "contact_example"), liked: false, likeCount: 123, visitCount: 123) // User | 

// Update a user's personalInfo and socialInfo
ProfileAPI.updateUserProfile(id: id, user: user).then {
         // when the promise is fulfilled
     }.always {
         // regardless of whether the promise is fulfilled, or rejected
     }.catch { errorType in
         // when the promise is rejected
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** |  | 
 **user** | [**User**](User.md) |  | 

### Return type

[**User**](User.md)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

