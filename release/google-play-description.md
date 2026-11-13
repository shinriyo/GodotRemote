# Google Play listing draft

Next Android release draft only — not submitted to Play Console (2026-10-28).

Name: SHINRIYO Remote for Godot 4

Short description:
Preview your Godot game on Android and send touch input over your local network.

## Full description

SHINRIYO Remote for Godot 4 is an independent remote playtesting client for Godot developers.

View a game running on your development computer and send touch input back to it over your local network. Your game runs on the computer; this app does not download and execute game code on Android.

REQUIRED SETUP

You need a computer running Godot, the free SHINRIYO Remote Server for Godot 4 server addon installed in each game project, and a local network that allows the computer and Android device to communicate. Tested server version: Godot 4.7.2. Other Godot versions have not been verified.

1. Download the free addon ZIP: https://store.godotengine.org/asset/shinriyo/shinriyo-remote-server/
   Extract addons/godot_remote into your game project. The current addon is 4.0.0-dev (Unstable), supporting Godot 4.7.2–4.7.2.
2. Enable SHINRIYO Remote Server for Godot 4 under Project > Project Settings > Plugins.
3. Run or restart your game on the computer.
4. Open this Android app, enter the computer's LAN IP address and port (default: 22766), and press Connect.

Android connections currently use manual address entry. Automatic Mac-to-iPhone discovery is not an Android feature.

IMPORTANT

Installing this app alone is not sufficient: the game-side addon is required. Remote playtesting does not replace testing a native Android export or measuring performance on the device. Network traffic, including any optional connection password, is unencrypted; use a trusted local network.

ONE-TIME PURCHASE

The store app is a paid, ready-to-install build. The source and server addon are freely available under the MIT license. Revenue supports development and maintenance of this app.

This is an independent SHINRIYO product, not an official product of Godot Engine or the original Godot Remote author. Purchases are not donations to those parties. Credits and license notices are available in About / Licenses.

Setup and support:
https://shinriyo-remote.netlify.app/index-en.html

Source:
https://github.com/shinriyo/GodotRemote/tree/develop/godot4

Privacy:
https://shinriyo-remote.netlify.app/privacy-en.html
