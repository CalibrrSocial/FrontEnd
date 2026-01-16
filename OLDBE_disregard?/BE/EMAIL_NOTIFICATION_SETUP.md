# Email Notification Infrastructure Setup

This document explains how to set up and use the email notification system for the Calibrr app.

## Files Created

1. **emailNotificationFinal.js** - Main Lambda function that sends emails using AWS SES
2. **emailNotificationHelper.js** - Utility functions for easily triggering notifications
3. **testEmailNotification.js** - Test function to verify the system works

## AWS Setup Completed

### 1. AWS SES (Simple Email Service) Setup ✅

- ✅ Domain `calibrr.com` is verified and can send emails
- ✅ Test email address verified for testing
- ✅ Emails are being sent successfully (some may initially go to spam)
- ⚠️ Currently in sandbox mode - can only send to verified email addresses

**To improve deliverability:**
- Add SPF record to DNS: `v=spf1 include:amazonses.com ~all`
- Request production access in AWS SES console to send to any email address
- DKIM is already enabled during domain verification

### 2. Lambda Functions Deployed ✅

**Main Function:** `emailNotificationFinal`
- Runtime: Node.js 18.x
- Uses AWS SDK v3 with CommonJS syntax
- Environment variables:
  - `REGION`: `us-east-1`
  - `USER_TABLE_NAME`: `Users`

**Test Function:** `testEmailNotification` 
- Environment variables:
  - `REGION`: `us-east-1`
  - `USER_TABLE_NAME`: `Users`
  - `EMAIL_NOTIFICATION_FUNCTION_NAME`: `emailNotificationFinal`

### 3. IAM Permissions ✅

Both functions use the existing `CalibrrLambda` role with permissions for:
- `ses:SendEmail` and `ses:SendRawEmail` - To send emails via SES
- `dynamodb:GetItem`, `dynamodb:PutItem`, `dynamodb:DeleteItem` - To fetch/manage user data
- `lambda:InvokeFunction` - To trigger email notifications from other functions

## Notification Types Implemented

### 1. Profile Liked ✅
**When:** Someone likes another user's profile
**Email Subject:** "FirstName LastName liked you!"
**Email Content:** "FirstName LastName just liked your profile on the Calibrr Social app-- go like their profile back!"

### 2. Attribute Liked ✅
**When:** Someone likes a specific attribute on another user's profile  
**Email Subject:** "FirstName LastName likes your 'Category/Attribute'"
**Email Content:** "FirstName LastName just liked your 'Category/Attribute' on the Calibrr Social app...looks like you caught their attention, or maybe have something in common? Go hit them back on the Calibrr Social app!"

### 3. Dead Link Reported ✅
**When:** Someone reports that a user's social media link is broken
**Email Subject:** "Fix your broken links!"
**Email Content:** Lists the broken platforms and provides instructions to fix them

## How to Trigger Email Notifications

### Direct Lambda Invocation

To trigger an email notification from another Lambda function:

```javascript
const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({region: 'us-east-1'});

// Profile liked notification
const profileLikedPayload = {
    notificationType: 'profile_liked',
    recipientUserId: 'user-123',
    senderUserId: 'user-456'
};

await lambda.invoke({
    FunctionName: 'emailNotificationFinal',
    InvocationType: 'Event', // Async
    Payload: JSON.stringify(profileLikedPayload)
}).promise();

// Attribute liked notification  
const attributeLikedPayload = {
    notificationType: 'attribute_liked',
    recipientUserId: 'user-123',
    senderUserId: 'user-456',
    additionalData: {
        category: 'Music',
        attribute: 'Hip Hop'
    }
};

await lambda.invoke({
    FunctionName: 'emailNotificationFinal',
    InvocationType: 'Event',
    Payload: JSON.stringify(attributeLikedPayload)
}).promise();

// Dead link reported notification
const deadLinkPayload = {
    notificationType: 'dead_link_reported',
    recipientUserId: 'user-123',
    additionalData: {
        platforms: ['Instagram', 'Snapchat', 'TikTok']
    }
};

await lambda.invoke({
    FunctionName: 'emailNotificationFinal', 
    InvocationType: 'Event',
    Payload: JSON.stringify(deadLinkPayload)
}).promise();
```

### Using the Helper Functions

Use the `emailNotificationHelper.js` functions for cleaner code:

```javascript
const emailHelper = require('./emailNotificationHelper');

// Profile liked
await emailHelper.sendProfileLikedNotification(recipientUserId, senderUserId);

// Attribute liked
await emailHelper.sendAttributeLikedNotification(
    recipientUserId, 
    senderUserId, 
    'Music', 
    'Hip Hop'
);

// Dead link reported
await emailHelper.sendDeadLinkReportedNotification(
    reportedUserId, 
    ['Instagram', 'Snapchat']
);
```

## Email Templates ✅

All emails use professional HTML templates with:
- **Branding:** "Calibrr Social" header
- **Styling:** Arial font, clean layout, responsive design
- **Footer:** "This email was sent from the Calibrr Social app"
- **Dual Format:** Both HTML and plain text versions
- **From Address:** contact@calibrr.com

**Tested and verified:** All three email types successfully delivered with proper formatting.

## Testing ✅

The email system has been successfully tested:

**Test Results:**
- ✅ All three notification types working
- ✅ Emails deliver to verified addresses
- ✅ Professional formatting maintained
- ✅ Both HTML and text versions generated
- ⚠️ Some emails may initially go to spam (normal for new AWS SES setups)

**To test manually:**
1. Run the `testEmailNotification` function
2. Use payload: `{"testEmail": "your-verified-email@example.com"}`
3. Check email inbox for three test emails

## Integration Examples

### In Profile Like Function (likeProfile.js)
```javascript
// Add this after successfully liking a profile
const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({region: process.env.REGION});

await lambda.invoke({
    FunctionName: 'emailNotificationFinal',
    InvocationType: 'Event',
    Payload: JSON.stringify({
        notificationType: 'profile_liked',
        recipientUserId: profileOwnerId,
        senderUserId: likingUserId
    })
}).promise();
```

### In Dead Link Report Function
```javascript
// Add this when someone reports a broken link
await lambda.invoke({
    FunctionName: 'emailNotificationFinal', 
    InvocationType: 'Event',
    Payload: JSON.stringify({
        notificationType: 'dead_link_reported',
        recipientUserId: reportedUserId,
        additionalData: {
            platforms: ['Instagram'] // Platform(s) reported as broken
        }
    })
}).promise();
```

## Current Status

**Completed:**
- ✅ AWS SES domain verification for calibrr.com
- ✅ Lambda functions deployed and working
- ✅ All three email notification types implemented
- ✅ End-to-end testing successful
- ✅ Professional email templates matching specifications

**Next Steps for Integration:**
1. Add email notification triggers to existing Lambda functions:
   - `likeProfile.js` - Add profile liked notifications
   - Add attribute liking functionality and notifications
   - Add dead link reporting functionality and notifications

2. **For Production:**
   - Request AWS SES production access to send to any email address
   - Add DNS records (SPF, DKIM) to improve deliverability
   - Monitor email delivery rates and spam reports

## Function Names Reference

- **Main Email Function:** `emailNotificationFinal`
- **Test Function:** `testEmailNotification`  
- **Helper Functions:** Use `emailNotificationHelper.js`

The email notification infrastructure is fully operational and ready for integration into existing and future features! 