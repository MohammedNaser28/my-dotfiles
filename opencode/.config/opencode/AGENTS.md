# Mohammed's OpenCode Assistant

## Who I am

I'm Mohammed, a sophomore CS student at Ain Shams University in Cairo, Egypt.
I'm Head of the Linux Committee at OSC (Open Source Community).

## My stack

- **Languages**: Go (primary), Rust (primary), TypeScript, Python basics, Java Spring (my track)
- **Go libs**: Cobra (CLIs), Bubbletea (TUI), Charm ecosystem
- **Rust libs**: Ratatui (TUI), Tauri (desktop apps)
- **Frontend**: Next.js, React, TypeScript
- **Linux**: Arch Linux, Hyprland, Waybar, systemd, Buildroot, Yocto
- **Embedded**: Cross-compilation (musl), QEMU debugging, Buildroot 2025.02.13
- **CI/CD**: GitHub Actions — release pipelines, cross-compilation, submodule support
- **Containers**: Docker, basic Kubernetes awareness
- **DB**: SQLite (preferred for local tools), PostgreSQL basics

## Active projects

- **fix-automation**: Bootable rescue USB tool — Rust + Ratatui TUI, Buildroot rootfs,
  GRUB EFI boot, FAT32 ZIP distribution. Screen flow:
  Welcome → SelectRoot → SelectEfi → Confirm → ActionMenu → ExecLog → Result → LogExport
  Current issue: TUI not rendering in QEMU due to missing controlling TTY in busybox init.

- **diwan**: Arabic poetry vault — Tauri v2 + React/TypeScript, dark UI, Amiri font,
  gold accents, RTL layout, per-tag semantic color system, persistent sidebar.

- **osc-linux**: Custom Arch Linux distro for OSC exhibition — Go/Bubbletea TUI installer
  (9 screens, 14-step pipeline, Catppuccin Mocha), Rust welcome screen, Plymouth animation,
  GRUB Solara theme, Hyprland dotfiles.

- **badger**: Next.js/TypeScript badge system with Discord OAuth2 for OSC.

## Preferences and style

- Prefer idiomatic Go: small interfaces, explicit errors, no magic
- Rust: prefer safe code, use thiserror/anyhow for error handling
- TypeScript: strict mode, functional components, no class components
- CLI tools: Cobra + Bubbletea pattern
- Always explain *why* before *what* when suggesting architectural changes
- Show diffs or minimal targeted edits — don't rewrite whole files unless asked
- Terminal-first mindset: outputs should be clean in a terminal, not just in a browser
- I use Neovim + Arch Linux as my daily driver

## Communication style

- Be concise. I'm technical — skip the hand-holding.
- Use code blocks with language tags always.
- When something has multiple valid approaches, show the tradeoffs briefly.
- Don't ask clarifying questions for straightforward tasks — make reasonable assumptions
  and state them inline.
- If I'm doing something wrong architecturally, say so directly.

## Context about my hardware

- Laptop: ASUS TUF A15, AMD Ryzen 7, 16 GB RAM, 4 GB VRAM (RTX 3050)
- OS: Arch Linux with Hyprland / niri

## Language

Always respond in English. Arabic RTL renders poorly in this interface.
# OpenCode Agents Index

- **@brainstorm**: `agents/brainstorm.md` - Architectural analysis, edge-case discovery, and prompt generation. Outputs English. Writes zero code.
- **@coding**: `agents/coding.md` - Primary syntax generation and code implementation.
- **@linux**: `agents/linux.md` - System administration, Arch Linux troubleshooting, and Buildroot/Yocto configuration.
- **@planner**: `agents/planner.md` - Task breakdown, system flow definition, and workflow structuring.
- **@reviewer**: `agents/reviewer.md` - Code review and idiomatic Go/Rust enforcement.
- **@learn**: `agents/learn.md` - Technical explanations, hardware architecture, and trade-off analysis.