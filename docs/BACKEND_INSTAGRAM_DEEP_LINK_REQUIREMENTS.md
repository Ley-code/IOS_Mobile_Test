# Backend Requirements: Instagram OAuth Deep Link Support

## Overview

This document outlines the backend changes required to support mobile-first Instagram OAuth flow with deep linking.

## Required Endpoints

### 1. GET /oauth/instagram/callback

**Purpose**: OAuth redirect endpoint that Instagram will call after user authorization.

**Request**:
```
GET /oauth/instagram/callback?code=XYZ&state=ABC
```

**Parameters**:
- `code` (query param): Authorization code from Instagram
- `state` (query param): State parameter for CSRF protection (should be "mobile_app_auth")

**Behavior**:
1. Read `code` and `state` from query parameters
2. Validate `state` parameter (same logic as existing POST endpoint)
3. Reuse existing OAuth completion logic from `POST /api/v1/instagram/callback`:
   - Exchange code with Instagram API
   - Fetch user profile from Instagram Graph API
   - Store Instagram credentials in database
4. Create `session_id`:
   - Temporary identifier (UUID or similar)
   - Expiry: 5-10 minutes
   - Single-use (mark as used after first exchange)
   - Store in Redis or DB, linking to Instagram OAuth result
5. Return `302 Redirect`:
   ```
   Location: vyrlapp://instagram/callback?session_id=<SESSION_ID>
   ```

**Important**:
- Do NOT return HTML
- Do NOT return JSON
- Do NOT expose Instagram access tokens in the URL
- Must be HTTPS (required by Instagram)

**Keep existing endpoint intact**: `POST /api/v1/instagram/callback` must remain unchanged for web app.

---

### 2. POST /api/v1/instagram/finalize

**Purpose**: Exchange temporary session_id for permanent Instagram connection.

**Request**:
```json
POST /api/v1/instagram/finalize
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "session_id": "temporary_session_id_from_deep_link"
}
```

**Response** (200 OK):
```json
{
  "message": "Instagram connected successfully",
  "instagram_username": "johndoe_style"
}
```

**Response** (400 Bad Request):
```json
{
  "error": "Invalid or expired session_id"
}
```

**Behavior**:
1. Validate `session_id`:
   - Check if exists in Redis/DB
   - Check if not expired (5-10 min window)
   - Check if not already used (single-use)
2. Link Instagram OAuth result to authenticated user:
   - Get user from JWT token
   - Associate stored Instagram credentials with user account
   - Mark session_id as used
3. Return success/error response

**Security**:
- Requires authentication (JWT token)
- Session_id must be single-use
- Session_id must expire after 5-10 minutes

---

## Implementation Notes

### Session Storage

The `session_id` should be stored with:
- Instagram OAuth result (access_token, user_id, username, etc.)
- Creation timestamp (for expiry check)
- Used flag (for single-use validation)

Example Redis structure:
```
instagram_session:<session_id> = {
  "instagram_data": {...},
  "created_at": timestamp,
  "used": false
}
```

### Reusing Existing Logic

The GET endpoint should reuse the same OAuth completion logic as the POST endpoint:
- Same Instagram API calls
- Same database storage logic
- Same error handling

The only difference is:
- POST endpoint → returns JSON / web behavior
- GET endpoint → redirects to mobile deep link

---

## Testing

1. Test GET endpoint with valid code/state → should redirect to `vyrlapp://instagram/callback?session_id=...`
2. Test GET endpoint with invalid state → should return error
3. Test POST finalize endpoint with valid session_id → should link Instagram to user
4. Test POST finalize endpoint with expired session_id → should return error
5. Test POST finalize endpoint with already-used session_id → should return error
6. Verify existing POST `/api/v1/instagram/callback` still works for web

---

## Configuration

Update Instagram OAuth redirect URI in Facebook Developer Console:
- Add: `https://vyrl.space/oauth/instagram/callback` (or your backend URL)
- This is the URL Instagram will redirect to after authorization





