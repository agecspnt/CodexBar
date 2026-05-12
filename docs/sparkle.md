---
summary: "Sparkle integration details for CodexBar: updater config, keys, and release flow."
read_when:
  - Touching Sparkle settings, feed URL, or keys
  - Generating or troubleshooting the Sparkle appcast
  - Validating update toggles or updater UI
---

# Sparkle integration

- Framework: Sparkle 2.8.1 via SwiftPM.
- Updater: `SPUStandardUpdaterController` owned by `AppDelegate` (see `Sources/CodexBar/CodexbarApp.swift:1`).
- Feed: `SUFeedURL` in Info.plist points to the fork appcast (`https://raw.githubusercontent.com/agecspnt/CodexBar/main/appcast.xml` by default). Override with `CODEXBAR_FEED_URL` when packaging another fork.
- Key: `SUPublicEDKey` defaults to `AGCY8w5vHirVfGGDGc8Szc5iuOqupZSh9pMj/Qs67XI=`. Set `CODEXBAR_SPARKLE_PUBLIC_KEY` when packaging releases signed with a new Sparkle Ed25519 key, and keep the matching private key safe for `SPARKLE_PRIVATE_KEY_FILE`.
- UI: auto-check toggle (About) enables auto-downloads; menu only shows “Update ready, restart now?” once an update is downloaded.
- LSUIElement: works; updater window will show when checking. App is non-sandboxed.
- Channels: stable vs beta are served from the same appcast. Beta items are tagged with `sparkle:channel="beta"`; About → Update Channel controls `allowedChannels`.

## Release flow
1) Build & notarize as usual (`./Scripts/sign-and-notarize.sh`), producing notarized `CodexBar-<ver>.zip`.
2) Generate appcast entry with Sparkle `generate_appcast` using the Ed25519 private key; HTML release notes come from `CHANGELOG.md` via `Scripts/changelog-to-html.sh`. For beta releases: set `SPARKLE_CHANNEL=beta` to tag the entry.
3) Upload `appcast.xml` + zip to GitHub Releases in `agecspnt/CodexBar` (feed URL stays stable).
4) Tag/release.

## Notes
- HTML release notes are embedded in the appcast entry; the Sparkle update dialog should show formatted bullets (not raw tags).
- If you change the feed host or key, update Info.plist (`SUFeedURL`, `SUPublicEDKey`) and bump the app.
- Auto-check toggle is persisted via Sparkle; manual “Check for Updates…” remains in About.
- CodexBar disables Sparkle in Homebrew and unsigned builds; those installs should be updated via `brew` or reinstalling from Releases.
