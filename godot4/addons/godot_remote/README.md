# SHINRIYO Remote server addon for Godot 4

Stream a running Godot game's viewport to a compatible remote client and receive touch, mouse, keyboard and sensor input. Tested with Godot 4.7.2 only. Older Godot Remote clients are not compatible.

## Install

1. Copy this entire folder into your game's `addons/godot_remote/` directory. Keep your existing `project.godot`.
2. In the Godot editor, open **Project > Project Settings > Plugins** and enable **Godot Remote 4** (the plugin's current display name).
3. Run or restart your game. The plugin registers the `GodotRemote` autoload automatically; no scene or script changes are needed.
4. Open the compatible client, allow Local Network access when requested, select the running game and press **Connect**. Bonjour discovery currently supports Mac servers and iPhone clients on the same LAN. For external access, enter a public hostname such as `your-name.duckdns.org` and the forwarded port manually.

A client application is required. This addon alone does not display your game on a phone. The planned paid App Store client is not yet released; client source and build instructions are available in the repository.

Default TCP port: `22766`. Advanced project settings: `godot_remote/server`. Use different ports for simultaneous game instances. The server starts automatically only in debug builds. Traffic is unencrypted; prefer a VPN for external access and never expose it without a strong password and router/firewall restrictions.

## Set a connection password

1. In the game project on your Mac, enable **Godot Remote 4** under **Project > Project Settings > Plugins**.
2. Open the **General** tab, enable **Advanced Settings**, and search for `godot_remote/server`.
3. Set **Password** (`godot_remote/server/password`) to your chosen password.
4. Stop and restart the game so the server reads the new setting.
5. Enter the same password in the client's **Password** field before pressing **Connect**.

The default is empty, which requires no password. To remove a password, clear the server setting, restart the game, and clear the client field too. The client does not save passwords across app launches. Passwords are sent in plaintext; use a trusted local network.

## Update or remove

Stop the game before replacing the addon folder. Updates are manual. To remove the addon, disable the plugin first, then delete its folder.

## Troubleshooting

- Plugin missing: check that `addons/godot_remote/plugin.cfg` exists in the target game. Do not install the old Godot 3 addon from the repository root.
- No game discovered: check that the plugin is enabled, the game is running, Local Network permission is granted and both devices can communicate on the LAN.
- Cannot listen: another game may be using the same port.
- Manual connection: use the Mac's LAN address, not `127.0.0.1` on the phone.

## License and source

MIT; see the included `LICENSE`. Original Godot Remote copyright: DmitriySalnikov. This is an independent Godot 4 implementation in the fork, not an official Godot Engine product.

Source and detailed setup: https://github.com/shinriyo/GodotRemote/tree/develop/godot4
