#!/usr/bin/env python3
"""Read-only Studs UI draft checks. Standard library only; never executes Luau.

Source diagnostics use a small comment/string scanner, NOT a Luau parser.
An exit code of zero means no definite offline failures, not Studio readiness.
"""

from __future__ import annotations

import argparse
import base64
from dataclasses import dataclass
import json
from pathlib import Path, PureWindowsPath
import re
import sys
import xml.etree.ElementTree as ET


PANELS = (
    "DailyRewards", "Shop", "Rebirth", "Index", "SeasonPass", "Upgrades",
    "StockShop", "Settings", "StarterPack",
)
REQUIRED = ("pack.json", "README.md", "CHANGELOG.md", "CREDITS.md", "src/Build.luau")
SOUNDS = ("OpenSoundId", "CloseSoundId", "HoverSoundId", "ClickSoundId")
MEDIA = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".svg", ".psd",
         ".mp4", ".mov", ".wav", ".ogg", ".mp3", ".pdf"}
OPAQUE = {".zip", ".7z", ".rar", ".rbxm", ".rbxl"}


@dataclass(frozen=True)
class Finding:
    level: str
    code: str
    message: str


@dataclass(frozen=True)
class Token:
    kind: str
    value: str
    start: int
    end: int


LONG_BRACKET = re.compile(r"\[(=*)\[")
WORD_TOKEN = re.compile(r"[A-Za-z_][A-Za-z_0-9]*|\d+(?:\.\d+)?")


def lex_source(source: str) -> list[Token]:
    """Skip Luau comments; distinguish strings from code without parsing Luau.

    Supports long-bracket delimiters and escaped quoted strings. Backtick
    strings are opaque: interpolated expressions are NOT analyzed.
    """
    tokens = []
    i = 0
    while i < len(source):
        if source[i].isspace():
            i += 1
            continue
        start = i
        comment = source.startswith("--", i)
        if comment:
            i += 2
        long = LONG_BRACKET.match(source, i)
        if long:
            opening = len(long.group())
            closing = "]" + long.group(1) + "]"
            end = source.find(closing, i + opening)
            stop = len(source) if end < 0 else end
            value = source[i + opening:stop]
            i = len(source) if end < 0 else end + len(closing)
            if not comment:
                tokens.append(Token("string", value, start, i))
            continue
        if comment:
            end = source.find("\n", i)
            i = len(source) if end < 0 else end + 1
            continue
        if source[i] in "\"'`":
            quote = source[i]
            i += 1
            value_start = i
            while i < len(source):
                if source[i] == "\\":
                    i += 2
                elif source[i] == quote:
                    break
                else:
                    i += 1
            # Escape sequences deliberately remain undecoded; this is not Luau.
            tokens.append(Token("string", source[value_start:i], start, min(i + 1, len(source))))
            i += 1
            continue
        word = WORD_TOKEN.match(source, i)
        if word:
            value = word.group()
            i += len(value)
            tokens.append(Token("word", value, start, i))
        else:
            i += 1
            tokens.append(Token("symbol", source[start:i], start, i))
    return tokens


def code_only(source: str, tokens: list[Token]) -> str:
    chars = ["\n" if char == "\n" else " " for char in source]
    for token in tokens:
        if token.kind != "string":
            chars[token.start:token.end] = source[token.start:token.end]
    return "".join(chars)


class NoDoctype(ET.TreeBuilder):
    def doctype(self, name, pubid, system):
        raise ValueError("DTD declarations are not supported in model exports")


class Validator:
    def __init__(self, pack: Path):
        self.pack = pack.resolve()
        self.findings: list[Finding] = []

    def add(self, level: str, code: str, message: str) -> None:
        self.findings.append(Finding(level, code, message))

    def path(self, relative: str, label: str) -> Path | None:
        """Validate portable manifest paths, including Windows paths on POSIX."""
        if not isinstance(relative, str) or not relative.strip():
            self.add("FAIL", "path.invalid", f"{label}: expected a nonempty relative file path.")
            return None
        portable = relative.replace("\\", "/")
        win = PureWindowsPath(relative)
        if (portable.startswith("/") or win.drive or ":" in portable or
                "\x00" in portable or ".." in portable.split("/")):
            self.add("FAIL", "path.escape", f"{label}: absolute, traversal, or drive-qualified path rejected.")
            return None
        try:
            target = (self.pack / portable).resolve()
            if not target.is_relative_to(self.pack):
                self.add("FAIL", "path.escape", f"{label}: resolved path escapes the pack (including links).")
                return None
        except (OSError, ValueError, RuntimeError):
            self.add("FAIL", "path.invalid", f"{label}: path cannot be resolved safely.")
            return None
        return target

    def read(self, path: Path, label: str) -> str | None:
        try:
            return path.read_text(encoding="utf-8-sig")
        except (OSError, UnicodeError):
            self.add("FAIL", "file.read", f"{label}: cannot read as UTF-8 text.")
            return None

    def reference(self, value, label: str) -> None:
        if value is None:
            return
        if isinstance(value, dict):
            for key, child in value.items():
                self.reference(child, f"{label}.{key}")
        elif isinstance(value, list):
            for index, child in enumerate(value):
                self.reference(child, f"{label}[{index}]")
        elif isinstance(value, str):
            target = self.path(value, label)
            if target is not None:
                if target.is_file():
                    self.add("PASS", "path.exists", f"{label}: confined referenced file exists.")
                else:
                    self.add("FAIL", "path.missing", f"{label}: referenced file is missing or is not a file.")
        else:
            self.add("FAIL", "path.type", f"{label}: expected path, collection of paths, or null.")

    def metadata(self, path: Path) -> None:
        raw = self.read(path, "pack.json")
        if raw is None:
            return
        def unique_object(pairs):
            result = {}
            for key, value in pairs:
                if key in result:
                    raise ValueError("duplicate key")
                result[key] = value
            return result
        def invalid_constant(value):
            raise ValueError("non-JSON numeric constant")
        try:
            data = json.loads(raw, object_pairs_hook=unique_object, parse_constant=invalid_constant)
        except (ValueError, RecursionError):
            self.add("FAIL", "json.invalid", "pack.json: invalid JSON, duplicate key, or non-JSON constant.")
            return
        if not isinstance(data, dict):
            self.add("FAIL", "metadata.type", "pack.json must be an object.")
            return
        self.add("PASS", "json.valid", "pack.json is valid, unambiguous JSON.")
        for key, expected in (("id", "studs-ui"), ("category", "ui"),
                              ("status", "draft"), ("license", "UNLICENSED")):
            if data.get(key) != expected:
                self.add("FAIL", f"metadata.{key}", f"pack.json {key} must be {expected!r} for this draft contract.")
            else:
                self.add("PASS", f"metadata.{key}", f"pack.json {key} matches the draft contract.")
        for key in ("name", "description", "version", "author"):
            value = data.get(key)
            if not isinstance(value, str) or (key != "author" and not value.strip()):
                self.add("FAIL", "metadata.field", f"pack.json {key}: required string is missing/invalid.")
            elif "replace with" in value.lower() or "replace-with" in value.lower():
                self.add("FAIL", "metadata.placeholder", f"pack.json {key}: template placeholder remains.")
        version = data.get("version")
        if isinstance(version, str) and not re.fullmatch(r"\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.+-]+)?", version):
            self.add("FAIL", "metadata.version", "pack.json version must have an x.y.z version shape.")
        for key in ("dependencies", "tags"):
            if not isinstance(data.get(key), list):
                self.add("FAIL", "metadata.field", f"pack.json {key} must be an array.")
        if isinstance(data.get("tags"), list) and not all(isinstance(x, str) for x in data["tags"]):
            self.add("FAIL", "metadata.tags", "pack.json tags must contain strings.")
        if data.get("dependencies"):
            self.add("WARN", "metadata.dependencies", "Declared dependencies need manual review; this tool does not fetch them.")
        files = data.get("files")
        if not isinstance(files, dict):
            self.add("FAIL", "metadata.files", "pack.json files must be an object.")
        else:
            for key in ("model", "demo", "previews"):
                if key not in files:
                    self.add("FAIL", "metadata.files", f"pack.json files.{key} is required by the template.")
            for key in ("model", "demo"):
                if key in files and files[key] is not None and not isinstance(files[key], str):
                    self.add("FAIL", "metadata.files", f"pack.json files.{key} must be a path or null.")
            if "previews" in files and (not isinstance(files["previews"], list) or
                    not all(isinstance(x, str) for x in files["previews"])):
                self.add("FAIL", "metadata.files", "pack.json files.previews must be an array of paths.")
            self.reference(files, "files")
        self.add("WARN", "release.unlicensed", "Draft validation is not a license grant or release approval; UNLICENSED must not be published as licensed content.")

    def source(self, source: str, label: str, *, installer: bool = False, depth: int = 0) -> None:
        tokens = lex_source(source)
        code = code_only(source, tokens)
        patterns = (
            ("source.network", r"\b(?:loadstring|loadfile|dofile|HttpGet|HttpGetAsync|HttpPost|HttpPostAsync|RequestAsync|GetAsync|PostAsync|LoadAsset|LoadAssetAsync)\s*\(",
             "Possible loader/network/storage API call; manually review executable context and remove real integrations."),
            ("source.integration", r"\b(?:Prompt\w*Purchase|AwardBadge(?:Async)?|UserHasBadgeAsync|SetAsync|UpdateAsync|IncrementAsync|FireServer|InvokeServer)\s*\(|\bProcessReceipt\s*=",
             "Possible purchase/reward/persistence/remote integration; this pack should change demo-only state."),
        )
        for finding_code, pattern, message in patterns:
            match = re.search(pattern, code)
            if match:
                line = source.count("\n", 0, match.start()) + 1
                self.add("WARN", finding_code, f"{label}:{line}: heuristic: {message}")
        for index, token in enumerate(tokens[:-2]):
            if token.value == "require" and token.kind == "word" and tokens[index + 1].value == "(":
                argument = tokens[index + 2]
                if argument.value.isdigit() or (argument.kind == "string" and "rbxassetid://" in argument.value):
                    self.add("WARN", "source.network", f"{label}: heuristic: asset-ID require call may load remote code.")
                    break
        if any(source[token.start:token.start + 1] == "`" for token in tokens if token.kind == "string"):
            self.add("WARN", "source.interpolation", f"{label}: backtick interpolation is opaque to this scanner.")
        if installer or re.search(r"\bCONFIG\s*(?::[^=\n]+)?=\s*\{", code):
            self.config(tokens, code, label)
        if installer:
            # Resolve only direct literal/identifier Source assignments. Never eval.
            literals = {tokens[i].value: tokens[i + 2].value for i in range(len(tokens) - 2)
                        if tokens[i].kind == "word" and tokens[i + 1].value == "="
                        and tokens[i + 2].kind == "string"}
            embedded = []
            for i in range(len(tokens) - 2):
                if tokens[i].kind == "word" and tokens[i].value == "Source" and tokens[i + 1].value == "=":
                    value = tokens[i + 2]
                    text = value.value if value.kind == "string" else literals.get(value.value)
                    if text and text.strip():
                        embedded.append(text)
            if not embedded:
                self.add("WARN", "source.embedded", f"{label}: no literal embedded script Source resolved; verify the installer embeds a nonempty Controller LocalScript.")
            elif depth == 0:
                self.add("PASS", "source.embedded_candidate", f"{label}: found {len(embedded)} literal Source candidate(s); assignment destination is not proven.")
                for index, script in enumerate(embedded):
                    self.source(script, f"{label} embedded candidate {index + 1}", depth=1)

    def config(self, tokens: list[Token], code: str, label: str) -> None:
        match = re.search(r"\bCONFIG\s*(?::[^=\n]+)?=\s*\{", code)
        if not match:
            self.add("WARN", "source.config", f"{label}: heuristic: editable CONFIG table not recognized.")
            return
        start = match.end() - 1
        fields = {}
        depth = 0
        for i, token in enumerate(tokens):
            if token.start < start:
                continue
            if token.value == "{" and token.kind != "string":
                depth += 1
            elif token.value == "}" and token.kind != "string":
                depth -= 1
                if depth == 0:
                    break
            if depth == 1 and token.kind == "word" and i + 2 < len(tokens) and tokens[i + 1].value == "=":
                value = tokens[i + 2]
                simple = i + 3 < len(tokens) and tokens[i + 3].value in (",", ";", "}")
                fields[token.value] = (value, simple)
        for name in (*SOUNDS, "SoundVolume", "ReducedMotion"):
            if name not in fields:
                self.add("WARN", "source.config", f"{label}: heuristic: CONFIG.{name} default not recognized.")
            elif name in SOUNDS:
                value, simple = fields[name]
                if not simple or value.kind != "string":
                    self.add("WARN", "source.sound_unknown", f"{label}: CONFIG.{name} is not a recognized literal; verify an empty default.")
                elif value.value:
                    self.add("WARN", "source.sound_default", f"{label}: CONFIG.{name} has a nonempty literal default; review asset rights and reset before distribution.")
                else:
                    self.add("PASS", "source.sound_empty", f"{label}: CONFIG.{name} has an empty literal default (heuristic).")

    def inspect_file(self, path: Path, relative: str) -> None:
        lower = relative.lower()
        suffix = path.suffix.lower()
        parts = Path(lower).parts
        reference_name = any(re.search(r"(?:^|[-_ .])(?:references?|refs?|moodboard|supplied)(?:$|[-_ .])", part) for part in parts)
        if reference_name and suffix in MEDIA:
            self.add("FAIL", "media.reference", f"{relative}: reference/supplied media filename is not a distributable pack asset; review and remove it.")
        elif suffix in MEDIA:
            self.add("WARN", "media.review", f"{relative}: media ownership/permissions require human review; bytes cannot prove licensing.")
        if suffix in OPAQUE:
            self.add("WARN", "file.opaque", f"{relative}: binary/archive contents are not inspected; do not treat this as a full distribution audit.")
        env_file = path.name.lower() == ".env" or (path.name.lower().startswith(".env.")
                   and path.name.lower() not in {".env.example", ".env.sample", ".env.template"})
        if (env_file or path.name.lower() in {"credentials.json", "secrets.json", "id_rsa", "id_ed25519"}
                or suffix in {".p12", ".pfx", ".key"}):
            self.add("FAIL", "credential.filename", f"{relative}: credential-like filename must not be distributed.")
        try:
            raw = path.read_bytes()
        except OSError:
            self.add("FAIL", "file.read", f"{relative}: file is unreadable.")
            return
        # Scan even comments/binary strings for secrets; never print matched values.
        signatures = (
            rb"-----BEGIN (?:RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----",
            rb"\bgh[pousr]_[A-Za-z0-9]{30,}\b",
            rb"\bgithub_pat_[A-Za-z0-9_]{40,}\b",
            rb"\bAKIA[A-Z0-9]{16}\b",
            rb"https://(?:canary\.|ptb\.)?discord(?:app)?\.com/api/webhooks/\d+/[A-Za-z0-9_-]{20,}",
            rb"_\|WARNING:-DO-NOT-SHARE-THIS\.[^\r\n]{20,}",
        )
        if any(re.search(pattern, raw) for pattern in signatures):
            self.add("FAIL", "credential.signature", f"{relative}: credential-like signature detected (value redacted); remove it and review rotation if genuine.")
        if suffix in {".luau", ".lua", ".json", ".md", ".txt", ".toml", ".yaml", ".yml", ".env", ".rbxmx", ".rbxlx"}:
            generic = rb'''(?im)["']?(?:api[_-]?key|access[_-]?token|password|client[_-]?secret)["']?\s*[:=]\s*["']([^"'\r\n]{12,})["']'''
            if re.search(generic, raw):
                self.add("WARN", "credential.assignment", f"{relative}: possible credential assignment (value redacted); manually distinguish placeholders from secrets.")
        if suffix in {".luau", ".lua"} and not relative.startswith(("tests/", "tools/")):
            text = self.read(path, relative)
            if text is not None:
                if not lex_source(text):
                    self.add("FAIL", "source.empty", f"{relative}: source has no non-comment tokens.")
                self.source(text, relative, installer=relative == "src/Build.luau")
        if suffix in {".rbxmx", ".rbxlx"}:
            self.export(path, relative, model=suffix == ".rbxmx")

    def export(self, path: Path, label: str, *, model: bool = True) -> None:
        try:
            root = ET.parse(path, parser=ET.XMLParser(target=NoDoctype())).getroot()
        except (ET.ParseError, OSError, ValueError):
            self.add("FAIL", "xml.invalid", f"{label}: malformed/unreadable XML or unsupported DTD; no scripts were executed.")
            return
        self.add("PASS", "xml.valid", f"{label}: XML is well-formed (not a Studio import test).")
        if root.tag != "roblox":
            self.add("FAIL", "xml.root", f"{label}: expected a Roblox XML root element.")
            return

        def prop(item, name):
            return item.find(f"./Properties/*[@name='{name}']")

        def value(item, name):
            element = prop(item, name)
            return "".join(element.itertext()) if element is not None else None

        def child(parent, name, classes):
            matches = [item for item in parent.findall("Item") if value(item, "Name") == name]
            if len(matches) != 1 or matches[0].get("class") not in classes:
                self.add("FAIL", "xml.hierarchy", f"{label}: expected exactly one direct {name} with class in {sorted(classes)}.")
                return None
            self.add("PASS", "xml.hierarchy", f"{label}: direct {name} hierarchy matches.")
            return matches[0]

        guis = [item for item in root.iter("Item") if value(item, "Name") == "StudsUI"]
        if len(guis) != 1 or guis[0].get("class") != "ScreenGui":
            # Optional demos can contain both StarterGui and saved PlayerGui copies.
            self.add("FAIL" if model else "WARN", "xml.gui", f"{label}: expected one StudsUI ScreenGui; found {len(guis)} named instance(s).")
            return
        gui = guis[0]
        if value(gui, "ResetOnSpawn") != "false":
            self.add("FAIL", "xml.reset", f"{label}: StudsUI must explicitly serialize ResetOnSpawn=false.")
        else:
            self.add("PASS", "xml.reset", f"{label}: ResetOnSpawn=false.")
        if value(gui, "Enabled") == "false":
            self.add("FAIL", "xml.disabled", f"{label}: StudsUI is disabled.")
        controller = child(gui, "Controller", {"LocalScript"})
        if controller is not None:
            if value(controller, "Disabled") == "true" or value(controller, "Enabled") == "false":
                self.add("FAIL", "xml.controller_disabled", f"{label}: Controller is disabled.")
            else:
                self.add("PASS", "xml.controller_enabled", f"{label}: Controller has no serialized disabled flag (runtime still unverified).")
        canvas = child(gui, "DesignCanvas", {"Frame", "CanvasGroup", "ScrollingFrame"})
        if canvas is not None:
            child(canvas, "HUD", {"Frame", "CanvasGroup", "ScrollingFrame"})
            modals = child(canvas, "Modals", {"Frame", "CanvasGroup", "ScrollingFrame"})
            if modals is not None:
                for name in PANELS:
                    panel = child(modals, name, {"Frame"})
                    if panel is not None and value(panel, "Visible") != "false":
                        self.add("FAIL", "xml.panel_open", f"{label}: {name} must explicitly serialize Visible=false; omitted defaults are visible.")
                extras = [item for item in modals.findall("Item")
                          if item.get("class") == "Frame" and value(item, "Name") not in PANELS]
                if extras:
                    self.add("WARN", "xml.extra_panels", f"{label}: additional direct Frames in Modals need review.")
        shared = {item.get("md5"): item.text or "" for item in root.findall("./SharedStrings/SharedString")}
        for script in gui.iter("Item"):
            if script.get("class") == "Sound" and (value(script, "SoundId") or "").strip():
                self.add("WARN", "xml.sound_default", f"{label}: exported Sound has a nonempty SoundId; review rights and empty distribution defaults.")
            if script.get("class") not in {"Script", "LocalScript", "ModuleScript"}:
                continue
            element = prop(script, "Source")
            if element is None or not "".join(element.itertext()).strip():
                self.add("FAIL", "xml.source_missing", f"{label}: {script.get('class')} has no embedded nonempty Source; linked scripts are not a self-contained substitute.")
                continue
            source = "".join(element.itertext())
            if element.tag == "SharedString":
                try:
                    encoded = "".join(shared[source.strip()].split())
                    source = base64.b64decode(encoded, validate=True).decode("utf-8")
                except (KeyError, ValueError, UnicodeError):
                    self.add("WARN", "xml.source_opaque", f"{label}: shared Source could not be resolved; inspect in Studio.")
                    continue
            elif element.tag not in {"ProtectedString", "string"}:
                self.add("WARN", "xml.source_opaque", f"{label}: unrecognized Source encoding; inspect in Studio.")
                continue
            if not lex_source(source):
                self.add("FAIL", "xml.source_missing", f"{label}: decoded script Source has no non-comment tokens.")
            else:
                self.add("PASS", "xml.source_present", f"{label}: embedded script text is available for heuristic scanning.")
                self.source(source, f"{label} embedded {script.get('class')}")
        self.add("WARN", "xml.attributes", f"{label}: binary AttributesSerialize/action wiring and Studio import behavior are not verified; run InspectInstalled.luau and manual interactions.")

    def run(self) -> list[Finding]:
        self.add("WARN", "scope.offline", "Read-only offline validation only: no Luau parser, installer execution, Studio import, runtime test, network request, or comprehensive secret scan is performed.")
        if not self.pack.is_dir():
            self.add("FAIL", "pack.missing", "Explicit pack path is not an existing directory.")
            return self.findings
        for relative in REQUIRED:
            path = self.path(relative, relative)
            if path is None:
                continue
            if not path.is_file():
                self.add("FAIL", "required.missing", f"Missing required deliverable: {relative}.")
            elif path.stat().st_size == 0:
                self.add("FAIL", "required.empty", f"Required deliverable is empty: {relative}.")
            else:
                self.add("PASS", "required.present", f"Required deliverable present: {relative}.")
                if relative == "pack.json":
                    self.metadata(path)
        export_path = self.path("exports/studs-ui.rbxmx", "optional export")
        if export_path is not None:
            if export_path.exists() and not export_path.is_file():
                self.add("FAIL", "export.type", "Optional exports/studs-ui.rbxmx exists but is not a regular file.")
            elif not export_path.is_file():
                self.add("WARN", "export.absent", "Optional exports/studs-ui.rbxmx absent; source-only draft and files.model=null are permitted.")

        def walk_error(error):
            self.add("FAIL", "file.walk", "Cannot enumerate part of the pack; audit is incomplete.")
        # Path.walk does not follow directory links. Explicitly reject external
        # links before reading; warn on internal directory links/junctions.
        for directory, dirs, files in self.pack.walk(on_error=walk_error, follow_symlinks=False):
            for name in sorted(dirs + files):
                entry = directory / name
                relative = entry.relative_to(self.pack).as_posix()
                target = self.path(relative, relative)
                if target is None:
                    if name in dirs:
                        dirs.remove(name)
                    continue
                if entry.is_symlink() or entry.is_junction():
                    if name in dirs:
                        dirs.remove(name)
                    self.add("WARN", "file.link", f"{relative}: link/junction detected; directory targets are not recursively scanned.")
                if target.is_file():
                    self.inspect_file(target, relative)
        return self.findings


def validate_pack(pack: Path) -> list[Finding]:
    return Validator(pack).run()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", type=Path, help="explicit path to packs/ui/studs-ui")
    args = parser.parse_args(argv)
    try:
        findings = validate_pack(args.pack)
    except (OSError, ValueError, RuntimeError, RecursionError):
        # No raw exception/source text: it could contain credential values.
        print("[FAIL] validation.error: unable to complete filesystem/XML inspection; audit is incomplete.")
        return 1
    for finding in findings:
        print(f"[{finding.level}] {finding.code}: {finding.message}")
    counts = {level: sum(f.level == level for f in findings) for level in ("PASS", "WARN", "FAIL")}
    print(f"Summary: {counts['PASS']} pass, {counts['WARN']} warning, {counts['FAIL']} failure. Studio checks: NOT RUN.")
    return 1 if counts["FAIL"] else 0


if __name__ == "__main__":
    sys.exit(main())
