#!/usr/bin/env python3
"""Deterministically export the *complete* literal scene in ../src/Build.luau.

Python 3.9+, standard library only. No Luau runtime, Roblox, network, or packages.
Run: python packs/ui/studs-ui/tools/build_export.py [--check]
Build.luau is authoritative; this helper never rewrites it or executes its code.
The intentionally restricted literal-table reader rejects expressions/functions.
XML and attribute encodings: https://dom.rojo.space/xml.html and /attributes.html.
An offline export is NOT a claim that Studio import/play has been tested.
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import math
from pathlib import Path
import re
import struct
import sys
import xml.etree.ElementTree as ET

PACK = Path(__file__).resolve().parents[1]
SOURCE = PACK / "src" / "Build.luau"
EXPORT = PACK / "exports" / "studs-ui.rbxmx"
PANELS = {"DailyRewards", "Shop", "Rebirth", "Index", "SeasonPass",
          "Upgrades", "StockShop", "Settings", "StarterPack"}
ENUMS = {
    "Font": {"GothamBlack": 20},
    "ZIndexBehavior": {"Global": 0, "Sibling": 1},
    "ApplyStrokeMode": {"Contextual": 0, "Border": 1},
    "LineJoinMode": {"Round": 0, "Bevel": 1, "Miter": 2},
    "TextXAlignment": {"Left": 0, "Right": 1, "Center": 2},
    "TextYAlignment": {"Top": 0, "Center": 1, "Bottom": 2},
    "ScrollingDirection": {"X": 1, "Y": 2, "XY": 4},
    "ElasticBehavior": {"WhenScrollable": 0, "Always": 1, "Never": 2},
    "SortOrder": {"Name": 0, "Custom": 1, "LayoutOrder": 2},
    "ScaleType": {"Stretch": 0, "Slice": 1, "Tile": 2, "Fit": 3, "Crop": 4},
}
GUI_CLASSES = {"Frame", "TextLabel", "TextButton", "ScrollingFrame", "ImageLabel"}
CLASSES = GUI_CLASSES | {"ScreenGui", "UIScale", "UIStroke", "UIGradient",
                         "UICorner", "UIGridLayout"}
INT_PROPERTIES = {"BorderSizePixel", "DisplayOrder", "ZIndex", "LayoutOrder",
                  "ScrollBarThickness", "FillDirectionMaxCells"}


class LiteralReader:
    """Read array-only Luau literals (JSON-compatible strings, finite numbers).

    Not a Lua evaluator: the only accepted tokens are braces, commas, strings,
    booleans, numbers, whitespace, and single-line comments.
    """
    def __init__(self, source: str):
        self.source, self.offset = source, 0

    def whitespace(self):
        while self.offset < len(self.source):
            if self.source[self.offset].isspace():
                self.offset += 1
            elif self.source.startswith("--", self.offset):
                end = self.source.find("\n", self.offset)
                self.offset = len(self.source) if end < 0 else end + 1
            else:
                break

    def read(self):
        self.whitespace()
        if self.offset >= len(self.source):
            raise ValueError("Unexpected end of literal scene")
        if self.source[self.offset] == "{":
            self.offset += 1
            result = []
            self.whitespace()
            while self.source[self.offset:self.offset + 1] != "}":
                result.append(self.read())
                self.whitespace()
                char = self.source[self.offset:self.offset + 1]
                if char == ",":
                    self.offset += 1
                    self.whitespace()
                elif char != "}":
                    raise ValueError(f"Expected comma at offset {self.offset}")
            self.offset += 1
            return result
        try:
            value, end = json.JSONDecoder().raw_decode(self.source, self.offset)
        except json.JSONDecodeError as error:
            raise ValueError(f"Non-literal token at offset {self.offset}") from error
        if value is None or not isinstance(value, (str, bool, int, float)):
            raise ValueError("Only strings, booleans, numbers and array tables are supported")
        if isinstance(value, (int, float)) and not math.isfinite(value):
            raise ValueError("Non-finite numbers are not supported")
        self.offset = end
        return value


def pairs(values):
    if not isinstance(values, list) or len(values) % 2:
        raise ValueError("Expected alternating name/value pairs")
    result = {}
    for name, value in zip(values[::2], values[1::2]):
        if not isinstance(name, str) or name in result:
            raise ValueError(f"Invalid or duplicate property/attribute: {name!r}")
        result[name] = value
    return result


def read_source(path=SOURCE):
    source = path.read_text(encoding="utf-8")
    declaration = re.search(r"local SCENE(?::\s*\{any\})?\s*=\s*", source)
    if not declaration:
        raise ValueError("Missing literal SCENE declaration")
    begin = declaration.end()
    reader = LiteralReader(source[begin:source.index("-- END SCENE", begin)])
    scene = reader.read()
    reader.whitespace()
    if reader.offset != len(reader.source):
        raise ValueError("Unexpected content following SCENE")
    config_match = re.search(r"local CONFIG = \{(.*?)\n\}", source, re.S)
    if not config_match:
        raise ValueError("Missing CONFIG table")
    config = {}
    for line in config_match[1].splitlines():
        line = line.strip()
        if not line or line.startswith("--"):
            continue
        match = re.fullmatch(r"(\w+)\s*=\s*(.*?),?", line)
        if not match:
            raise ValueError(f"Unsupported CONFIG entry: {line}")
        config[match[1]] = json.loads(match[2].rstrip(","))
    expected = {"OpenSoundId", "CloseSoundId", "HoverSoundId", "ClickSoundId",
                "SoundVolume", "ReducedMotion"}
    if set(config) != expected:
        raise ValueError("CONFIG contract changed; review export defaults")
    if any(not isinstance(config[key], str) for key in expected if key.endswith("SoundId")):
        raise ValueError("Sound IDs must be strings (empty is silent)")
    if type(config["ReducedMotion"]) is not bool or not isinstance(config["SoundVolume"], (int, float)) or not 0 <= config["SoundVolume"] <= 1:
        raise ValueError("Expected boolean ReducedMotion and SoundVolume in [0, 1]")
    match = re.search(r"local CONTROLLER_SOURCE = \[(=*)\[(.*?)\]\1\]", source, re.S)
    if not match:
        raise ValueError("Embedded Controller source not found")
    controller = match[2]
    # Lua long string literals discard exactly one opening newline.
    if controller.startswith("\n"):
        controller = controller[1:]
    validate_scene(scene, controller)
    return scene, config, controller


def validate_scene(scene, controller):
    if not scene or scene[0][:3] != ["ScreenGui", "StudsUI", 0]:
        raise ValueError("Expected a single StudsUI ScreenGui root")
    for index, record in enumerate(scene, 1):
        if len(record) != 5:
            raise ValueError(f"Malformed scene record {index}")
        cls, name, parent, properties, attributes = record
        if cls not in CLASSES or not isinstance(name, str):
            raise ValueError(f"Unsupported class/name at record {index}")
        if not isinstance(parent, int) or not 0 <= parent < index or (index > 1 and parent == 0):
            raise ValueError(f"Invalid parent at record {index}")
        props, attrs = pairs(properties), pairs(attributes)
        if cls == "TextButton" and not isinstance(attrs.get("StudsAction"), str):
            raise ValueError(f"Button has no action: {name}")
        if attrs.get("StudsAction") in {"OpenPanel", "ClosePanel"} and attrs.get("StudsTarget") not in PANELS:
            raise ValueError(f"Invalid panel target: {name}")
        if any(isinstance(value, list) for value in attrs.values()):
            raise ValueError("Only scalar attributes are supported")
    if pairs(scene[0][3]).get("ResetOnSpawn") is not False:
        raise ValueError("ResetOnSpawn must be false")
    canvas = next(i for i, row in enumerate(scene, 1) if row[1] == "DesignCanvas" and row[2] == 1)
    modals = next(i for i, row in enumerate(scene, 1) if row[1] == "Modals" and row[2] == canvas)
    panels = [row for row in scene if row[2] == modals]
    if len(panels) != 9 or {row[1] for row in panels} != PANELS:
        raise ValueError("Modals must have exactly the nine contracted panel Frames")
    if any(row[0] != "Frame" or pairs(row[3]).get("Visible") is not False for row in panels):
        raise ValueError("All panels must be initially hidden Frames")
    for panel in PANELS:
        for action in ("OpenPanel", "ClosePanel"):
            if not any(pairs(row[4]).get("StudsAction") == action and
                       pairs(row[4]).get("StudsTarget") == panel for row in scene):
                raise ValueError(f"Missing {action} control for {panel}")
    if len(controller) < 10000 or "script.Parent" not in controller:
        raise ValueError("Missing or truncated embedded Controller")


def defaults(cls):
    result = {}
    if cls in GUI_CLASSES:
        result.update(BorderSizePixel=0, BackgroundTransparency=1, Active=False)
    if cls in {"TextLabel", "TextButton"}:
        result.update(Font=["Enum", "Font", "GothamBlack"], TextColor3=["Color3", 255, 255, 255],
                      TextStrokeTransparency=1, TextWrapped=True, TextScaled=False,
                      RichText=False, Text="")
    return result


def encode_attributes(attributes):
    def string(value):
        data = value.encode("utf-8")
        return struct.pack("<I", len(data)) + data
    data = bytearray(struct.pack("<I", len(attributes)))
    for name, value in sorted(attributes.items()):
        data.extend(string(name))
        if isinstance(value, bool):
            data.extend(b"\x03" + bytes([value]))
        elif isinstance(value, str):
            data.extend(b"\x02" + string(value))
        elif isinstance(value, (int, float)):
            data.extend(b"\x06" + struct.pack("<d", value))
        else:
            raise ValueError(f"Unsupported attribute: {name}")
    return base64.b64encode(data).decode("ascii")


def decode_attributes(encoded):
    data = base64.b64decode(encoded)
    offset = 0
    def take(fmt):
        nonlocal offset
        result = struct.unpack_from(fmt, data, offset)[0]
        offset += struct.calcsize(fmt)
        return result
    def string():
        nonlocal offset
        length = take("<I")
        result = data[offset:offset + length].decode("utf-8")
        offset += length
        return result
    result = {}
    for _ in range(take("<I")):
        name, kind = string(), take("<B")
        if kind == 2:
            value = string()
        elif kind == 3:
            value = bool(take("<B"))
        elif kind == 6:
            value = take("<d")
        else:
            raise ValueError(f"Unknown attribute tag: {kind}")
        result[name] = value
    if offset != len(data):
        raise ValueError("Trailing attribute bytes")
    return result


def number(value):
    return format(value, ".10g")


def write_property(parent, name, value):
    def element(tag, contents=None):
        node = ET.SubElement(parent, tag, name=name)
        if contents is not None:
            node.text = contents
        return node
    if isinstance(value, list):
        kind, *components = value
        if kind == "Enum":
            element("token", str(ENUMS[components[0]][components[1]]))
        elif kind in {"UDim2", "UDim", "Vector2", "Color3"}:
            tags = {"UDim2": ("XS", "XO", "YS", "YO"), "UDim": ("S", "O"),
                    "Vector2": ("X", "Y"), "Color3": ("R", "G", "B")}[kind]
            if len(components) != len(tags):
                raise ValueError(f"Invalid {kind}: {value}")
            result = element(kind)
            for tag, component in zip(tags, components):
                if tag in {"XO", "YO", "O"} and int(component) != component:
                    raise ValueError(f"UDim offsets must be integers: {name} {value}")
                ET.SubElement(result, tag).text = number(component / 255 if kind == "Color3" else component)
        elif kind == "NumberSequence":
            element("NumberSequence", " ".join(map(number, components)) + " ")
        elif kind == "ColorSequence":
            if len(components) % 4:
                raise ValueError("Malformed ColorSequence")
            keys = []
            for i in range(0, len(components), 4):
                time, red, green, blue = components[i:i+4]
                keys.extend([time, red/255, green/255, blue/255, 0])
            element("ColorSequence", " ".join(map(number, keys)) + " ")
        else:
            raise ValueError(f"Unsupported typed value: {kind}")
    elif isinstance(value, bool):
        element("bool", str(value).lower())
    elif isinstance(value, str):
        if name == "Image":
            content = element("Content")
            ET.SubElement(content, "url").text = value
        else:
            element("ProtectedString" if name == "Source" else "string", value)
    elif isinstance(value, (int, float)):
        element("int" if name in INT_PROPERTIES else "float", number(value))
    else:
        raise ValueError(f"Unsupported property {name}: {value!r}")


def export_bytes(scene, config, controller):
    root = ET.Element("roblox", version="4")
    ET.SubElement(root, "External").text = "null"
    ET.SubElement(root, "External").text = "nil"
    items = {0: root}
    for index, (cls, name, parent, properties, attributes) in enumerate(scene, 1):
        item = ET.SubElement(items[parent], "Item", {"class": cls, "referent": f"RBX{index}"})
        items[index] = item
        props = ET.SubElement(item, "Properties")
        values = defaults(cls)
        values.update(pairs(properties))
        values["Name"] = name
        for key, value in sorted(values.items()):
            write_property(props, key, value)
        attrs = pairs(attributes)
        if index == 1:
            attrs.update(config)
        if attrs:
            ET.SubElement(props, "BinaryString", name="AttributesSerialize").text = encode_attributes(attrs)
    item = ET.SubElement(items[1], "Item", {"class": "LocalScript", "referent": f"RBX{len(scene)+1}"})
    props = ET.SubElement(item, "Properties")
    write_property(props, "Name", "Controller")
    write_property(props, "Disabled", False)
    write_property(props, "Source", controller)
    ET.indent(root, space="  ")
    data = ET.tostring(root, encoding="utf-8", xml_declaration=True) + b"\n"
    validate_export(data, scene, config, controller)
    return data


def validate_export(data, scene, config, controller):
    """Reparse XML; verify every parent, property, attribute and script source."""
    parsed = ET.fromstring(data)
    if parsed.tag != "roblox" or parsed.get("version") != "4" or len(parsed.findall("Item")) != 1:
        raise ValueError("Malformed model root")
    items = {item.get("referent"): item for item in parsed.iter("Item")}
    if len(items) != len(scene) + 1:
        raise ValueError("Missing/duplicate referents")
    for i, record in enumerate(scene, 1):
        cls, name, parent, properties, attributes = record
        item = items[f"RBX{i}"]
        if item.get("class") != cls or item.findtext("Properties/string[@name='Name']") != name:
            raise ValueError(f"Instance identity mismatch: {name}")
        if parent and item not in list(items[f"RBX{parent}"]):
            raise ValueError(f"Parent mismatch: {name}")
        expected_props = defaults(cls)
        expected_props.update(pairs(properties))
        expected_props["Name"] = name
        actual_props = {p.get("name"): p for p in item.find("Properties")}
        for prop, value in expected_props.items():
            temporary = ET.Element("Properties")
            write_property(temporary, prop, value)
            # Ignore formatting-only whitespace introduced by indent().
            def canonical(element):
                return element.tag, element.attrib, (element.text or "").strip(), [canonical(c) for c in element]
            if prop not in actual_props or canonical(actual_props[prop]) != canonical(temporary[0]):
                raise ValueError(f"Property mismatch: {name}.{prop}")
        attrs = pairs(attributes)
        if i == 1:
            attrs.update(config)
        actual_attrs = decode_attributes(actual_props["AttributesSerialize"].text) if "AttributesSerialize" in actual_props else {}
        if attrs != actual_attrs:
            raise ValueError(f"Attribute mismatch: {name}")
    scripts = [item for item in items.values() if item.get("class") == "LocalScript"]
    if len(scripts) != 1 or scripts[0] not in list(items["RBX1"]):
        raise ValueError("Controller must be the sole direct LocalScript")
    if scripts[0].findtext("Properties/ProtectedString[@name='Source']") != controller:
        raise ValueError("Controller source did not round-trip byte-for-byte")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Validate and compare; do not write")
    args = parser.parse_args()
    scene, config, controller = read_source()
    data = export_bytes(scene, config, controller)
    if args.check:
        if not EXPORT.is_file() or EXPORT.read_bytes() != data:
            print("Export missing or stale; run this helper without --check.", file=sys.stderr)
            return 1
    else:
        EXPORT.parent.mkdir(parents=True, exist_ok=True)
        EXPORT.write_bytes(data)
    print(f"{'Checked' if args.check else 'Exported'} {len(scene)+1} instances, 9 panels; "
          f"Controller {len(controller.encode('utf-8'))} bytes preserved.")
    print(f"SHA256 {hashlib.sha256(data).hexdigest()}  {EXPORT.name}")
    print("Offline XML/contract checks only; Studio import, rendering and Play still need testing.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
