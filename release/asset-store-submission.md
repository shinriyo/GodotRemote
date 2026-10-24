# Godot Asset Store submission

Status: submitted on 2026-10-20. Asset Status: Pending (review queue; not publicly released yet).

Asset: https://store.godotengine.org/asset/shinriyo/shinriyo-remote-server/

Uploaded version ID: 7480. Version: 4.0.0-dev, Unstable / Pending Approval. Minimum and maximum Godot version: 4.7.2.

Validation: ZIP extracted into a temporary project; plugin lifecycle passed and all 27 protocol/input integration checks passed.

Thumbnail: existing independent icon rendered at 1280×720. Evidence: `godot4/build/asset-store/submitted.png`.

## Listing fields

- Publisher: SHINRIYO
- Suggested publisher slug: shinriyo
- Asset name: SHINRIYO Remote Server for Godot 4
- Suggested asset slug: shinriyo-remote-server
- Type: Addon
- License: MIT
- Price: Free
- Version: 4.0.0-dev (initial preview)
- Tested Godot version: 4.7.2 only
- Source: https://github.com/shinriyo/GodotRemote/tree/develop/godot4
- Support: https://shinriyo-remote.netlify.app/index-en.html
- Suggested tags: Tool, Debugging, Mobile, GDScript

## Summary

Stream your running Godot game to a compatible remote client for LAN playtesting, with touch, mouse, keyboard and sensor input.

## Description

SHINRIYO Remote Server is a free MIT-licensed addon for testing a running Godot game through a compatible remote client. The game runs on your development computer; the client displays streamed JPEG frames and sends input back to the game.

Features include touch, mouse and keyboard input, sensor forwarding, configurable frame rate, JPEG quality and image scale, optional connection passwords, and Bonjour discovery for Mac servers and iPhone clients.

### Requirements and installation

Tested with Godot 4.7.2. Other versions have not been verified.

1. Install the addon so that `addons/godot_remote/plugin.cfg` is inside your game project.
2. Open Project > Project Settings > Plugins and enable **Godot Remote 4**.
3. Run or restart your game.
4. Open the compatible client on the same trusted local network, select the running game or enter its LAN address, and connect.

The server starts automatically in debug builds. The default TCP port is 22766. Use different ports for simultaneous game instances.

### Client availability

A compatible client is required. This addon alone does not run or display a game on a phone. The planned paid App Store client is not yet released. Client source and build instructions are available at https://github.com/shinriyo/GodotRemote/tree/develop/godot4 . Older Godot Remote clients use a different protocol and are not compatible.

### Network and licensing

Traffic, including optional passwords, is unencrypted. Use a trusted local network.

This is independent software, not an official Godot Engine product. The original Godot Remote project is by DmitriySalnikov; the included MIT license preserves its attribution. The free addon and source remain available independently of the planned paid client.

## AI disclosure

OpenAI Codex assisted with code and documentation for the Godot 4 implementation. Validation includes automated protocol/input tests, plugin lifecycle tests and manual iPhone testing. Compatibility claims are limited to the tested Godot 4.7.2 version.

## Version changelog

Initial Godot 4 preview: JPEG streaming, remote input and sensor forwarding, debug-build autoload, configurable server settings and Mac-to-iPhone Bonjour discovery.

## Upload files

- ZIP: `godot4/build/asset-store/shinriyo-remote-server-4.0.0-dev.zip`
- File hashes: `godot4/build/asset-store/manifest.json`
- Existing independent icon source: `godot4/remote_icon.svg`

The ZIP contains only `addons/godot_remote/`, including its README and MIT license. Build artifacts are ignored by Git. Confirm the store's media requirements on the authenticated submission form before uploading media.
