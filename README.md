# Overview

This repository contains assignment starter code for buildroot based assignments for the course Advanced Embedded Software Design, ECEN 5713.

It also contains instructions related to modifying your buildroot project to use with supported hardware platforms. See [this wiki page](https://github.com/cu-ecen-5013/buildroot-assignments-base/wiki/Supported-Hardware) for details.

## Assignment 4 Part 2 Summary

### Architecture-level updates
- Added a complete Buildroot external tree interface (`external.desc`, `Config.in`, `external.mk`) under `base_external` using `project_base` as the external name.
- Completed the `aesd-assignments` package integration using Buildroot `generic-package` + git site method over SSH, including installation of `writer`, `finder.sh`, `tester.sh`, and `finder-test.sh` into `/usr/bin`.
- Added host automation scripts to standardize clean/configure/build/boot workflows:
  - `clean.sh` for `distclean`
  - `configure-ssh-build.sh` for menuconfig-driven SSH image setup + validation + build
  - `boot-test-cycle.sh` for full clean/build/build/boot orchestration
- Updated build policy to use `${HOME}`-relative cache/download paths (`BR2_DL_DIR=${HOME}/.dl`, `${HOME}/.buildroot-ccache`) to improve rebuild speed and portability.

### Work log (hash + date)
- `1e30a17` — 2026-02-07 — Baseline repository state with buildroot submodule registration.
- `f476c87` — 2026-02-07 — Added external package integration, finder test script behavior updates, and assignment automation/report artifacts.

## Assignment 5 Part 1 Summary

### Architecture-level updates
- Extended `aesd-assignments` Buildroot package build rules to compile both `finder-app` and `server` with `TARGET_CONFIGURE_OPTS`, ensuring `aesdsocket` is cross-compiled for the target architecture.
- Extended install rules to stage `aesdsocket` at `/usr/bin/aesdsocket` and register `aesdsocket-start-stop` as `/etc/init.d/S99aesdsocket` for boot-time service management.
- Updated `runqemu.sh` networking to keep SSH passthrough (`10022 -> 22`) and add socket forwarding (`9000 -> 9000`) so host tools can reach the VM service directly.
- Added assignment planning and review artifacts (`plan-assignment5-part1.md`, `code-review-assignment5-part1.md`) documenting pseudocode-driven implementation and engineering rationale.

### Work log (hash + date)
- `d5fc178` — 2026-02-14 — Implemented assignment 5 part 1 package, QEMU forwarding, and technical planning/review documentation.
