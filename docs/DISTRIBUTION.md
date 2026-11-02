# Distribution

## Start simple

Keep editable source, documentation, previews, and small current exports in Git. Use a versioned ZIP per pack for downloads instead of asking users to download the entire monorepo. Keep generated ZIPs in the ignored `release-builds/` directory, not committed alongside every version.

Suggested ZIP contents:

```text
inventory-ui-1.0.0/
  inventory-ui.rbxm
  inventory-ui-demo.rbxl    # optional
  README.md
  LICENSE
  CREDITS.md
  CHANGELOG.md
```

For larger files or frequent binary revisions, consider release attachments or dedicated asset storage rather than growing Git history indefinitely.

## Private now, public later

This repository and its releases are private. Anonymous developers cannot download from them. Choose one of these when ready:

1. Make the repository public after reviewing its files and history; publish downloads using GitHub Releases.
2. Keep this source repository private and deliberately publish approved ZIPs to a separate public downloads repository or website.

Do not expose a GitHub token in a download website. No public distribution has been configured by this starter.

Suggested per-pack tag: `ui/inventory-ui/v1.0.0`. Each release should identify the pack, changes, install steps, and license.

## Release checklist

- [ ] Replace all template placeholders and set a real version.
- [ ] Export a working model and test installation in a fresh place.
- [ ] Test supported screen sizes and input methods.
- [ ] Document exact instance destinations and any required setup.
- [ ] List external asset IDs, permissions, and dependencies.
- [ ] Inspect scripts and remove secrets or unrelated private content.
- [ ] Confirm rights to redistribute every included asset.
- [ ] Add a license and synchronize its identifier in `pack.json`.
- [ ] Add screenshots and update changelog.
- [ ] Package and test the actual downloaded ZIP.
- [ ] Set status to `released` and update the root catalog with download links only once available.
