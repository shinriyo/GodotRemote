#!/usr/bin/env python3
"""Attach the Bonjour helper to Godot's generated iOS plug-in lifecycle hooks."""
from pathlib import Path
import sys
root = Path(__file__).resolve().parents[1]
export = Path(sys.argv[1])
swift = export / "dummy.swift"
cpp = export / "dummy.cpp"
marker = "// GODOT_REMOTE_BONJOUR"
source = swift.read_text().split(marker)[0]
swift.write_text(source + "\n" + marker + "\n" + (root / "native/ios/BonjourDiscovery.swift").read_text())
source = cpp.read_text()
if marker not in source:
    for name, call in [("initialize", "start"), ("deinitialize", "stop")]:
        hook = "void godot_apple_embedded_plugins_" + name + "() {"
        if source.count(hook) != 1:
            raise SystemExit("Godot iOS template lifecycle changed: " + hook)
        source = source.replace(hook, hook + "\n\tgodot_remote_bonjour_" + call + "();")
    source = marker + '\nextern "C" void godot_remote_bonjour_start();\nextern "C" void godot_remote_bonjour_stop();\n' + source
    cpp.write_text(source)
