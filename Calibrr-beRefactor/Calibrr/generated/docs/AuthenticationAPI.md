# AuthenticationAPI

All URIs are relative to *https://x1oyeepmz2.execute-api.us-east-1.amazonaws.com/prod*

Method | HTTP request | Description
------------- | ------------- | -------------
[**changePassword**](AuthenticationAPI.md#changepassword) | **POST** /auth/changepassword | Change password
[**forgotPassword**](AuthenticationAPI.md#forgotpassword) | **POST** /auth/forgotpassword | Forgot password
[**loginUser**](AuthenticationAPI.md#loginuser) | **POST** /auth/login | Login user
[**refreshToken**](AuthenticationAPI.md#refreshtoken) | **POST** /auth/refresh | Refresh user token
[**registerUser**](AuthenticationAPI.md#registeruser) | **POST** /auth/register | Registers user
[**removeUser**](AuthenticationAPI.md#removeuser) | **DELETE** /profile/{id} | Removes a user&#39;s account


# **changePassword**
```swift
    open class func changePassword( changePassword: ChangePassword) -> Promise<Void>
```

Change password

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let changePassword = ChangePassword(oldPassword: "oldPassword_example", newPassword: "newPassword_example") // ChangePassword | 

// Change password
AuthenticationAPI.changePassword(changePassword: changePassword).then {
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
 **changePassword** | [**ChangePassword**](ChangePassword.md) |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **forgotPassword**
```swift
    open class func forgotPassword( username: String) -> Promise<Void>
```

Forgot password

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let username = "username_example" // String | 

// Forgot password
AuthenticationAPI.forgotPassword(username: username).then {
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
 **username** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginUser**
```swift
    open class func loginUser( loginAuth: LoginAuth) -> Promise<LoginUser>
```

Login user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let loginAuth = LoginAuth(username: "username_example", password: "password_example") // LoginAuth | 

// Login user
AuthenticationAPI.loginUser(loginAuth: loginAuth).then {
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
 **loginAuth** | [**LoginAuth**](LoginAuth.md) |  | 

### Return type

[**LoginUser**](LoginUser.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshToken**
```swift
    open class func refreshToken( tokenAuth: TokenAuth) -> Promise<Token>
```

Refresh user token

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let tokenAuth = TokenAuth(refreshToken: "refreshToken_example") // TokenAuth | 

// Refresh user token
AuthenticationAPI.refreshToken(tokenAuth: tokenAuth).then {
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
 **tokenAuth** | [**TokenAuth**](TokenAuth.md) |  | 

### Return type

[**Token**](Token.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerUser**
```swift
    open class func registerUser( registerUser: RegisterUser) -> Promise<LoginUser>
```

Registers user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let registerUser = RegisterUser(email: "email_example", phone: "phone_example", password: "password_example", firstName: "firstName_example", lastName: "lastName_example") // RegisterUser | 

// Registers user
AuthenticationAPI.registerUser(registerUser: registerUser).then {
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
 **registerUser** | [**RegisterUser**](RegisterUser.md) |  | 

### Return type

[**LoginUser**](LoginUser.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeUser**
```swift
    open class func removeUser( id: String) -> Promise<Void>
```

Removes a user's account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let id = "id_example" // String | 

// Removes a user's account
AuthenticationAPI.removeUser(id: id).then {
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

Void (empty response body)

### Authorization

[CalibrrAuthorizer](../README.md#CalibrrAuthorizer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

