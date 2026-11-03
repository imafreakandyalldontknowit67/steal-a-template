# Discord community kit

[Open the server](https://discord.com/channels/1566964411401371769/1566966689818611732)

This folder contains deployed artwork, copy, configuration, and API verification. No bot token or persistent bot process is included.

## Member path

Start here → rules → GitHub asset library → general, project posts, UI requests, or a build room. Optional onboarding questions suggest channels and let members choose notification topics and their main agent. These choices do not gate access to public channels.

## Channels

- Start here: start-here, rules, announcements, asset-library.
- Community: general, showcase (forum), ui-requests (forum), bug-reports.
- Voice channels: Build room 1, Build room 2, Build room 3. Voice, screen sharing, and room chat are allowed.
- Staff: community-updates and staff-notes, hidden from regular members.

Help, Suggestions, and the old Workshop voice channel were removed. General has a text-only guide. Showcase was converted after checking there were no member posts to lose.

## Embeds and artwork

Seven live banner guides use an image-only embed followed by the body and link buttons. Body embeds omit titles already present in the banners. Bold labels, numbered sections, spacing, and quote bars organize the text; there are no emojis in written copy.

[Profile](assets/profile.png) is applied to the server and setup bot. [Banners](assets/banners/) use the GitHub hero character. General and Suggestions artwork is retained as source material but is not deployed. [Artwork notes](ARTWORK.md) record generation prompts and editable sources.

## Roles and onboarding

Hierarchy: setup bot → Maintainer → Moderator → Contributor → Member → agent identities → notification roles. Staff and Member use the [brand palette](../../docs/BRAND.md). Agent identities and all notification roles have no color and grant no permissions.

Notification topics: UI releases, Model releases, VFX releases, Luau releases, Community updates, Events. All are optional and not publicly mentionable. Routine posts should not use everyone or here. Automated posts must allow only their selected role ID in allowed_mentions.roles.

The optional single-choice question “Which agent do you use most?” offers Codex, Claude Code, Cursor, GitHub Copilot, Other agent, and No agent. Members can skip it or change their choice later. Recognizable product icons identify Codex, Claude Code, Cursor, and GitHub Copilot; Other agent and No agent use generic symbols. [Sources](assets/icons/sources/sources.json) are recorded. Add future tools by adding a colorless role, icon, and onboarding option; Other agent covers tools not yet listed. Studio builder and Agent builder were removed.

Selecting any onboarding option grants Member. Skipping every question preserves normal access via everyone; assigning Member to every future join would require a running automation. Staff roles remain manually assigned.

## Requests and reports

UI requests require a full walkthrough video and a screenshot of every requested frame or panel, plus scope, source, and target devices. Staff review completeness; native forum settings do not inspect video contents.

Kit reports collect kit/version/source, reproduction steps, expected and actual results, environment, errors, modifications, and visual evidence. The [agent report prompt](report-kit-issue.txt) is attached to the live guide. Repository fixes and improvements can go through GitHub pull requests, linked in asset-library.

## Verification and limits

Community, native onboarding, welcome screen, and mention-spam AutoMod are enabled. [verification.json](verification.json) records the latest API readback. No real new-member client walkthrough was performed.

The initial role API response gave every non-everyone role position 1. A single-role update normalized the positions, after which the full hierarchy reorder succeeded. No owner role movement was required.

Role icons beside chat names are also boost-gated: Discord rejected the upload with HTTP 403 / code 50101. Onboarding logos are live; [the role icon manifest](role-icons.json) maps the prepared PNGs to their roles for later application. No boosts were purchased. Native server-header artwork is unavailable at the current server tier. Separate membership-screening acceptance and Server Guide UI were not configured. Public copy links to GitHub; this setup did not change repository visibility or licenses.

[Server IDs](server-map.json) · [Public copy](copy.json) · [Onboarding configuration](onboarding.json)
