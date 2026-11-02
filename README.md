<div align="center">

<img src="assets/branding/banner.png" alt="Steal a Template — Grab a kit. Build something." width="100%">

# Steal a Template

**Free Roblox asset packs for developers and their AI agents.**

UI kits now. Models, VFX, and Luau systems next.

[Browse UI kits](#pick-a-kit) · [Install a kit](#drop-it-into-studio) · [Build with an agent](docs/USING_WITH_AGENTS.md) · [Contribute](CONTRIBUTING.md)

</div>

Skip the blank baseplate. Start with an editable kit, open the source, and build your game around it. Studded panels, chunky buttons, loud colors, and actual Roblox instances you can change.

**Current status:** three UI kits are available to repository collaborators as private drafts. Free public distribution is the goal; the packs are still unlicensed and pending rights review. Check each pack's status before reuse or redistribution.

<a id="catalog"></a>

## Pick a kit

| [Studs UI](packs/ui/studs-ui/) | [Essential STUD UI](packs/ui/essential-stud-ui/) | [Steal an Egg](packs/ui/steal-an-egg/) |
| --- | --- | --- |
| [![Studs UI shop](packs/ui/studs-ui/previews/shop.jpg)](packs/ui/studs-ui/) | [![Essential STUD UI shop](packs/ui/essential-stud-ui/previews/shop.jpg)](packs/ui/essential-stud-ui/) | [![Steal an Egg shop](packs/ui/steal-an-egg/previews/shop.jpg)](packs/ui/steal-an-egg/) |
| HUD, shops, rewards, rebirth, index, and settings. | Shops, gifting, codes, rewards, lucky wheel, and animated effects. | HUD, pet index, active pets, growing eggs, fuse machine, and trails. |
| [10 screenshots](packs/ui/studs-ui/#screenshot-gallery) · [Download RBXM](packs/ui/studs-ui/StudsUI.rbxm?raw=1) | [13 screenshots](packs/ui/essential-stud-ui/#screenshot-gallery) · [Download RBXM](packs/ui/essential-stud-ui/EssentialStudUI.rbxm?raw=1) | [21 screenshots](packs/ui/steal-an-egg/#screenshot-gallery) · [Download RBXM](packs/ui/steal-an-egg/StealAnEggUI.rbxm?raw=1) |

These are UI demos. Purchases, rewards, currency, and inventory need your game's backend. Device coverage and asset-access requirements are listed in each pack.

## Drop it into Studio

1. Pick a kit and download its **`.rbxm`**. You do not need the whole repo.
2. Stop Play in Roblox Studio. Right-click **StarterGui → Insert from File** and select the model.
3. If it lands elsewhere, move the kit's **ScreenGui** into **StarterGui**.
4. Press **Play**, try the included interactions, then customize the named instances.

The controller comes with the model. No code paste, Rojo setup, or extra plugin is needed to try the current kits. Read the pack README for its hierarchy, configuration, linked assets, and limits.

## Bring your agent

The native model is for Studio. The Luau source, file paths, and pack notes are for you and your agent.

Start with [`catalog.json`](catalog.json) to find a pack, then read its README and `src/`. [`AGENTS.md`](AGENTS.md) explains how to work in this repository; the [agent guide](docs/USING_WITH_AGENTS.md) covers importing, editing, exporting, and verifying a kit.

Give your agent a concrete task:

```text
Read AGENTS.md and catalog.json, then inspect the Steal an Egg pack's
README and src/ files. Adapt its HUD to my game's colors and currency.
Keep the existing panel routes and animations. List the integration
points before wiring my backend. Update the source and exported model,
then verify the imported result in Studio. Report anything you could
not test.
```

Use any agent that can read the repository. Applying changes to a live place requires Studio access, through your own import workflow or a connected Studio tool. This repo does not install an agent or MCP server.

## What's on the shelf?

| Category | Today |
| --- | --- |
| [UI kits](packs/ui/) | Three editable kits with source, native models, and galleries |
| [Models](packs/models/) | Planned |
| [VFX](packs/effects/) | Planned |
| [Luau systems](packs/systems/) | Planned |
| [Audio](packs/audio/) | Planned |

A **kit** is something you insert and adapt. A **system** will include documented gameplay integration. A working demo button does not imply a finished economy, purchase flow, or save system.

## Make the next pack

Keep each pack in its own folder. Ship the model, readable source, screenshots, setup instructions, asset provenance, and an honest verification record.

[Contribution guide](CONTRIBUTING.md) · [Pack format](docs/AUTHORING.md) · [Release checklist](docs/DISTRIBUTION.md) · [Brand notes](docs/BRAND.md)

## Use and licensing

Free downloads are the intended release model. Current packs have no reuse or redistribution license yet; there is no blanket license for this repository. Consult each pack's README, credits, and license status. [Licensing status](docs/LICENSING.md).

Independent project; not affiliated with Roblox.
