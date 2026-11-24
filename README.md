# kvmd-debian

Debian packages for [PiKVM](https://pikvm.org)'s [kvmd](https://github.com/pikvm/kvmd) and
[ustreamer](https://github.com/pikvm/ustreamer), for Debian 13 (trixie) and Raspberry Pi OS, built
against Debian's own Python.

## Scope

**Packaging of upstream only.** Patches here exist only to make upstream run on Debian, never to add
features. Today that is:

- `kvmd`: a build step that adds `from __future__ import annotations` to every module when building
  with Python older than 3.14 (upstream targets 3.14's lazy annotations), and patch 0001, which makes
  `kvmd-otg` tolerate kernels without PiKVM's CD-ROM inquiry-string patch.
- `ustreamer`: no patches; built with systemd support only (no GPIO, DRM pass-through or Janus).

Site-specific configuration (overrides, EDIDs, extra tools) belongs in the machine's own repository.

## Packages

| Package | From |
|---|---|
| `ustreamer`, `python3-ustreamer` | ustreamer, tag and commit in `versions.env` |
| `kvmd` | kvmd (Python, architecture-independent) |
| `kvmd-platform-v2-hdmi-rpi4` | kvmd's per-board configuration: Raspberry Pi 4 with a TC358743 HDMI-to-CSI bridge |

Services are installed but not enabled. The boot configuration (`dtoverlay=tc358743`,
`dtoverlay=dwc2,dr_mode=peripheral`) is left to the administrator.

## Building

```
./build.sh ustreamer      # on an arm64 host with Docker (arm64 packages)
./build.sh kvmd
```

Each build runs in a clean `debian:trixie` container, checks that the pinned tag resolves to the
pinned commit, and leaves the `.deb` files in `out/`.

## Licence

GPL-3.0, as upstream.
