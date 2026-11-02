"""Check the native download, freshness metadata and complete screenshot gallery."""
import hashlib
import json
from pathlib import Path
import unittest

PACK = Path(__file__).resolve().parents[1]


class PackageDistributionTests(unittest.TestCase):
    def test_native_download_and_checksum(self):
        manifest = json.loads((PACK / 'exports/native-export.json').read_text())
        model = (PACK / manifest['model']).read_bytes()
        self.assertTrue(model.startswith(b'<roblox!'))
        self.assertEqual(hashlib.sha256(model).hexdigest(), manifest['model_sha256'])
        self.assertEqual(manifest['root_class'], 'ScreenGui')
        self.assertEqual(manifest['target_parent'], 'StarterGui')

    def test_native_download_matches_current_authoring_snapshot(self):
        manifest = json.loads((PACK / 'exports/native-export.json').read_text())
        source = (PACK / manifest['source']).read_text(encoding='utf-8').encode('utf-8')
        self.assertEqual(hashlib.sha256(source).hexdigest(), manifest['source_sha256'],
                         'Regenerate the native model and its manifest after authoring changes.')

    def test_gallery_has_hud_and_every_panel(self):
        metadata = json.loads((PACK / 'pack.json').read_text())
        expected = {'hud', 'shop', 'stock-shop', 'daily-rewards', 'rebirth',
                    'index', 'season-pass', 'upgrades', 'settings', 'starter-pack'}
        paths = metadata['files']['previews']
        self.assertEqual({Path(path).stem for path in paths}, expected)
        self.assertEqual(len(paths), 10)
        readme = (PACK / 'README.md').read_text(encoding='utf-8')
        for path in paths:
            data = (PACK / path).read_bytes()
            self.assertTrue(data.startswith(b'\xff\xd8'))
            self.assertTrue(data.endswith(b'\xff\xd9'))
            self.assertIn(path, readme)
        self.assertEqual(metadata['files']['model'], 'StudsUI.rbxm')


if __name__ == '__main__':
    unittest.main()
