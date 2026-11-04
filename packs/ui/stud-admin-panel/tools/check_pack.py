"""Packaging checks only; Studio verification is documented separately."""
import hashlib
import json
import re
from pathlib import Path

pack = Path(__file__).resolve().parents[1]
required = ['README.md', 'CREDITS.md', 'LICENSE', 'CHANGELOG.md', 'VERIFICATION.md',
            'StudAdminPanel.rbxm', 'src/Layout.luau', 'src/Controller.client.luau']
for relative in required:
    assert (pack / relative).is_file(), f'Missing {relative}'
model = (pack / 'StudAdminPanel.rbxm').read_bytes()
assert model.startswith(b'<roblox!'), 'Not a native binary Roblox model'
readme = (pack / 'README.md').read_text(encoding='utf-8')
for link in re.findall(r'\]\(([^)]+)\)', readme):
    if '://' not in link and not link.startswith('#'):
        assert (pack / link.split('?')[0].split('#')[0]).exists(), f'Broken link: {link}'
for p in (pack / 'previews').glob('*.jpg'):
    data = p.read_bytes()
    assert data[:2] == b'\xff\xd8' and data[-2:] == b'\xff\xd9', f'Invalid JPEG: {p.name}'
reports = json.loads((pack / 'previews/device-checks.json').read_text())
assert len(reports) == 5
assert all(json.loads(r['result'])['inBounds'] for r in reports)
metadata = json.loads((pack / 'pack.json').read_text())
assert hashlib.sha256(model).hexdigest() == metadata['sha256'], 'Model checksum mismatch'
print('PASS: package files, README links, native model signature/checksum, JPEGs, and five recorded viewport-bound checks.')
print('This is not a live Studio test or a claim of universal device support.')
