# Email Notification Infrastructure Setup

This document explains how to set up and use the email notification system for the Calibrr app.

## Files Created

1. **sendEmailNotification.js** - Main Lambda function that sends emails using AWS SES
2. **emailNotificationHelper.js** - Utility functions for easily triggering notifications
3. **testEmailNotification.js** - Test function to verify the system works

## AWS Setup Required

### 1. AWS SES (Simple Email Service) Setup

1. Go to AWS SES console
2. Verify the domain `calibrr.com` or at minimum verify the email `contact@calibrr.com`
3. Request production access (move out of sandbox mode) so you can send to any email address
4. Set up SPF/DKIM records in your DNS to improve deliverability

### 2. Lambda Function Deployment

Deploy the `sendEmailNotification.js` function with these environment variables:
- `REGION` - AWS region (e.g., "us-east-1")
- `USER_TABLE_NAME` - Name of your DynamoDB users table

### 3. IAM Permissions

The Lambda function needs these permissions:
- `ses:SendEmail` - To send emails via SES
- `dynamodb:GetItem` - To fetch user data from DynamoDB
- `lambda:InvokeFunction` - To trigger email notifications from other functions

## Notification Types Supported

### 1. Profile Liked
**When:** Someone likes another user's profile
**Email Subject:** "FirstName LastName liked you!"
**Usage:**
```javascript
const emailHelper = require('./emailNotificationHelper')
await emailHelper.sendProfileLikedNotification(recipientUserId, senderUserId)
```

### 2. Attribute Liked
**When:** Someone likes a specific attribute on another user's profile
**Email Subject:** "FirstName LastName likes your 'Category/Attribute'"
**Usage:**
```javascript
await emailHelper.sendAttributeLikedNotification(
    recipientUserId, 
    senderUserId, 
    "Music", 
    "Hip Hop"
)
```

### 3. Dead Link Reported
**When:** Someone reports that a user's social media link is broken
**Email Subject:** "Fix your broken links!"
**Usage:**
```javascript
await emailHelper.sendDeadLinkReportedNotification(
    reportedUserId, 
    ["Instagram", "Snapchat"]
)
```

## Email Templates

All emails use the same base HTML template styling as the current password reset emails, including:
- Calibrr Social branding
- Professional styling with Arial font
- Responsive design
- Both HTML and plain text versions

## Testing

Use the `testEmailNotification.js` function to verify the system works:

1. Deploy the test function
2. Run it with a test user ID and email
3. Check that the email is received and formatted correctly

## Implementation Timeline

**Milestone 1 (Current):** Infrastructure setup completed
- ✅ Email notification Lambda function created
- ✅ Helper utilities created
- ✅ Email templates implemented
- ⏳ AWS SES setup (requires domain verification)

**Future Milestones:** Integration with features
- Milestone 2: Integrate with profile liking feature
- Milestone 3: Integrate with attribute liking and dead link reporting

## Next Steps for Nolan

1. Set up AWS SES and verify `contact@calibrr.com` domain
2. Deploy the `sendEmailNotification` Lambda function
3. Test the system using the test function
4. Confirm emails are being delivered to inbox (not spam)

The infrastructure is now ready - when profile likes and other features are implemented in future milestones, simply add the helper function calls to trigger the appropriate notifications. 