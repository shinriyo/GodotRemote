extends RefCounted

const ORIGINAL_LICENSE := """MIT License

Copyright (c) 2020-2022 DmitriySalnikov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the Software), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, andor sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."""

static func full_text() -> String:
	var text := "Tested with Godot 4.7.2. Other Godot 4.x versions have not been verified.\n\nIndependent software by SHINRIYO. Not affiliated with or endorsed by Godot Engine or the original Godot Remote author.\n\nOriginal Godot Remote — DmitriySalnikov\nhttps://github.com/DmitriySalnikov/GodotRemote\n\n" + ORIGINAL_LICENSE
	text += "\n\nGodot Engine\nhttps://godotengine.org/license\nSource: https://github.com/godotengine/godot\nVersion: " + Engine.get_version_info().string + "\n\n" + Engine.get_license_text()
	text += "\n\nThird-party component notices\n"
	for component in Engine.get_copyright_info():
		text += "\n" + component.name + "\n"
		for part in component.parts:
			text += "Files: " + ", ".join(part.files) + "\n"
			text += "\n".join(part.copyright) + "\nLicense: " + part.license + "\n"
	var licenses := Engine.get_license_info()
	for name in licenses:
		text += "\n\n" + name + "\n" + licenses[name]
	return text
