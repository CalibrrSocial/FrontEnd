# Attribute Likes Implementation Summary

## Overview
This implementation adds the ability to 'like' individual profile attributes in the Calibrr Social app, with email notifications following the same 2-email cap policy as profile likes.

## Features Implemented

### 1. Email Notification System
**File:** `/NewAWSBE/emailNotificationFinal.js`
- Added support for `attribute_liked` notification type
- Sends personalized emails: "FirstName LastName just liked your [Attribute]!"
- Includes link to Calibrr on App Store
- Uses same email template as profile likes but with attribute-specific messaging

### 2. Backend Database Structure
**Files:**
- `/EC2BACKENDGIT/database/migrations/2025_01_28_000001_create_attribute_likes_table.php`
- `/EC2BACKENDGIT/database/migrations/2025_01_28_000002_create_attribute_like_events_table.php`
- `/EC2BACKENDGIT/app/Models/AttributeLike.php`

**Database Tables:**
- `attribute_likes`: Stores individual attribute likes with soft delete support
- `attribute_like_events`: Tracks email notification state with 2-email cap logic

### 3. Backend API Endpoints
**File:** `/EC2BACKENDGIT/app/Http/Controllers/ProfileController.php`

**New Endpoints:**
- `POST /api/profile/{id}/attributes/like` - Like an attribute
- `DELETE /api/profile/{id}/attributes/like` - Unlike an attribute  
- `GET /api/profile/{id}/attributes/{category}/{attribute}/likes` - Get like count

**Features:**
- Same 2-email notification cap as profile likes
- Soft delete support for likes/unlikes
- Email notifications via Lambda service
- Comprehensive logging and error handling

### 4. Lambda Notification Service
**File:** `/EC2BACKENDGIT/app/Services/LambdaNotificationService.php`
- Added `notifyAttributeLiked()` method
- Integrates with existing Lambda infrastructure
- Supports both debug and production modes

### 5. API Routes
**File:** `/EC2BACKENDGIT/routes/api.php`
- Added attribute like routes under profile middleware
- Maintains same authentication and authorization as profile likes

### 6. iOS UI Implementation
**Files:**
- `/Calibrr-beRefactor/Calibrr/UI/Profile/ProfileCell.swift`
- `/Calibrr-beRefactor/Calibrr/UI/Profile/ProfilePage.swift`

**UI Features:**
- Heart icon and like counter next to each profile attribute
- Same visual design as main profile like button
- Optimistic UI updates for responsive feel
- Proper animation disabling for instant feedback
- Category mapping for different attribute types

## Technical Details

### Email Notification Logic
1. **First Like**: Always sends email notification
2. **Unlike**: Enables `can_notify_again` flag if only 1 notification sent
3. **Second Like**: Sends notification only if `can_notify_again` is true
4. **Subsequent Likes**: No more notifications (2-email cap enforced)

### Attribute Categories
The system maps profile fields to categories:
- **Personal**: Born, Gender, Sexuality, Relationship, Bio
- **Location**: Currently lives in, Hometown
- **Education**: High School, College, Major, Class Year, Campus, Courses
- **Career**: Career Aspirations, Postgraduate Plans, Occupation
- **Social**: Greek life, Team/Club, Best Friends
- **Politics**: Politics
- **Music**: Favorite Music
- **Entertainment**: Favorite TV, Favorite Games
- **Religion**: Religion
- **Other**: Fallback category

### Database Schema

#### attribute_likes table
```sql
- id (primary key)
- user_id (who liked)
- profile_id (whose attribute was liked)
- category (e.g., "Music", "Politics")
- attribute (e.g., "Hip Hop", "Liberal")
- is_liked (boolean, default true)
- is_deleted (boolean, default false)
- created_at, updated_at
- unique constraint on (user_id, profile_id, category, attribute)
```

#### attribute_like_events table
```sql
- id (primary key)
- user_id (liker)
- profile_id (liked)
- category
- attribute
- notified_at (timestamp)
- last_unliked_at (timestamp)
- notify_count (integer, default 0)
- can_notify_again (boolean, default false)
- created_at, updated_at
- unique constraint on (user_id, profile_id, category, attribute)
```

## API Usage Examples

### Like an Attribute
```bash
POST /api/profile/{userId}/attributes/like
Authorization: Bearer {token}
Content-Type: application/json

{
  "profileId": "123",
  "category": "Music", 
  "attribute": "Hip Hop"
}
```

### Unlike an Attribute
```bash
DELETE /api/profile/{userId}/attributes/like
Authorization: Bearer {token}
Content-Type: application/json

{
  "profileId": "123",
  "category": "Music",
  "attribute": "Hip Hop"
}
```

### Get Like Count
```bash
GET /api/profile/{profileId}/attributes/{category}/{attribute}/likes
Authorization: Bearer {token}
```

## Deployment Instructions

### Backend (EC2)
1. The database migrations and code changes are ready in `/EC2BACKENDGIT/`
2. Push the EC2BACKENDGIT folder to trigger the GitHub deploy action
3. Migrations will run automatically on deployment

### Lambda Function
1. The updated `emailNotificationFinal.js` is ready for deployment
2. Deploy this file to replace the existing Lambda function
3. No environment variable changes needed

### iOS App
1. The UI changes are implemented in the iOS codebase
2. The API integration is stubbed out for now (marked with TODO comments)
3. Full API integration can be completed once backend is deployed

## Testing

### Email Notifications
The existing `testEmailNotificaiton.js` file already includes attribute like testing:
```javascript
// Test 2: Attribute Liked Notification
let attributeLikedResult = await testNotification({
    notificationType: 'attribute_liked',
    recipientUserId: testRecipientUserId,
    senderUserId: testSenderUserId,
    additionalData: {
        category: "Music",
        attribute: "Hip Hop"
    }
})
```

### Backend Testing
1. Use the API endpoints to test like/unlike functionality
2. Verify email notifications are sent correctly
3. Test the 2-email cap logic by liking, unliking, and liking again

### iOS Testing
1. Run the app to see the heart icons next to each profile attribute
2. Tap the hearts to see the optimistic UI updates
3. Once API integration is complete, test full end-to-end functionality

## Notes
- All existing functionality remains unchanged
- The implementation follows the same patterns as the existing profile like system
- Email notifications use the exact same format as requested
- The 2-email cap logic is identical to profile likes
- UI design matches the existing profile like button design
- The system is designed to be scalable and maintainable

## Next Steps
1. Deploy the backend changes by pushing EC2BACKENDGIT
2. Deploy the updated Lambda function
3. Complete the iOS API integration (replace TODO comments with actual API calls)
4. Test the complete end-to-end functionality
5. Monitor email delivery and system performance
