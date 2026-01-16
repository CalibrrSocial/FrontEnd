# Broken Links Reporting Feature

## Overview
This feature allows users to report broken social media links on other users' profiles. When a link is reported, the affected user receives an email notification asking them to fix their broken links.

## Components

### 1. Frontend (iOS App)
- **HeaderProfileCell.swift**: Added a purple "Report Broken Link" button (link.circle.fill icon) next to the block and report buttons
- **ProfileFriendPage.swift**: Handles the broken link reporting UI flow:
  - Shows platform selection dialog
  - Allows single or multiple platform reporting
  - Sends report to backend API
- **ProfileEditPage.swift**: Shows reminder after saving profile to test social media links
- **ProfileAPI+BlockReport.swift**: Added `reportBrokenLinks` API method

### 2. Backend (AWS Lambda)

#### emailNotificationFinal.js
Updated to handle "dead_link_reported" notification type:
- Sends formatted email with broken platform list
- Includes instructions on how to fix the links
- Uses Calibrr branding

## API Endpoint

```
POST /email-notification
```

**Request Body:**
```json
{
  "notificationType": "dead_link_reported",
  "additionalData": {
    "recipientEmail": "user@example.com",
    "platforms": ["Instagram", "Facebook", "TikTok"],
    "reporterName": "John Doe"
  }
}
```

**Response:**
```json
{
  "ok": true,
  "messageId": "email-message-id"
}
```

## User Experience

### For the Reporter:
1. Taps the purple link icon on another user's profile
2. Selects which platform(s) have broken links
3. Confirms the report
4. Sees success message

### For the Reported User:
1. Receives email notification with:
   - List of reported broken platforms
   - Reporter's name
   - Instructions to fix the links
   - Warning that people can't connect until fixed

### Profile Save Reminder:
- After saving profile with social links, users see a popup reminder to test their links
- Option to "Test My Links" or dismiss with "Later"

## Deployment Instructions

1. **Update emailNotificationFinal Lambda:**
Deploy the updated version with the new dead_link_reported handler

2. **iOS App Update:**
Build and deploy the updated iOS app with the new broken link reporting feature

**Note:** No additional API Gateway routes needed - uses existing `/email-notification` endpoint

## Testing

1. **Test Email Notification:**
```javascript
// Test payload for emailNotificationFinal
{
  "notificationType": "dead_link_reported",
  "additionalData": {
    "recipientEmail": "test@example.com",
    "platforms": ["Instagram", "TikTok"],
    "reporterName": "John Doe"
  }
}
```

2. **Test Report API:**
```bash
curl -X POST https://api.calibrr.com/email-notification \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"notificationType":"dead_link_reported","additionalData":{"recipientEmail":"test@example.com","platforms":["Instagram"],"reporterName":"Test User"}}'
```

## Security Considerations
- Users must be authenticated to report broken links
- Rate limiting should be implemented to prevent spam
- Consider adding a cooldown period between reports for the same user
- Log all reports for audit trail

## Future Enhancements
- Add analytics dashboard for broken link reports
- Auto-detect broken links using link validation
- Allow users to mark reports as "Fixed"
- Send follow-up reminders if links remain broken
