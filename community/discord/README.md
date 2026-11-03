# Discord setup

Server: [Steal a Template](https://discord.com/channels/1566964411401371769/1566966689818611732)

This folder contains the deployed artwork, copy, onboarding configuration, server IDs, and API verification record. It contains no bot token and does not run a persistent bot.

## Artwork

- [Profile image](assets/profile.png): applied to the server and setup bot.
- [Channel banners](assets/banners/): 9 deployed matching PNGs and editable SVG sources.
- [Onboarding icons](assets/icons/): 8 custom PNGs and editable SVG sources.
- [Artwork notes](ARTWORK.md): provenance and rendering details.

Each public guide uses two embeds: an image-only banner, then the body. Channel-link buttons sit below the body. No emoji or decorative text is used in channel names or written copy. Custom icons are used only as onboarding option artwork.

## Member path

1. Join and optionally choose interests and notification topics.
2. Read start-here and rules.
3. Open GitHub from asset-library and choose a kit.
4. Introduce a project in general or share a build in the Showcase forum.
5. Submit a UI request with references when needed.

Community, native onboarding, the welcome screen, and mention-spam AutoMod are enabled. Onboarding passes Discord's requirements. These settings remain after the setup bot is removed.

## Channel layout

- Start here: start-here, rules, announcements, asset-library.
- Community: general, showcase (forum), ui-requests (forum), suggestions, and bug-reports.
- Staff: community-updates and staff-notes. Hidden from regular members.

Read-only public channels are reserved for maintainers. Existing general chat was preserved. Help and Workshop voice were removed; Showcase was replaced only after checking that it contained no member posts.

## Roles and pings

Optional notification roles: UI releases, Model releases, VFX releases, Luau releases, Community updates, Events. Each grants zero permissions, has no role color, and is not publicly mentionable.

Studio builder and Agent builder are optional identity roles available in Channels & Roles. Contributor is available for manual assignment. Moderator and Maintainer are configured but unassigned; the owner chooses who receives them.

Regular members cannot mass-mention. Maintainer can publish in the read-only channels but does not receive mass-mention permission. The owner can post a relevant role ping. Routine posts should not use everyone or here.

For a future automated release publisher, pass only the selected role ID in `allowed_mentions.roles`; keep `allowed_mentions.parse` empty. No setup messages pinged a role or everyone.

## UI requests

The forum requires a tag and displays a reference checklist. Each request needs:

- A screenshot of every frame or panel to be copied, including important states.
- A full walkthrough video showing animations, transitions, hover/click feedback, scrolling, opening, and closing.
- The reference source, requested scope, and target devices.

The pinned guide repeats the checklist. Moderator-only status tags are Needs references, Under review, Planned, and Completed. Reference completeness is reviewed by a person; native forum settings cannot verify that a video demonstrates every interaction.

## Kit reports and contributions

The kit issue guide requests version/source, reproduction steps, expected and actual results, environment, errors, modifications, and visual evidence. Its attached [agent prompt](report-kit-issue.txt) gathers a report without modifying the project. Suggestions links directly to GitHub pull requests.

## Release-facing links and remaining settings

Public Discord copy links directly to GitHub as requested. Repository visibility and pack licenses were not changed by this Discord update.

Role colors follow the [brand palette](../../docs/BRAND.md). Discord rejected the bot role hierarchy reorder; an owner must order staff above contributor and builder identities. Colors were applied successfully.

The server does not currently expose the BANNER feature. Channel banners are installed; a native server-header banner was not applied.

Rules are published in the designated Community rules channel. Native membership-screening acknowledgment and the separate Server Guide UI were not configured. The documented bot API does not expose those setup flows, and desktop control was stopped. The start-here guide and native onboarding provide the configured welcome flow.

## Verification

[verification.json](verification.json) records API readback of Community, onboarding requirements, role permissions, embed ordering, message pins, and mention behavior. The forum guide is pinned as a thread via its channel flag. A real new-member client walkthrough was not performed.

[server-map.json](server-map.json) maps all channel, role, icon, and message IDs. [copy.json](copy.json) contains the deployed public copy. [onboarding.json](onboarding.json) contains the returned configuration.

API references: [Discord guild and onboarding documentation](https://github.com/discord/discord-api-docs/blob/main/developers/resources/guild.mdx), [Discord message documentation](https://github.com/discord/discord-api-docs/blob/main/developers/resources/message.mdx).
