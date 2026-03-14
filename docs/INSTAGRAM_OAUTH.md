# Instagram OAuth Integration for Content Creators

This document explains how the Instagram OAuth flow works in the Vyrl mobile app, from the user clicking "Connect Instagram" to the backend storing their Instagram credentials.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [User Flow](#user-flow)
4. [Data Transformation](#data-transformation)
5. [Code Components](#code-components)
6. [API Endpoints](#api-endpoints)
7. [Configuration](#configuration)
8. [Error Handling](#error-handling)
9. [Testing](#testing)

---

## Overview

The Instagram integration allows content creators to link their Instagram accounts during the onboarding flow. This enables:

- Automatic profile import (username, profile picture)
- Display of engagement metrics (followers, posts)
- Verification that the user owns the Instagram account

### Why Instagram OAuth?

Instead of asking users to manually enter their Instagram username (which anyone could fake), OAuth:
- Verifies the user actually owns the account
- Provides secure access to their profile data
- Follows Instagram's terms of service

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MOBILE APP                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐      │
│   │   Social Media   │───▶│  Instagram Auth  │───▶│     AuthBloc     │      │
│   │      Page        │    │      Page        │    │                  │      │
│   └──────────────────┘    └────────┬─────────┘    └────────┬─────────┘      │
│                                     │                        │                │
│                           Opens Browser                      │                │
│                                     ▼                        ▼                │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │                       url_launcher                                 │      │
│   │              (Opens Instagram in external browser)                 │      │
│   └────────────────────────────┬─────────────────────────────────────┘      │
│                                 │                                            │
└─────────────────────────────────┼────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           INSTAGRAM SERVERS                                   │
│                                                                               │
│   1. User logs in to Instagram                                               │
│   2. User authorizes the app                                                 │
│   3. Instagram redirects to redirect_uri with ?code=ABC123                   │
│                                                                               │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
                                  │ User copies code from URL
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MOBILE APP                                       │
│                                                                               │
│   User pastes code ──▶ AuthBloc.ConnectInstagramEvent                        │
│                              │                                               │
│                              ▼                                               │
│                     ConnectInstagramUseCase                                  │
│                              │                                               │
│                              ▼                                               │
│                      AuthRepository                                          │
│                              │                                               │
│                              ▼                                               │
│                  AuthRemoteDataSource                                        │
│                              │                                               │
│                              │ POST /instagram/callback                      │
│                              ▼                                               │
└──────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND SERVER                                      │
│                                                                               │
│   1. Receives code + state from mobile app                                   │
│   2. Exchanges code for access_token with Instagram API                      │
│   3. Fetches user profile from Instagram Graph API                           │
│   4. Stores Instagram credentials in database                                │
│   5. Returns success/failure to mobile app                                   │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## User Flow

### Step-by-Step Journey

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. ONBOARDING - USER SELECTION                                               │
│    User selects "Content Creator" role                                       │
│    ──▶ Navigates to FreelancerOnboardingPage1                               │
└──────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. ONBOARDING - PROFILE INFO                                                 │
│    User enters: name, email, password, about, etc.                          │
│    ──▶ Data stored as partialData map                                       │
│    ──▶ Navigates to FreelancerOnboardingPage2                               │
└──────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. ONBOARDING - SKILLS                                                       │
│    User selects specialities and languages                                   │
│    ──▶ Data combined into FreelancerSignupEntity                            │
│    ──▶ IF Content Creator: Navigate to ContentCreatorSocialMediaPage        │
│    ──▶ IF Other role: Skip to TermsAndConditionsPage                        │
└──────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. SOCIAL MEDIA PAGE (Content Creators Only)                                 │
│    User sees options: Instagram, Facebook, TikTok                           │
│    ──▶ Clicks "Instagram" button                                            │
│    ──▶ Opens InstagramAuthPage                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 5. INSTAGRAM AUTH PAGE                                                       │
│    A. User clicks "Open Instagram" button                                    │
│    B. Browser opens Instagram authorization page                             │
│    C. User logs in and clicks "Allow"                                       │
│    D. Instagram redirects to: redirect_uri?code=ABC123#_                    │
│    E. User copies code from URL bar                                         │
│    F. User pastes code in app and clicks "Connect Account"                  │
│    G. App sends code to backend via AuthBloc                                │
└──────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 6. TERMS & CONDITIONS                                                        │
│    User accepts terms                                                        │
│    ──▶ Triggers account creation API call                                   │
│    ──▶ User is registered and logged in                                     │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Transformation

### Example: Complete User Journey

#### 1. User Selection Page
```dart
// User clicks "Content Creator"
selectedRole = UserRole.contentCreator
```

#### 2. Onboarding Page 1 - User enters their info
```dart
// Data collected in form fields:
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "phoneNumber": "+1234567890",
  "password": "SecurePass123!",
  "about": "Fashion and lifestyle content creator",
  "preferredLanguage": "English",
  "socialMediaLinks": ["@johndoe"],
  "selectedRole": UserRole.contentCreator
}
```

#### 3. Onboarding Page 2 - Skills Selection
```dart
// User selects specialities:
_selectedSpecialities = {"Content Creation", "Photography", "Video Production"}

// User adds languages:
_languages = [
  LanguageEntry(language: "English", level: "Native"),
  LanguageEntry(language: "Spanish", level: "Intermediate")
]

// Combined into FreelancerSignupEntity:
FreelancerSignupEntity(
  firstName: "John",
  lastName: "Doe",
  email: "john@example.com",
  phoneNumber: "+1234567890",
  password: "SecurePass123!",
  about: "Fashion and lifestyle content creator",
  preferredLanguage: "English",
  socialMediaLinks: ["@johndoe"],
  selectedRole: UserRole.contentCreator,
  specialities: ["Content Creation", "Photography", "Video Production"],
  languages: ["English:Native", "Spanish:Intermediate"]
)
```

#### 4. Instagram OAuth Page - User connects Instagram
```dart
// User pastes code from redirect URL:
code = "AQBvkX9J3r_mHw..."

// Event dispatched to AuthBloc:
ConnectInstagramEvent(
  code: "AQBvkX9J3r_mHw...",
  state: "mobile_app_auth"
)

// Request sent to backend:
POST /api/v1/instagram/callback
{
  "code": "AQBvkX9J3r_mHw...",
  "state": "mobile_app_auth"
}
```

#### 5. Backend Processing
```go
// Backend receives code and exchanges it with Instagram:
// POST https://api.instagram.com/oauth/access_token
{
  "client_id": "772563655395430",
  "client_secret": "cf489abb620726129e0131219a2f08b4",
  "grant_type": "authorization_code",
  "redirect_uri": "https://...",
  "code": "AQBvkX9J3r_mHw..."
}

// Instagram returns:
{
  "access_token": "IGQVJYeU...",
  "user_id": 17841405793187218
}

// Backend fetches user profile:
// GET https://graph.instagram.com/17841405793187218?fields=id,username&access_token=IGQVJYeU...
{
  "id": "17841405793187218",
  "username": "johndoe_style"
}

// Backend stores in database:
users_social_accounts:
  user_id: 123
  platform: "instagram"
  platform_user_id: "17841405793187218"
  username: "johndoe_style"
  access_token: "IGQVJYeU..." (encrypted)
```

#### 6. Final Sign-up
```dart
// User accepts terms, API call made:
POST /api/v1/users/signup
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john@example.com",
  "phone_number": "+1234567890",
  "password": "SecurePass123!",
  "about": "Fashion and lifestyle content creator",
  "account_type": "content_creator",
  "skills": ["Content Creation", "Photography", "Video Production"],
  "terms_accepted": true,
  "privacy_accepted": true
}
```

---

## Code Components

### Mobile App Files

| File | Purpose |
|------|---------|
| `instagram_config.dart` | OAuth configuration (client ID, redirect URI) |
| `instagram_auth_page.dart` | UI for the OAuth flow |
| `content_creator_page_socialmedia.dart` | Social media linking page |
| `auth_event.dart` | `ConnectInstagramEvent` definition |
| `auth_state.dart` | `InstagramConnectedState` definition |
| `auth_bloc.dart` | Handles the event, calls use case |
| `connect_instagram_usecase.dart` | Business logic layer |
| `auth_repo.dart` / `auth_repo_impl.dart` | Repository interface & implementation |
| `auth_remote_data_source_impl.dart` | Makes API call to backend |

### Backend Files

| File | Purpose |
|------|---------|
| `instagramHandler.go` | HTTP handler for `/instagram/callback` |
| `instagramService.go` | Token exchange and profile fetching |
| `.env` | Instagram credentials |

---

## API Endpoints

### Mobile App → Backend

```http
POST /api/v1/instagram/callback
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "code": "AQBvkX9J3r_mHw...",
  "state": "mobile_app_auth"
}

Response (200 OK):
{
  "message": "Instagram connected successfully",
  "instagram_username": "johndoe_style"
}

Response (400 Bad Request):
{
  "error": "Invalid authorization code"
}
```

### Backend → Instagram API

```http
# Token Exchange
POST https://api.instagram.com/oauth/access_token
Content-Type: application/x-www-form-urlencoded

client_id=772563655395430
&client_secret=cf489abb620726129e0131219a2f08b4
&grant_type=authorization_code
&redirect_uri=https://...
&code=AQBvkX9J3r_mHw...

Response:
{
  "access_token": "IGQVJYeU...",
  "user_id": 17841405793187218
}
```

```http
# Profile Fetch
GET https://graph.instagram.com/17841405793187218?fields=id,username&access_token=IGQVJYeU...

Response:
{
  "id": "17841405793187218",
  "username": "johndoe_style"
}
```

---

## Configuration

### Instagram Developer Setup

1. Go to [Facebook Developers](https://developers.facebook.com/apps)
2. Create/select your app
3. Add "Instagram Basic Display" product
4. Configure OAuth settings:
   - Valid OAuth Redirect URIs: Add your redirect URI
   - Deauthorize Callback URL: Your backend URL
   - Data Deletion Request URL: Your backend URL
5. Add test users (if in development mode)
6. Copy App ID (Client ID) and App Secret

### Environment Variables

```bash
# Backend .env
INSTAGRAM_CLIENT_ID=772563655395430
INSTAGRAM_CLIENT_SECRET=cf489abb620726129e0131219a2f08b4
INSTAGRAM_REDIRECT_URI=https://your-backend.com/auth/instagram/callback
```

### Mobile App Configuration

Update `lib/core/config/instagram_config.dart`:

```dart
class InstagramConfig {
  static const String clientId = '772563655395430';
  static const String redirectUri = 'https://your-backend.com/auth/instagram/callback';
  // ...
}
```

---

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Invalid code" | Code expired (valid for ~1 hour) | User must re-authorize |
| "redirect_uri mismatch" | URI doesn't match Instagram config | Ensure exact match in both places |
| "App not authorized" | App in development, user not added | Add user as test user in dev console |
| "Network error" | No internet connection | Show retry option |

### Handling in Code

```dart
// BlocListener catches all states
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is InstagramConnectedState) {
      // Success - update UI
    } else if (state is AuthErrorState) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
)
```

---

## Testing

### Manual Testing Steps

1. **Start the backend** with ngrok:
   ```bash
   ngrok http 8080
   # Copy the https URL
   ```

2. **Update configurations**:
   - Add ngrok URL to Instagram Developer Console
   - Update `instagram_config.dart` with ngrok URL

3. **Run the app** and go through onboarding as Content Creator

4. **Click Connect Instagram**:
   - Browser should open
   - Login and click Allow
   - Copy code from redirect URL
   - Paste in app
   - Verify success message

### Checklist

- [ ] Opens Instagram authorization page correctly
- [ ] Redirect URL shows code parameter
- [ ] Code can be pasted (raw or full URL)
- [ ] Success state updates UI
- [ ] Error messages display properly
- [ ] Back navigation works correctly
- [ ] Skip & Continue works without connecting

---

## Troubleshooting

### "WebView assertion failed"
**Cause**: Using webview_flutter on Flutter Web
**Solution**: The current implementation uses url_launcher which works on all platforms

### "Code is invalid"
**Cause**: Instagram codes expire after ~1 hour or after first use
**Solution**: User needs to re-authorize

### "redirect_uri does not match"
**Cause**: The redirect URI in your request doesn't exactly match what's in Instagram Developer Console
**Solution**: Ensure character-for-character match, including trailing slashes

---

## Future Improvements

1. **Automatic code capture**: Use deep links to automatically receive the code
2. **Token refresh**: Implement long-lived token refresh before expiry
3. **Profile data sync**: Periodically sync follower counts and metrics
4. **Facebook & TikTok**: Implement similar flows for other platforms
