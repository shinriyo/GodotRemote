# SHINRIYO Remote for Godot 4 — iOS 4.0.0

Status: historical iOS release and source-provenance notes, updated 2026-11-13. The separate source release is published; the exact source commit of distributed iOS build 4 remains unverified.

## Confirmed public distribution

Apple's public Lookup endpoint for Japan returned version 4.0.0, bundle ID `com.shinriyo.godotremote4`, price JPY 500, and currentVersionReleaseDate `2026-11-13T07:21:32Z` on 2026-11-13.

Store: https://apps.apple.com/jp/app/shinriyo-remote-for-godot-4/id6824852108

## User-facing notes (supported by the published store description)

- Initial iOS release of the independently developed SHINRIYO Remote for Godot 4 client.
- View a Godot game running on your Mac and send touch input from your iPhone over the local network.
- Find the running game on the same LAN or enter its IP address manually.
- Requires the free server addon in the Godot project; the iOS app alone is not sufficient.
- Tested with Godot 4.7.2. Other Godot 4.x versions are unverified.
- One-time paid prebuilt client; no subscriptions or in-app purchases. Source and server addon are MIT licensed.
- This does not replace testing a native exported iOS game for performance or compatibility.

Setup: https://shinriyo-remote.netlify.app/index-en.html
Source: https://github.com/shinriyo/GodotRemote

## Published source release and remaining provenance limit

PR #1 was merged into master at `ff506b023c1eb4f08aad89d11f1fee58ec34955c` on 2026-11-13. The source snapshot tag `godot4-source-2026-11-13` points to that merge commit and its GitHub Release is published (not a draft):

https://github.com/shinriyo/GodotRemote/releases/tag/godot4-source-2026-11-13

This is a source snapshot release, not a claim that the tagged source exactly reproduces the distributed iOS build 4. The local mobile-artifact-manifest.json describes build 3 and commit `37dbcf918a3f1a26a823f64b0f3804ab38447212`; neither it nor the merged source proves build 4's source commit. Do not relabel this snapshot as the exact build 4 source without the missing archive/source evidence.

The Japanese public store listing is confirmed. Authenticated App Store Connect state was not re-read in this documentation pass. These notes do not change store metadata or submit a new version.

## Follow-up provenance check (2026-11-13)

- The retained App Store Connect review log identifies selected build 4 as uploaded 2026-10-23 09:54:32 JST. This is a historical API record, not a fresh authenticated query.
- Review notes describe a Bonjour discovery lifecycle fix preventing delayed callbacks after stopping from restarting service resolution; they do not establish that this was the root cause of the original review crash.
- The retained local xcarchive and App Store IPA both identify build 3. No build 4 archive was found in the checked project, temporary, Documents, or Codex worktree locations.
- Local commit a8b474c was made on October 24 with the lifecycle fix and other next-version work mixed together. It cannot be treated as the exact build 4 source solely on that basis.
- The source snapshot tag and GitHub Release above are now published. Exact build 4 archive/source provenance remains unresolved.
