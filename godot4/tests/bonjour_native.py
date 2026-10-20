#!/usr/bin/env python3
"""Test the actual macOS publisher and the iOS Swift browser on macOS.

Uses local Bonjour and a loopback UDP socket, not UI or a simulated parser.
Requires macOS, Xcode command-line tools, and Godot.
"""
import json
import pathlib
import socket
import subprocess
import sys
import tempfile
import time

root = pathlib.Path(__file__).resolve().parents[1]
godot = sys.argv[1] if len(sys.argv) > 1 else "/Applications/Godot.app/Contents/MacOS/Godot"
with tempfile.TemporaryDirectory(prefix="gr-bonjour-") as directory:
    folder = pathlib.Path(directory)
    (folder / "main.swift").write_text('''import Foundation
godotRemoteBonjourStart()
RunLoop.main.run(until: Date(timeIntervalSinceNow: 18))
RemoteBonjour.shared.stop()
''')
    binary = folder / "browser"
    subprocess.run(["xcrun", "swiftc", str(root / "native/ios/BonjourDiscovery.swift"), str(folder / "main.swift"), "-o", str(binary)], check=True)
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as listener:
        listener.bind(("127.0.0.1", 22767))
        listener.settimeout(1)
        browser = subprocess.Popen([str(binary)])
        server = subprocess.Popen([godot, "--headless", "--audio-driver", "Dummy", "--path", str(root), "--script", "res://tests/bonjour_server.gd", "--log-file", str(folder / "server.log")], stdout=subprocess.DEVNULL)
        found = False
        removed = False
        try:
            deadline = time.monotonic() + 17
            while time.monotonic() < deadline:
                try:
                    data, _ = listener.recvfrom(16384)
                except socket.timeout:
                    continue
                snapshot = json.loads(data)
                entries = [s for s in snapshot["servers"] if s["port"] == 24768]
                if entries:
                    found = True
                    assert entries[0]["host"], snapshot
                elif found and server.poll() is not None:
                    removed = True
                    break
            assert server.wait(timeout=3) == 0, "Godot publisher failed"
            assert found, "Browser did not resolve the Godot publisher"
            assert removed, "Stopped server remained in the browser"
            print("PASS: real Bonjour publication, resolution, loopback bridge, and removal")
        finally:
            # The test server normally stops its own dns-sd child after 7 seconds.
            try:
                server.wait(timeout=10)
            except subprocess.TimeoutExpired:
                server.terminate()
                server.wait(timeout=3)
            browser.terminate()
            browser.wait(timeout=3)
