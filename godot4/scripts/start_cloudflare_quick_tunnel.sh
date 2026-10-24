#!/bin/sh
set -eu

# Start a temporary public HTTPS/WebSocket endpoint for the local Godot server.
# Keep this process running while the game is being tested.

command -v cloudflared >/dev/null 2>&1 || {
	printf '%s\n' 'cloudflared is required: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/' >&2
	exit 1
}

printf '%s\n' 'Starting temporary Cloudflare Tunnel for http://127.0.0.1:22766...' >&2
exec cloudflared tunnel --url http://127.0.0.1:22766
