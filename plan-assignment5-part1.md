# Assignment 5 Part 1 Implementation Plan

## Objective
Update the Buildroot external package and QEMU launcher so `aesdsocket` is cross-compiled, installed into the target rootfs, started by init, and reachable from the host over port forwarding.

## Step-by-step Plan

### 1) Extend Buildroot package build commands
**Pseudocode Block 1**
```text
SET package git source metadata (version/site/site method/submodules)
WHEN Buildroot enters build phase:
  RUN make in finder-app with TARGET_CONFIGURE_OPTS
  RUN make in server with TARGET_CONFIGURE_OPTS
```

Implementation approach:
- Keep deterministic source pinning for repeatable grading.
- Reuse `TARGET_CONFIGURE_OPTS` so `CC`, `LD`, and other cross-toolchain flags are injected by Buildroot.
- Build both existing finder utilities and new server binary in one package rule.

### 2) Extend Buildroot package install commands
**Pseudocode Block 2**
```text
WHEN Buildroot enters install-target phase:
  CREATE /etc/finder-app/conf and copy conf files
  CREATE /usr/bin and copy writer/finder.sh/finder-test.sh
  COPY server/aesdsocket to /usr/bin/aesdsocket
  CREATE /etc/init.d
  COPY server/aesdsocket-start-stop to /etc/init.d/S99aesdsocket
```

Implementation approach:
- Preserve assignment-4 installs and add assignment-5 artifacts.
- Place executable in `/usr/bin` for shell PATH compatibility.
- Name init script `S99aesdsocket` to ensure late startup ordering during boot.

### 3) Update QEMU run helper networking
**Pseudocode Block 3**
```text
LAUNCH qemu-system-aarch64 with existing VM args
CONFIGURE user-mode network forwarding:
  host tcp 10022 -> guest 22
  host tcp 9000  -> guest 9000
```

Implementation approach:
- Keep SSH workflow unchanged for test automation.
- Add socket service forwarding to support host-side validation using `nc localhost 9000`.

### 4) Produce documentation and review artifacts
**Pseudocode Block 4**
```text
CREATE code-review-assignment5-part1.md
FOR each pseudocode block:
  INCLUDE pseudocode
  EXPLAIN architectural rationale, syntax choices, and conventions
UPDATE README with assignment 5 summary + dated git hash log
```

Implementation approach:
- Write review notes at “junior developer onboarding” depth.
- Capture architectural tradeoffs (single package, init integration, network forwarding).
- Track commit hashes and dates for auditability.

## Validation Plan
- Run `bash -n runqemu.sh` for shell syntax validation.
- Run `git diff --check` to catch whitespace/formatting issues.
- Optionally run a Buildroot package build in local workflow to validate target compile/install behavior.
