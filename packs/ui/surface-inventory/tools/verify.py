"""Validate the shipped Studio-native model and local gallery. No fake runtime pass."""
from pathlib import Path
import os,subprocess,json,hashlib,re
import xml.etree.ElementTree as ET
P=Path(__file__).resolve().parents[1]
lune=Path(os.environ.get('LUNE_BIN',str(Path(os.environ.get('LOCALAPPDATA',''))/'rhr/cache/bin/lune.exe')))
assert lune.is_file(),'Set LUNE_BIN to Lune 0.10.5+'
subprocess.run([str(lune),'run',str(P/'tools/check_native.luau'),str(P/'SurfaceInventory.rbxm'),str(P/'exports/native-inspection.json')],check=True)
native=json.loads((P/'exports/native-inspection.json').read_text(encoding='utf-8-sig'))
assert native['roots']==1 and native['class']=='ScreenGui' and native['name']=='SurfaceInventory'
assert native['count']==sum(1 for _ in ET.parse(P/'src/SurfaceInventory.rbxmx').getroot().iter('Item'))
assert native['bevelFaces']==2070 and native['classes']['TextButton']==64
assert native['slots']==60 and native['scrollEnabled'] and native['scrollThickness']==4 and native['scrollWidth']==497 and native['scrollCanvasY']==1078
assert native['classes']['SurfaceGui']==1 and native['classes']['ScrollingFrame']==1
assert native['surfaceResetOnSpawn'] is False
assert set(native['scripts'])=={'Controller','Config'}
canonical=lambda s:s.replace('\r\n','\n').strip()
for name,file in [('Controller','Controller.client.luau'),('Config','Config.luau')]:
 assert canonical(native['scripts'][name])==canonical((P/'src'/file).read_text(encoding='utf-8-sig')),f'Embedded {name} differs'
assert len(native['images'])==2 and all(x['visible'] and '86135425235678' in x['image'] for x in native['images'])
assert not any(native['classes'].get(x,0) for x in ['Script','RemoteEvent','RemoteFunction'])
h=hashlib.sha256()
for file in ['tools/build.py','src/Controller.client.luau','src/Config.luau']:
 h.update(file.encode());h.update(canonical((P/file).read_text(encoding='utf-8-sig')).encode())
assert native['sourceVersion']==h.hexdigest(),'Stale native model/source version'
assert (P/'SurfaceInventory.rbxm').read_bytes().startswith(b'<roblox!')
pack=json.loads((P/'pack.json').read_text())
for file in [pack['files']['model'],pack['files']['source'],*pack['files']['previews']]:assert (P/file).is_file(),file
assert len(pack['files']['previews'])==17
readme=(P/'README.md').read_text(encoding='utf-8')
for file in pack['files']['previews']:assert ']('+file+')' in readme,file
hashes={f:hashlib.sha256((P/f).read_bytes()).hexdigest() for f in ['SurfaceInventory.rbxm','src/Controller.client.luau','src/Config.luau','src/SurfaceInventory.rbxmx','assets/backpack-v2.png']}
report={'method':'Studio SerializationService native export + independent Lune binary inspection','sourceVersion':native['sourceVersion'],'instances':native['count'],'slots':60,'buttons':64,'bevelFaces':native['bevelFaces'],'embeddedSourcesMatch':True,'realArtworkId':'rbxassetid://86135425235678','galleryCount':17,'hashes':hashes,'nativeImportCaveat':'Raw MCP serialized-script reparent blocked; deserialized native UI plus byte-identical embedded sources restored with supported script editor, then Play tested. Fresh one-step Insert from File not certified.'}
(P/'exports/native-export.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: native binary, 12990 instances, embedded sources, real art, source version, 17 gallery links. Runtime/device caveats remain in VERIFICATION.md.')
