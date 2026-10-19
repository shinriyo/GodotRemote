#!/usr/bin/env python3
"""Offline development signing with an existing profile and Keychain identity.

Does not register Apple resources or request new provisioning profiles.
"""
import argparse
import datetime
import hashlib
import pathlib
import plistlib
import shutil
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--app", type=pathlib.Path, required=True)
parser.add_argument("--profile", type=pathlib.Path, required=True)
parser.add_argument("--identity", required=True, help="SHA-1 fingerprint of an existing codesigning identity")
parser.add_argument("--output", type=pathlib.Path, required=True)
parser.add_argument("--device", required=True, help="Target device UDID, checked against the profile")
args = parser.parse_args()
team = "R8W4W3W2S5"
profile = plistlib.loads(subprocess.check_output(["security", "cms", "-D", "-i", str(args.profile)]))
info = plistlib.loads((args.app / "Info.plist").read_bytes())
bundle = info["CFBundleIdentifier"]
app_id = team + "." + bundle
entitlements = profile["Entitlements"].copy()
allowed = entitlements["application-identifier"]
assert profile["TeamIdentifier"] == [team], "Wrong signing team"
assert allowed == app_id or (allowed.endswith(".*") and app_id.startswith(allowed[:-1])), "Bundle ID not covered by profile"
assert args.device in profile.get("ProvisionedDevices", []), "Device not covered by profile"
assert profile["ExpirationDate"] > datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None), "Expired profile"
assert entitlements.get("get-task-allow") is True, "Use a development profile"
assert args.identity.upper() in [hashlib.sha1(cert).hexdigest().upper() for cert in profile["DeveloperCertificates"]], "Identity not covered by profile"
identities = subprocess.check_output(["security", "find-identity", "-v", "-p", "codesigning"], text=True)
assert args.identity.upper() in identities, "Identity is not valid or its private key is unavailable"
entitlements["application-identifier"] = app_id
if "keychain-access-groups" in entitlements:
    entitlements["keychain-access-groups"] = [group.replace(team + ".*", app_id) for group in entitlements["keychain-access-groups"]]
args.output.mkdir(parents=True, exist_ok=True)
payload = args.output / "Payload"
payload.mkdir(exist_ok=True)
signed_app = payload / args.app.name
if signed_app.exists():
    shutil.rmtree(signed_app)
shutil.copytree(args.app, signed_app, symlinks=True)
shutil.copyfile(args.profile, signed_app / "embedded.mobileprovision")
entitlements_path = args.output / "development-entitlements.plist"
entitlements_path.write_bytes(plistlib.dumps(entitlements))
# The current export links statically. Sign embedded libraries if a later
# Godot template adds them, before sealing the application bundle.
nested = list(signed_app.rglob("*.framework")) + list(signed_app.rglob("*.dylib"))
for item in sorted(nested, key=lambda path: len(path.parts), reverse=True):
    subprocess.run(["codesign", "--force", "--sign", args.identity, "--timestamp=none", str(item)], check=True)
subprocess.run(["codesign", "--force", "--sign", args.identity, "--timestamp=none", "--entitlements", str(entitlements_path), str(signed_app)], check=True)
subprocess.run(["codesign", "--verify", "--deep", "--strict", str(signed_app)], check=True)
ipa = args.output / "GodotRemote4.ipa"
subprocess.run(["ditto", "-c", "-k", "--keepParent", str(payload), str(ipa)], check=True)
print("Signed app:", signed_app)
print("Development IPA:", ipa)
