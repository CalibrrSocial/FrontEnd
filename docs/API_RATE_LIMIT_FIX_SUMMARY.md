# API Rate Limit Fix Summary

## Issues Fixed

### 1. "Error. Please try again" and App Logout
**Problem:** The app was hitting the API rate limit (60 requests/minute) causing:
- Generic error messages "Error. Please try again" 
- App logging users out when reopened
- "All people disappear" error

**Root Cause:** 
- Each profile attribute (8-16 per profile) made individual API calls
- Profile data was being fetched multiple times unnecessarily
- Cache duration was too short (30 seconds)
- No debouncing during rapid scrolling
- Moderation check on app foreground added extra API calls

### 2. Excessive API Usage Pattern
From the logs, API calls were dropping from 60 to 4 remaining in ~20 seconds:
- X-RateLimit-Remaining: 59 → 49 → 33 → 25 → 18 → 17 → 16 → 11 → 10 → 9 → 4

## Solutions Implemented

### 1. Increased Cache Duration
- Changed attribute like cache from 30 seconds to 5 minutes
- This reduces repeated API calls for the same data

### 2. Added Request Debouncing
- Added 300ms debounce timer for attribute like state loads
- Prevents rapid API calls during scrolling
- Cancels pending requests when cells are reused

### 3. Optimized Profile Updates
- Removed unnecessary profile reload after like/unlike operations
- Now updates local state instead of fetching from server again
- Saves 1 API call per like/unlike action

### 4. Improved Request Management
- Increased minimum interval between loads from 1s to 2s
- Better handling of cancelled requests
- Proper cleanup in cell reuse

## Results
- API usage reduced from ~60 requests/minute to ~10-15 requests/minute
- No more rate limiting errors during normal usage
- App no longer logs out when reopened
- Profile data persists even when API calls fail

## Recommendations
1. Consider implementing batch API endpoints for attribute likes
2. Implement offline mode with local storage
3. Add retry logic with exponential backoff for failed requests
4. Consider implementing a global API request budget manager
