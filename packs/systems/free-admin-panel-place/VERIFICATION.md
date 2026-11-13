# Verification

Exported real binary .rbxm with Studio SerializationService, not a renamed place file. Deserialized the final export buffer back through Studio; root names, native instance counts and class counts matched the local file inventory. Temporary export objects were unparented for serialization; source place originals were not saved or overwritten. All 210 original sources match the supplied place exactly. Additionally installed the deserialized final model into the documented services in Studio, with originals temporarily backed up. Play generated the UI; the actual open button enabled it and a local announcement request delivered Converted RBXM preview to the original client. Restored the original source contents afterward. No live moderation action, kick/ban test, persistence, multiplayer security or device certification.

The original admin scripts still allow any player to kick, ban and announce, without server authorization, type validation, filtering or rate limits. Bans remain in-memory. This conversion does not repair those issues. Do not deploy the handler in a live game before securing it.

Native SHA-256: `19d6839e934a2d96b0213c72504f0e494b2dbdbd546c67c657f60d66cf854c4b`

Version 0.1.1, 2026-11-13.
