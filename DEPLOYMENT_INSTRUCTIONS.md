# Broken Links Feature - Deployment Instructions

## Overview
The broken links feature has been implemented with the correct architecture based on how the existing email notification system works. Here's what needs to be deployed:

## What Was Implemented

### 1. iOS App Changes ✅ (Already Done)
- **HeaderProfileCell.swift**: Added purple "Report Broken Link" button
- **ProfileFriendPage.swift**: Complete broken link reporting UI and API integration
- **ProfileEditPage.swift**: Profile save reminder to test links

### 2. Backend Lambda Function ✅ (Ready to Deploy)
- **NewAWSBE/reportBrokenLinks.mjs**: New Lambda function that handles broken link reports

### 3. Email Lambda ✅ (Already Deployed)
- **NewAWSBE/emailNotificationFinal.js**: Already supports "dead_link_reported" notifications

## Deployment Steps

### Step 1: Deploy the reportBrokenLinks Lambda
1. Deploy `NewAWSBE/reportBrokenLinks.mjs` as a new AWS Lambda function
2. Set environment variables:
   - `EMAIL_LAMBDA_NAME=emailNotificationFinal`
   - `REGION=us-east-1`

### Step 2: Configure API Gateway
1. Add a new route to your existing API Gateway:
   - **Path**: `/broken-links/report`
   - **Method**: POST
   - **Integration**: Lambda function `reportBrokenLinks`
   - **Authentication**: Same as other Calibrr API endpoints (JWT)

### Step 3: Set Lambda Permissions
Ensure the `reportBrokenLinks` Lambda has permission to invoke the `emailNotificationFinal` Lambda:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:ACCOUNT:function:emailNotificationFinal"
    }
  ]
}
```

## Architecture Flow

```
iOS App (ProfileFriendPage.swift)
    ↓ POST /broken-links/report
Calibrr API (api.calibrr.com)
    ↓ Routes to Lambda
reportBrokenLinks.mjs
    ↓ Invokes Lambda
emailNotificationFinal.js
    ↓ Sends email via AWS SES
User receives email notification
```

## Testing

After deployment, test the flow:

1. **iOS App**: Tap "Report Broken Link" on a user's profile
2. **Select platforms**: Choose Instagram, Facebook, etc.
3. **Submit report**: Should get success message
4. **Check email**: Reported user should receive email notification

## Expected API Calls

The iOS app will make this call:
```
POST https://api.calibrr.com/api/broken-links/report
Authorization: Bearer {jwt-token}
Content-Type: application/json

{
  "platforms": ["Instagram"],
  "recipientEmail": "user@example.com", 
  "reporterName": "John Doe"
}
```

## Files Changed

### iOS App
- `Calibrr-beRefactor/Calibrr/UI/Profile/HeaderProfileCell.swift`
- `Calibrr-beRefactor/Calibrr/UI/Profile/Friend/ProfileFriendPage.swift`
- `Calibrr-beRefactor/Calibrr/UI/Profile/Edit/ProfileEditPage.swift`

### Backend
- `NewAWSBE/reportBrokenLinks.mjs` (NEW - needs deployment)
- `NewAWSBE/emailNotificationFinal.js` (already deployed)

## Notes

- The `emailNotificationFinal.js` Lambda already supports the "dead_link_reported" notification type
- The iOS app uses the same authentication pattern as other Calibrr API calls
- The broken link reporting follows the same architecture as profile likes and other features
- No direct AWS API Gateway calls from iOS - everything goes through the Calibrr API backend

Once you deploy the `reportBrokenLinks` Lambda and configure the API Gateway route, the feature should work end-to-end!
