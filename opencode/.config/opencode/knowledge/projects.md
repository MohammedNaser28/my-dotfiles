# Active project knowledge

## fix-automation

**Goal**: Bootable rescue USB that auto-detects root/EFI partitions and repairs boot issues.

**Stack**: Rust + Ratatui TUI, Buildroot 2025.02.13 rootfs, GRUB EFI bootloader

**Distribution model**: FAT32 ZIP — user unzips to USB, no `dd` required.

**TUI screen flow**:
```
Welcome → SelectRoot → SelectEfi → Confirm → ActionMenu → ExecLog → Result → LogExport
```

**Build**: GitHub Actions CI — cross-compiles to x86_64-unknown-linux-musl, packages ZIP.

**Active bug**: TUI does not render in QEMU.
- Root cause suspected: busybox init doesn't allocate a controlling TTY for the process.
- Ratatui requires a real TTY (not just stdout) to initialize the terminal backend.
- Relevant files: `board/fixauto/rootfs_overlay/etc/inittab`, QEMU `-append` cmdline.
- Things to try: `console=ttyS0`, `setsid`, `openvt`, launching via getty.

---

## diwan

**Goal**: Personal Arabic poetry vault and reader.

**Stack**: Tauri v2 (Rust backend) + React + TypeScript frontend.

**UI**: Dark theme, Amiri font, gold accents (#C9A84C), RTL layout for Arabic text.

**Features**: Per-tag semantic color system, persistent sidebar, animated interactions,
poem CRUD, search.

**Current state**: UI mostly complete, working on poem import and search.

---

## osc-linux

**Goal**: Custom Arch Linux distro for OSC exhibition and community use.

**Stack**:
- Go + Bubbletea: TUI installer (9 screens, 14-step pipeline, Catppuccin Mocha theme)
- Rust: welcome screen app
- Plymouth: 194-frame boot animation, systemd audio workaround
- GRUB: Solara theme
- Hyprland dotfiles bundled

**Release pipeline**: GitHub Actions with submodule support, produces ISO.

**Status**: Stable, released for exhibition.

---

## badger

**Goal**: Badge/certificate system for OSC members.

**Stack**: Next.js + TypeScript, Discord OAuth2, badge design system.

**Status**: In development, OAuth2 flow working.

---

## LFX Mentorship Term 2 (June–August 2026)

Applied to:
1. **OpenEverest `everestctl`** — Go CLI tool
2. **Microcks CLI v2 VS Code Integration** — TypeScript extension (detailed Typst proposal written, based on real codebase analysis)
3. **Harbor Satellite** — Go, container image distribution at the edge

Waiting on results. Preparation: deep codebase reading, proposal writing done.
