# Assignment 5 Part 1 Code Review Notes

This review maps each pseudocode block to the implemented code and explains architectural intent, conventions, and syntax choices.

---

## Pseudocode Block 1 — Build phase in Buildroot package
```text
SET package git source metadata (version/site/site method/submodules)
WHEN Buildroot enters build phase:
  RUN make in finder-app with TARGET_CONFIGURE_OPTS
  RUN make in server with TARGET_CONFIGURE_OPTS
```

### Why this structure
- **Single package, multiple build targets:** keeping `finder-app` and `server` in one package ensures all assignment binaries come from one pinned source revision. This avoids drift across repos/versions.
- **Cross-compilation correctness:** `$(TARGET_CONFIGURE_OPTS)` is a Buildroot convention that exports target `CC`, `AR`, `LD`, `STRIP`, and related flags. Passing this into both `make` invocations prevents accidental host compilation.
- **Explicit `-C` directory builds:** `make -C path` is preferred over shell `cd` pipelines because it's clearer in logs and easier for Buildroot to report errors by subdirectory.

### Non-trivial syntax notes
- `define ... endef` is GNU Make multiline variable/function syntax used by Buildroot package infrastructure.
- `$(@D)` refers to the extracted source directory for the package during build.

### Resource references
- Buildroot manual: *generic-package tutorial* and package hooks.
- GNU Make manual: `-C` option and variable expansion semantics.

---

## Pseudocode Block 2 — Install phase in Buildroot package
```text
WHEN Buildroot enters install-target phase:
  CREATE /etc/finder-app/conf and copy conf files
  CREATE /usr/bin and copy writer/finder.sh/finder-test.sh
  COPY server/aesdsocket to /usr/bin/aesdsocket
  CREATE /etc/init.d
  COPY server/aesdsocket-start-stop to /etc/init.d/S99aesdsocket
```

### Why this structure
- **Backward compatibility:** assignment 4 tooling (`writer`, `finder.sh`, `finder-test.sh`, config files) remains installed so existing tests still pass.
- **Runtime discoverability:** `/usr/bin/aesdsocket` aligns with standard executable lookup locations, minimizing absolute-path dependencies in init scripts and manual testing.
- **Init integration decision:** installing as `/etc/init.d/S99aesdsocket` follows SysV-style startup conventions used in Buildroot BusyBox init environments.
  - Prefix `S` => start script on boot.
  - Numeric priority `99` => late-start behavior after base networking and common services.
- **Deterministic permissions:** `-m 0755` explicitly marks executables/scripts runnable in target filesystem regardless of source repo mode bits.

### Non-trivial syntax notes
- `$(INSTALL) -d` creates directories idempotently.
- `$(TARGET_DIR)` is Buildroot’s destination rootfs staging directory; writes here become part of the generated image.
- `$(BR2_EXTERNAL_project_base_PATH)` references this external tree, used for local wrapper script installation.

### Workarounds and conventions
- Kept `finder-test.sh` sourced from external package path (instead of upstream repo) to preserve local assignment customizations already present in the project.

---

## Pseudocode Block 3 — QEMU networking updates
```text
LAUNCH qemu-system-aarch64 with existing VM args
CONFIGURE user-mode network forwarding:
  host tcp 10022 -> guest 22
  host tcp 9000  -> guest 9000
```

### Why this structure
- **Maintains current developer workflow:** preserving `10022 -> 22` means existing SSH commands and scripts continue to work unchanged.
- **Adds direct service test path:** forwarding `9000 -> 9000` allows host-side validation (`nc`, `telnet`, or custom client) without bridging/tap setup.
- **Minimal-risk change:** updates only the `-netdev user,...` argument, avoiding unrelated VM boot parameter churn.

### Non-trivial syntax notes
- Multiple `hostfwd` rules are comma-separated within the same `-netdev user` argument.
- `-nographic` remains intentional so serial console is accessible from the launching terminal for CI/headless grading.

---

## Pseudocode Block 4 — Planning and reporting artifacts
```text
CREATE code-review-assignment5-part1.md
FOR each pseudocode block:
  INCLUDE pseudocode
  EXPLAIN architectural rationale, syntax choices, and conventions
UPDATE README with assignment 5 summary + dated git hash log
```

### Why this structure
- **Traceability:** pairing pseudocode and implementation rationale provides a clear audit trail from plan -> code -> review.
- **Mentorship focus:** commentary is written for a junior engineer audience to explain not only *what* changed but *why these primitives* were selected.
- **Release engineering visibility:** README work logs with hash/date allow reviewers and graders to quickly map repository state to expected assignment milestones.

---

## Architectural decisions summary
1. **Keep assignment functionality centralized in one Buildroot package** instead of splitting finder/server into separate packages.
2. **Use Buildroot-provided toolchain variable injection** rather than manual `CROSS_COMPILE` plumbing.
3. **Use SysV init script installation path and naming convention** for predictable boot integration.
4. **Use QEMU user networking host forwarding** for portability (no elevated privileges or host bridge config required).
