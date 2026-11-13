# Verification

Exported real binary .rbxm with Studio SerializationService, not a renamed place file. Deserialized the final export buffer back through Studio; root names, native instance counts and class counts matched the local file inventory. Temporary export objects were unparented for serialization; source place originals were not saved or overwritten. LightingSettings was added for explicit property transfer; it is configuration, not an auto-installer. Prior place previews show the same delivered geometry/lighting; no new model-specific full runtime test is claimed.

No plot ownership, collecting, saving, economy or gameplay handlers are included. The only script in this export is the new LightingSettings configuration ModuleScript. No authored SpawnLocation. Screenshots show grouped scene regions, not exhaustive isolated inspection of every copy. No full traversal/collision, device or performance certification.

Native SHA-256: `db809cd40eedf08f5d96d6fffaf5746ee492e5b4f579faaec01a5a1887d5496e`

Version 0.1.1, 2026-11-13.
