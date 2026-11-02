"""Synthetic text/XML is generated ONLY inside temporary directories.

These tests exercise offline diagnostics, not a working installer or Studio.
Run with Python -B so no bytecode artifacts are written into the pack.
"""

import base64
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET


VALIDATOR = Path(__file__).resolve().parents[1] / "tools" / "validate_pack.py"
SPEC = importlib.util.spec_from_file_location("studs_pack_validator", VALIDATOR)
validator = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = validator
SPEC.loader.exec_module(validator)


class ValidatePackTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.pack = Path(self.temp.name) / "pack"
        self.pack.mkdir()
        self.metadata = {
            "id": "studs-ui", "name": "Studs UI", "category": "ui",
            "version": "0.0.0", "status": "draft", "license": "UNLICENSED",
            "description": "Temporary diagnostic input", "author": "",
            "files": {"model": None, "demo": None, "previews": []},
            "dependencies": [], "tags": ["ui"],
        }
        self.save_metadata()
        for name in ("README.md", "CHANGELOG.md", "CREDITS.md"):
            self.write(name, "Temporary diagnostic input; no license granted.\n")
        # Not an installer: just lexical input for CONFIG / Source diagnostics.
        self.source = (
            '-- Synthetic text, never executed.\n'
            'local CONFIG = {\n'
            ' OpenSoundId = "", CloseSoundId = "",\n'
            ' HoverSoundId = "", ClickSoundId = "",\n'
            ' SoundVolume = 0.5, ReducedMotion = false,\n'
            '}\n'
            'local SCRIPT_TEXT = [=[return nil]=]\n'
            'controller.Source = SCRIPT_TEXT\n'
        )
        self.write("src/Build.luau", self.source)

    def write(self, name, text):
        path = self.pack / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path

    def save_metadata(self):
        self.write("pack.json", json.dumps(self.metadata))

    def findings(self):
        return validator.validate_pack(self.pack)

    def assert_code(self, code, level=None):
        findings = self.findings()
        self.assertTrue(any(f.code == code and (level is None or f.level == level) for f in findings), findings)

    def assert_no_failures(self):
        self.assertEqual([], [f for f in self.findings() if f.level == "FAIL"])

    def xml_fixture(self):
        # Generated XML tests structural checks only. No fixture export is saved
        # in this repository and no source here implements Studs UI.
        root = ET.Element("roblox", version="4")

        def item(parent, kind, name, props=()):
            element = ET.SubElement(parent, "Item", {"class": kind})
            properties = ET.SubElement(element, "Properties")
            ET.SubElement(properties, "string", name="Name").text = name
            for tag, key, value in props:
                ET.SubElement(properties, tag, name=key).text = value
            return element

        gui = item(root, "ScreenGui", "StudsUI", [("bool", "ResetOnSpawn", "false")])
        controller = item(gui, "LocalScript", "Controller", [
            ("bool", "Disabled", "false"), ("ProtectedString", "Source", "return nil"),
        ])
        canvas = item(gui, "Frame", "DesignCanvas")
        item(canvas, "Frame", "HUD")
        modals = item(canvas, "Frame", "Modals")
        for name in validator.PANELS:
            item(modals, "Frame", name, [("bool", "Visible", "false")])
        return root, gui, controller, canvas, modals

    def save_xml(self, root):
        self.write("exports/studs-ui.rbxmx", ET.tostring(root, encoding="unicode"))

    def test_valid_draft_with_null_model(self):
        self.assert_no_failures()
        self.assert_code("metadata.license", "PASS")
        self.assert_code("metadata.status", "PASS")

    def test_optional_export_absence_is_warning_not_failure(self):
        self.assert_no_failures()
        self.assert_code("export.absent", "WARN")
        with contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(0, validator.main([str(self.pack)]))
        self.assertIn("Studio checks: NOT RUN", output.getvalue())

    def test_missing_deliverables_are_failures(self):
        for name in validator.REQUIRED:
            with self.subTest(name=name):
                path = self.pack / name
                original = path.read_bytes()
                path.unlink()
                self.assert_code("required.missing", "FAIL")
                path.write_bytes(original)

    def test_empty_deliverable_is_failure(self):
        self.write("src/Build.luau", "")
        self.assert_code("required.empty", "FAIL")

    def test_comment_only_installer_is_failure(self):
        self.write("src/Build.luau", "-- not an installer\n--[=[nothing here]=]")
        self.assert_code("source.empty", "FAIL")

    def test_nonexistent_pack(self):
        result = validator.validate_pack(self.pack / "missing")
        self.assertTrue(any(f.code == "pack.missing" and f.level == "FAIL" for f in result))

    def test_invalid_json_is_failure_without_exception(self):
        for text in ("{", "[]", '{"id": "a", "id": "b"}', '{"version": NaN}'):
            with self.subTest(text=text):
                self.write("pack.json", text)
                self.assertTrue(any(f.level == "FAIL" for f in self.findings()))

    def test_identity_and_draft_policy(self):
        for key, wrong in (("id", "another-pack"), ("category", "audio"),
                           ("status", "released"), ("license", "MIT")):
            with self.subTest(key=key):
                old = self.metadata[key]
                self.metadata[key] = wrong
                self.save_metadata()
                self.assert_code(f"metadata.{key}", "FAIL")
                self.metadata[key] = old
        self.save_metadata()

    def test_template_file_types(self):
        for key, value in (("model", []), ("demo", {}), ("previews", None), ("previews", [None])):
            with self.subTest(key=key, value=value):
                original = self.metadata["files"][key]
                self.metadata["files"][key] = value
                self.save_metadata()
                self.assert_code("metadata.files", "FAIL")
                self.metadata["files"][key] = original

    def test_missing_referenced_file_even_when_export_optional(self):
        self.metadata["files"]["model"] = "exports/studs-ui.rbxmx"
        self.save_metadata()
        self.assert_code("path.missing", "FAIL")

    def test_all_reference_collections_are_checked(self):
        self.metadata["files"]["extra"] = {"nested": ["src/missing.luau"]}
        self.save_metadata()
        self.assert_code("path.missing", "FAIL")

    def test_traversal_absolute_drive_and_unc_paths(self):
        (self.pack.parent / "outside.txt").write_text("outside", encoding="utf-8")
        for path in ("../outside.txt", "src/../../outside.txt", "..\\outside.txt",
                     "/tmp/outside", "C:\\outside.txt", "C:outside.txt", "\\outside.txt",
                     "\\\\server\\share\\file", "src/file:stream", "bad\x00path"):
            with self.subTest(path=repr(path)):
                self.metadata["files"]["demo"] = path
                self.save_metadata()
                self.assert_code("path.escape", "FAIL")

    def test_reference_must_be_file_not_directory(self):
        self.metadata["files"]["demo"] = "src"
        self.save_metadata()
        self.assert_code("path.missing", "FAIL")

    def test_backslash_relative_path_is_portable(self):
        self.metadata["files"]["installer"] = "src\\Build.luau"
        self.save_metadata()
        self.assert_no_failures()

    def test_external_symlink_rejected_without_reading_target(self):
        outside = self.pack.parent / "outside.txt"
        outside.write_text("outside", encoding="utf-8")
        link = self.pack / "outside.txt"
        try:
            link.symlink_to(outside)
        except (OSError, NotImplementedError):
            self.skipTest("OS does not permit symlink creation in this environment")
        self.metadata["files"]["demo"] = "outside.txt"
        self.save_metadata()
        self.assert_code("path.escape", "FAIL")

    def test_well_formed_export_and_embedded_source(self):
        self.save_xml(self.xml_fixture()[0])
        self.metadata["files"]["model"] = "exports/studs-ui.rbxmx"
        self.save_metadata()
        self.assert_no_failures()
        self.assert_code("xml.valid", "PASS")
        self.assert_code("xml.source_present", "PASS")
        self.assert_code("xml.attributes", "WARN")

    def test_malformed_xml(self):
        self.write("exports/studs-ui.rbxmx", "<roblox><Item></roblox>")
        self.assert_code("xml.invalid", "FAIL")

    def test_optional_export_path_cannot_be_a_directory(self):
        (self.pack / "exports/studs-ui.rbxmx").mkdir(parents=True)
        self.assert_code("export.type", "FAIL")

    def test_xml_dtd_is_not_expanded(self):
        self.write("exports/studs-ui.rbxmx", '<!DOCTYPE roblox [<!ENTITY x "text">]><roblox>&x;</roblox>')
        self.assert_code("xml.invalid", "FAIL")

    def test_wrong_xml_root_or_missing_gui(self):
        self.write("exports/studs-ui.rbxmx", "<unrelated />")
        self.assert_code("xml.root", "FAIL")
        self.write("exports/studs-ui.rbxmx", '<roblox version="4" />')
        self.assert_code("xml.gui", "FAIL")

    def test_missing_or_nested_controller(self):
        for nested in (False, True):
            with self.subTest(nested=nested):
                root, gui, controller, canvas, _ = self.xml_fixture()
                gui.remove(controller)
                if nested:
                    canvas.append(controller)
                self.save_xml(root)
                self.assert_code("xml.hierarchy", "FAIL")

    def test_missing_required_hierarchy_and_panel(self):
        for name in ("DesignCanvas", "HUD", "Modals", *validator.PANELS):
            with self.subTest(name=name):
                root = self.xml_fixture()[0]
                for parent in root.iter():
                    found = next((c for c in parent.findall("Item")
                                  if c.findtext("./Properties/string[@name='Name']") == name), None)
                    if found is not None:
                        parent.remove(found)
                        break
                self.save_xml(root)
                self.assert_code("xml.hierarchy", "FAIL")

    def test_wrong_panel_class_and_duplicate_identity(self):
        root, _, _, _, modals = self.xml_fixture()
        panel = modals.findall("Item")[0]
        panel.set("class", "Folder")
        self.save_xml(root)
        self.assert_code("xml.hierarchy", "FAIL")
        panel.set("class", "Frame")
        modals.append(ET.fromstring(ET.tostring(panel)))
        self.save_xml(root)
        self.assert_code("xml.hierarchy", "FAIL")

    def test_missing_source_disabled_controller_and_open_panel(self):
        root, _, controller, _, modals = self.xml_fixture()
        controller.find("Properties").remove(controller.find("./Properties/ProtectedString"))
        controller.find("./Properties/bool[@name='Disabled']").text = "true"
        modals.findall("Item")[0].find("./Properties/bool[@name='Visible']").text = "true"
        self.save_xml(root)
        self.assert_code("xml.source_missing", "FAIL")
        self.assert_code("xml.controller_disabled", "FAIL")
        self.assert_code("xml.panel_open", "FAIL")

    def test_reset_and_visibility_omission_do_not_pass(self):
        root, gui, _, _, modals = self.xml_fixture()
        gui.find("Properties").remove(gui.find("./Properties/bool[@name='ResetOnSpawn']"))
        panel = modals.findall("Item")[0]
        panel.find("Properties").remove(panel.find("./Properties/bool[@name='Visible']"))
        self.save_xml(root)
        self.assert_code("xml.reset", "FAIL")
        self.assert_code("xml.panel_open", "FAIL")

    def test_shared_source_supported_or_honestly_opaque(self):
        root, _, controller, _, _ = self.xml_fixture()
        source = controller.find("./Properties/ProtectedString")
        source.tag = "SharedString"
        source.text = "test-key"
        shared = ET.SubElement(root, "SharedStrings")
        ET.SubElement(shared, "SharedString", md5="test-key").text = base64.b64encode(b"return nil").decode()
        self.save_xml(root)
        self.assert_no_failures()
        self.assert_code("xml.source_present", "PASS")
        root.remove(shared)
        self.save_xml(root)
        self.assert_code("xml.source_opaque", "WARN")

    def test_comments_and_plain_strings_are_not_api_calls(self):
        harmless = '''
-- loadstring(game:HttpGet("url")) require(12345)
--[=[ MarketplaceService:PromptProductPurchase(player, 123) ]=]
local notice = "Do not call AwardBadge(123) or RequestAsync({})"
local help = [==[ Never use loadstring(...) or require(123) ]==]
local escaped = "a\\\" loadstring(thing)"
'''
        self.write("src/Build.luau", self.source + harmless)
        self.assert_no_failures()
        self.assertFalse(any(f.code in {"source.network", "source.integration"} for f in self.findings()))

    def test_actual_calls_are_only_heuristic_warnings(self):
        self.write("src/Build.luau", self.source + '\nloadstring(game:HttpGet("url"))\nservice:PromptProductPurchase(player, 1)\n')
        self.assert_code("source.network", "WARN")
        self.assert_code("source.integration", "WARN")
        self.assert_no_failures()

    def test_numeric_require_warning_and_embedded_loader_scanning(self):
        self.write("src/Build.luau", self.source.replace("return nil", "require(123456)"))
        self.assert_code("source.network", "WARN")
        self.assertTrue(any("embedded candidate" in f.message and f.code == "source.network" for f in self.findings()))

    def test_export_source_calls_not_comments_are_warned(self):
        root, _, controller, _, _ = self.xml_fixture()
        source = controller.find("./Properties/ProtectedString")
        source.text = '-- loadstring(game:HttpGet("url"))\nreturn nil'
        self.save_xml(root)
        self.assertFalse(any(f.code == "source.network" for f in self.findings()))
        source.text = 'loadstring(game:HttpGet("url"))'
        self.save_xml(root)
        self.assert_code("source.network", "WARN")
        self.assert_no_failures()

    def test_export_nonempty_sound_default_is_warning(self):
        root, gui, _, _, _ = self.xml_fixture()
        sound = ET.SubElement(gui, "Item", {"class": "Sound"})
        properties = ET.SubElement(sound, "Properties")
        content = ET.SubElement(properties, "Content", name="SoundId")
        ET.SubElement(content, "url").text = "rbxassetid://123"
        self.save_xml(root)
        self.assert_code("xml.sound_default", "WARN")
        self.assert_no_failures()

    def test_missing_embedded_installer_source_is_not_parser_failure(self):
        self.write("src/Build.luau", "local CONFIG = {}\nerror('Never execute this file')")
        self.assert_code("source.embedded", "WARN")
        self.assert_code("source.config", "WARN")
        self.assert_no_failures()

    def test_nonempty_sound_default_and_computed_value(self):
        self.write("src/Build.luau", self.source.replace('OpenSoundId = ""', 'OpenSoundId = "rbxassetid://123"'))
        self.assert_code("source.sound_default", "WARN")
        self.write("src/Build.luau", self.source.replace('OpenSoundId = ""', 'OpenSoundId = "" .. value'))
        self.assert_code("source.sound_unknown", "WARN")

    def test_source_sound_comments_are_ignored(self):
        self.write("src/Build.luau", '-- OpenSoundId = "rbxassetid://123"\n' + self.source)
        findings = self.findings()
        self.assertFalse(any(f.code == "source.sound_default" for f in findings))
        self.assertEqual(4, sum(f.code == "source.sound_empty" for f in findings))

    def test_reference_media_is_not_shipped_but_previews_are_allowed(self):
        self.write("reference/source.png", "temporary diagnostic bytes, not an image")
        self.assert_code("media.reference", "FAIL")
        (self.pack / "reference/source.png").unlink()
        self.write("previews/desktop.png", "temporary diagnostic bytes, not an image")
        self.metadata["files"]["previews"] = ["previews/desktop.png"]
        self.save_metadata()
        self.assert_no_failures()
        self.assert_code("media.review", "WARN")

    def test_credentials_are_redacted_even_in_comments(self):
        synthetic_token = "gh" + "p_" + "A" * 36
        self.write("src/Build.luau", self.source + "\n-- " + synthetic_token)
        self.assert_code("credential.signature", "FAIL")
        with contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(1, validator.main([str(self.pack)]))
        self.assertNotIn(synthetic_token, output.getvalue())

    def test_credential_filename_and_generic_assignment(self):
        self.write(".env", "temporary input")
        self.assert_code("credential.filename", "FAIL")
        (self.pack / ".env").unlink()
        self.write("notes.txt", 'api_' + 'key = "' + "x" * 20 + '"')
        self.assert_code("credential.assignment", "WARN")

    def test_environment_variants_and_opaque_archives(self):
        self.write(".env.production", "temporary input")
        self.assert_code("credential.filename", "FAIL")
        (self.pack / ".env.production").unlink()
        self.write(".env.example", "temporary input")
        self.write("download.zip", "not an archive; only tests the diagnostic")
        self.assert_no_failures()
        self.assert_code("file.opaque", "WARN")

    def test_validation_is_read_only(self):
        self.save_xml(self.xml_fixture()[0])
        def snapshot():
            return {p.relative_to(self.pack): (p.read_bytes(), p.stat().st_mtime_ns)
                    for p in self.pack.rglob("*") if p.is_file()}
        before = snapshot()
        self.findings()
        self.assertEqual(before, snapshot())

    def test_cli_requires_explicit_path_and_returns_failure(self):
        result = subprocess.run([sys.executable, "-B", str(VALIDATOR)], capture_output=True, text=True)
        self.assertEqual(2, result.returncode)
        (self.pack / "src/Build.luau").unlink()
        result = subprocess.run([sys.executable, "-B", str(VALIDATOR), str(self.pack)], capture_output=True, text=True)
        self.assertEqual(1, result.returncode)
        self.assertIn("[FAIL] required.missing", result.stdout)


if __name__ == "__main__":
    unittest.main()
