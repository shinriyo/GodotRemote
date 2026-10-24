# Mobile store release — 2026-10-20

## Approved release

- Free MIT server addon: Godot Asset Store submission remains Pending Approval.
- Paid clients: one-time JPY 500 purchase, regional conversion; no subscription or IAP.
- Release source: `37dbcf918a3f1a26a823f64b0f3804ab38447212` on develop.
- Keep the existing PR unmerged until Apple review approval.

## Android

- Google Play app `4976036389070439774`, package `org.godotremote.client4`.
- Version 4.0.0 / code 2, production release 1, 173 countries/regions.
- Review submission confirmed on 2026-10-20: console displays changes under review. Post-submission automated checks completed; console confirms the changes are currently under review. Not publicly available yet.
- JPY 500 saved; store listing, screenshots, privacy/data-safety, advertising-ID non-use, age ratings, target audience and support contact completed.
- Signed AAB: `godot4/build/SHINRIYO-Remote-4.0.0-2.aab`.
- SHA-256: `e15d4f8c2422f27fc8ea7f86fb7aa9ac4ffbff267301ef2281690417acb89fe6`.
- min SDK 24, target SDK 36, arm64-v8a and x86_64. Internet/network-state permissions.
- Pixel 6a: signed APK installed with `--no-incremental`; connection screen, opaque About/Licenses and privacy button checked. LAN image transfer and touch forwarding verified visually against demo circle movement/input coordinates.
- Console warnings: optional deobfuscation file and native debug symbols missing; no blocking validation errors at submission.

## Apple

- Official team `R8W4W3W2S5`; bundle `com.shinriyo.godotremote4`; ASC app `6824852108`.
- Version 4.0.0 / build 3 submitted on 2026-10-20 at 18:34 JST. Apple confirms Waiting for Review. Submission ID: `7482594f-882a-415f-aebb-5a4a23355402`. Not publicly available yet.
- Store IPA: `godot4/build/app-store-export/GodotRemote4.ipa`.
- SHA-256: `c231c9064a60f1025bdc0ea464d6c3a4c55f56352a42c3172f4729591ed8fa26`.
- Minimum iOS 15.0; Bonjour service `_godotremote._tcp`.
- Developer and Paid Apps agreements Active. JPY 500, 175 regions, automatic release after approval saved.
- Distribution limited to iPhone/iPad with explicit user authorization; Mac and Vision Pro disabled.
- Description/setup requirements, support URL, copyright, age 4+, content rights, Data Not Collected declaration and privacy policy saved.
- User-authorized private review contact and Mac demo instructions saved; no sign-in required.
- iPhone actual connection screen captured on iOS 26.6. Device Hub screen sharing requires iOS 27, but screenshots work; this does not change app minimum OS.
- iPhone medium-display and iPad 13-inch screenshots uploaded. User explicitly authorized simctl capture after Device Hub became unresponsive. Required metadata validation passed and final Submit for Review succeeded.
- Screenshot-only simulator build uses Metal to avoid an OpenGL black-screen issue under x86_64 simulation. Application UI/source is unchanged; the submitted IPA is unchanged. Simulator images are supplementary and do not establish physical-device performance.

## Signing custody and evidence

- Android upload key: `~/.android/shinriyo-remote/upload.jks`, alias `upload`. Directory 0700; key/password file 0600. No secrets in Git. External secure backup remains outstanding.
- Existing official Apple Distribution identity used; no certificate revoked.
- Local artifact manifest: `godot4/build/mobile-artifact-manifest.json`.
- Store media and console evidence: `godot4/build/store-media/`.
- Public support page: https://shinriyo-remote.netlify.app/index-en.html
- Store badges stay disabled until public download URLs are verified.

## Reviewer ZIP follow-up

- Attached `SHINRIYO-Remote-Review-Demo.zip` to Apple App Review Information after submission and saved updated instructions.
- Contains the minimal Godot demo project, server dependencies, MIT license and English setup/test instructions. Godot 4.7.2 on Mac is required; this is not a standalone Mac executable.
- Headless Godot editor import passed without script/parse errors. The archive contains only eight intended files, no keys or build caches.
- Local ZIP: `godot4/build/SHINRIYO-Remote-Review-Demo.zip`.
