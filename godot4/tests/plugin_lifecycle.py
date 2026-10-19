#!/usr/bin/env python3
"""Verify an installed plug-in still starts after the editor has exited."""
import pathlib
import shutil
import subprocess
import sys
import tempfile

source = pathlib.Path(__file__).resolve().parents[1]
godot = sys.argv[1] if len(sys.argv) > 1 else "godot"
with tempfile.TemporaryDirectory(prefix="godot-remote4-plugin-") as directory:
    project = pathlib.Path(directory)
    shutil.copytree(source / "addons", project / "addons")
    (project / "project.godot").write_text('''config_version=5
[application]
config/name="Godot Remote Plugin Test"
run/main_scene="res://test.tscn"
[editor_plugins]
enabled=PackedStringArray("res://addons/godot_remote/plugin.cfg")
[godot_remote]
server/port=24767
[rendering]
renderer/rendering_method="gl_compatibility"
''')
    (project / "test.tscn").write_text('''[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://check.gd" id="1"]
[node name="Test" type="Node"]
script = ExtResource("1")
''')
    (project / "check.gd").write_text('''extends Node
func _ready() -> void:
 var remote = get_node_or_null("/root/GodotRemote")
 if remote == null or not remote.listener.is_listening():
  push_error("FAIL: plugin autoload is not listening")
  get_tree().quit(1)
  return
 print("PASS: plugin registers and starts server autoload")
 get_tree().quit(0)
''')
    base = [godot, "--headless", "--audio-driver", "Dummy", "--path", directory,
            "--log-file", str(project / "test.log")]
    for args in (["--editor", "--import", "--quit"], []):
        result = subprocess.run(base + args, capture_output=True, text=True, timeout=30)
        output = result.stdout + result.stderr
        if result.returncode or "ERROR:" in output:
            print(output)
            sys.exit(1)
    assert "PASS: plugin registers" in output, output
    print("PASS: plugin registration survives editor shutdown and starts the server")
