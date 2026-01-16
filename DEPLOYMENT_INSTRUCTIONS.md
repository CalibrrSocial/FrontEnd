# Broken Links Feature - Deployment Instructions

## Overview
The broken links feature calls the existing `emailNotificationFinal` Lambda directly via API Gateway. The Lambda already supports "dead_link_reported" notifications.

## What Was Implemented

### 1. iOS App Changes ✅ (Already Done)
- **HeaderProfileCell.swift**: Added purple "Report Broken Link" button
- **ProfileFriendPage.swift**: Complete broken link reporting UI and API integration
- **ProfileEditPage.swift**: Profile save reminder to test links

### 2. Email Lambda ✅ (Already Deployed)
- **NewAWSBE/emailNotificationFinal.js**: Already supports "dead_link_reported" notifications

## Deployment Steps

### Step 1: Configure API Gateway (If Not Already Done)
The iOS app calls the `emailNotificationFinal` Lambda directly at:
```
https://x1oyeepmz2.execute-api.us-east-1.amazonaws.com/prod/email-notification
```

Ensure this endpoint is configured as:
- **Method**: POST
- **Integration**: Lambda function `emailNotificationFinal`
- **Authentication**: NONE (public endpoint)

### Step 2: Test the Feature
The feature should work immediately since `emailNotificationFinal` already supports broken link notifications.

## Architecture Flow

```
iOS App (ProfileFriendPage.swift)
    ↓ POST /email-notification
AWS API Gateway
    ↓ Invokes Lambda
emailNotificationFinal.js
    ↓ Sends email via AWS SES
User receives email notification
```

## Testing

Test the flow:

1. **iOS App**: Tap "Report Broken Link" on a user's profile
2. **Select platforms**: Choose Instagram, Facebook, etc.
3. **Submit report**: Should get success message
4. **Check email**: Reported user should receive email notification

## Expected API Calls

The iOS app will make this call:
```
POST https://x1oyeepmz2.execute-api.us-east-1.amazonaws.com/prod/email-notification
Content-Type: application/json

{
  "notificationType": "dead_link_reported",
  "additionalData": {
    "recipientEmail": "user@example.com",
    "platforms": ["Instagram"],
    "reporterName": "John Doe"
  }
}
```

## Files Changed

### iOS App
- `Calibrr-beRefactor/Calibrr/UI/Profile/HeaderProfileCell.swift`
- `Calibrr-beRefactor/Calibrr/UI/Profile/Friend/ProfileFriendPage.swift`
- `Calibrr-beRefactor/Calibrr/UI/Profile/Edit/ProfileEditPage.swift`

### Backend
- `NewAWSBE/emailNotificationFinal.js` (already deployed and supports this feature)

## Notes

- The `emailNotificationFinal.js` Lambda already supports the "dead_link_reported" notification type
- The iOS app calls the Lambda directly via API Gateway (no authentication required)
- This is the simplest approach - no additional Lambda functions needed
- If you're getting 403 errors, you need to make the `/email-notification` endpoint public in API Gateway

The feature should work immediately if the API Gateway endpoint is configured correctly!
