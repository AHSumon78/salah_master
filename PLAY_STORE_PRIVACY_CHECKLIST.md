# Salah Master - Play Store Privacy & Permission Checklist

Based on `android/app/src/main/AndroidManifest.xml`.

## Privacy Policy Files

- Bengali: `PRIVACY_POLICY_BN.md`
- English: `PRIVACY_POLICY_EN.md`

Before publishing, replace these placeholders:

- `[আপনার নাম বা কোম্পানির নাম]` / `[Your name or company name]`
- `[আপনার সাপোর্ট ইমেইল]` / `[Your support email]`
- `[আপনার ওয়েবসাইট বা privacy policy URL]`

Google Play requires a public privacy policy URL. Upload the English policy to a public web page and use that URL in Play Console.

## Likely Play Console Data Safety Answers

This is a starting point, not legal advice.

Data collected/shared:

- Approximate location: used for prayer times, nearby mosques, qibla, geofencing, and location-based alarms.
- Precise location: used for accurate prayer times, nearby mosques, qibla, geofencing, and auto silent/DND.
- App activity/preferences: alarms, settings, saved locations, language, theme, and widget preferences are stored locally.
- Audio files: used only when the user chooses custom alarm sounds.

Collection:

- Most app data is stored on device.
- Location coordinates may be sent to third-party services when using map, nearby mosque, direction, Hijri/calendar, or geofence-related features.

Sharing:

- No sale of personal data.
- No advertising network sharing found in the current manifest/dependencies.
- Third-party services may receive request data: Google Play Services Location, OpenStreetMap, Overpass API, Google Maps, and Aladhan API.

Security/deletion:

- User can delete data by deleting entries in the app, clearing app storage, or uninstalling the app.
- App currently uses local storage/Room/SharedPreferences.

## Sensitive Permissions To Justify In Play Console

- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`: prayer time, qibla, maps, nearby mosques.
- `ACCESS_BACKGROUND_LOCATION`: location-based jamaat alarms, mosque geofence, auto silent/DND while app is not open.
- `POST_NOTIFICATIONS`: alarm and pre-alarm notifications.
- `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`: accurate alarm timing.
- `USE_FULL_SCREEN_INTENT`: full-screen alarm popup on lock screen.
- `ACCESS_NOTIFICATION_POLICY`: DND/auto silent mode.
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: improve alarm reliability.
- `READ_MEDIA_AUDIO`, `READ_EXTERNAL_STORAGE`: user-selected alarm sounds.
- `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `FOREGROUND_SERVICE_SPECIAL_USE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: alarm, location/geofence, and sound playback behavior.
- `SYSTEM_ALERT_WINDOW`: only keep this if the app truly needs overlay behavior; Google Play may review this carefully.

## Important Before Release

- Change `applicationId = "com.butterflydevs.salahmaster"` to your real unique package name before Play Store upload.
- Do not keep debug signing for release builds.
- Make sure the in-app location disclosure clearly explains background location before requesting permission.
- If `SYSTEM_ALERT_WINDOW` is not essential, remove it to reduce Play review risk.

