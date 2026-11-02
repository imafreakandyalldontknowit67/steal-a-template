# Build with your agent

Start with the kit, then give your agent a bounded change: a new theme, a panel layout, or an integration with your existing systems. An agent can inspect the Luau and docs without running Studio. It needs Studio access to inspect live instances, export a native model, and verify the result in Play.

## Read in this order

1. [AGENTS.md](../AGENTS.md): repository conventions and verification rules.
2. [catalog.json](../catalog.json): exact model, source, and README paths.
3. The selected pack's README: installation, hierarchy, and demo behavior.
4. The pack's `src/` plus credits and verification notes where present.

Catalog paths are relative to the repo root. The catalog is an index, not a package installer or a promise of compatibility.

## Choose the entry point

| Task | Start here | Expected output |
| --- | --- | --- |
| Try a kit | Its `.rbxm` and README | Imported ScreenGui in StarterGui |
| Restyle a panel | `src/Build.luau` and authored instances | Updated source, model, and screenshot |
| Change interactions | The controller/runtime listed in the catalog | Behavior change verified in Play |
| Configure Essential STUD | `Configuration.luau` and `Runtime.luau` | Updated defaults and matching embedded scripts |
| Connect gameplay | Your server systems plus the kit's demo handlers | Explicit server/client integration; no client-authoritative rewards |
| Add a kit | [Authoring guide](AUTHORING.md) and [template](../_templates/ui-pack/) | A self-contained pack and updated catalog |

## Copy a task

### Restyle an existing kit

```text
Read AGENTS.md and catalog.json. Work only in packs/ui/studs-ui.
Inspect its README and source, then change the UI to [describe theme].
Preserve existing routes and interactions. Keep native instances
editable. Synchronize the source and model, verify the exported model
in Studio Play, and refresh screenshots of affected panels.
Report the actual viewport/input coverage and any remaining gaps.
```

### Integrate with a game

```text
Inspect the Essential STUD UI pack and my game's existing server APIs.
Map each demo purchase/reward handler to a proposed integration point.
Preserve the UI animations. Implement against the existing APIs only;
do not invent product IDs, remotes, persistence, or ownership checks.
Keep server-side validation authoritative. Explain which flows were
tested and which require live purchase or persistence verification.
```

### Work without Studio access

```text
Inspect the Steal an Egg source and propose the requested change.
Make the source edits and document the corresponding instance changes.
Do not edit the binary model as text. Clearly mark the export and
runtime checks pending until Studio is available.
```

## Handoff back to a developer

Name the changed pack and files, link its model and updated preview, explain the behavior change, and list the checks actually run. Include unresolved asset access, device coverage, or backend dependencies.

Changing a local script does not update an already exported model. A screenshot does not prove a purchase works. A successful desktop run does not prove touch support. Keep these distinctions in the handoff so the next developer or agent can pick up the work.
