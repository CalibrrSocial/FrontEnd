# SearchAPI

All URIs are relative to *https://x1oyeepmz2.execute-api.us-east-1.amazonaws.com/prod*

Method | HTTP request | Description
------------- | ------------- | -------------
[**searchByDistance**](SearchAPI.md#searchbydistance) | **POST** /search/distance | Searches users by distance from given point
[**searchByName**](SearchAPI.md#searchbyname) | **POST** /search/name | Searches users by name


# **searchByDistance**
```swift
    open class func searchByDistance( position: Position,  minDistance: Distance,  maxDistance: Distance) -> Promise<[User]>
```

Searches users by distance from given point

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let position = "TODO" // Position | 
let minDistance = "TODO" // Distance | 
let maxDistance = "TODO" // Distance | 

// Searches users by distance from given point
SearchAPI.searchByDistance(position: position, minDistance: minDistance, maxDistance: maxDistance).then {
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
 **position** | [**Position**](.md) |  | 
 **minDistance** | [**Distance**](.md) |  | 
 **maxDistance** | [**Distance**](.md) |  | 

### Return type

[**[User]**](User.md)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchByName**
```swift
    open class func searchByName( name: String) -> Promise<[User]>
```

Searches users by name

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let name = "name_example" // String | 

// Searches users by name
SearchAPI.searchByName(name: name).then {
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
 **name** | **String** |  | 

### Return type

[**[User]**](User.md)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

