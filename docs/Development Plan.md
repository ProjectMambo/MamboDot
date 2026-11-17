---
title: Development plan
description: Maintenance stages, exit gates, compatibility triggers, and risks for the active MamboDot workstation.
order: 35
---

::page{layout="docs" width="normal" sidebar=true}

# Development plan

MamboDot is in active maintenance. Its intended Arch Linux, Hyprland, AGS, application-configuration, and FA507XV host scope is implemented; the [roadmap](Roadmap.md) preserves the completed delivery history. This plan governs what happens next without inventing a feature backlog for a workstation that already serves its intended daily use.

The plan is authoritative for maintenance order, not a promise of calendar dates. A change starts from observed evidence, moves through the smallest owned fix and relevant live acceptance, then synchronizes documentation and delivery.

## Current state

The repository has guarded Stow deployment, package and service inventories, a machine doctor, Lua-driven Hyprland configuration, one systemd-supervised AGS/Astal shell, stable application leaves, explicit host policy, and focused regression checks. All 29 broad delivery phases in the roadmap are implemented. Recent work is incident-driven compatibility and reliability repair rather than unfinished product construction.

There is no open feature phase. The only known operational follow-ups are one physical hibernate/resume acceptance check after the latest guard changes and two optional privileged host cleanups: remove unsupported `thermald`, and unlink the inert TLP enablement entry before any future TLP installation. Neither justifies a new architecture or speculative automation.

## Target maintenance state

Keep the current workstation reproducible, secure, and dependable through Arch, Hyprland, AGS, application, firmware, and hardware changes. Every maintenance increment should preserve a known-good login path, explicit password fallback for authentication, safe Stow recovery, and one clear owner for session, power, notification, and configuration behavior.

MamboDot remains a personal FA507XV workstation profile. It does not aim to become a distribution-neutral desktop framework, unattended installer, general hardware-control daemon, secret store, session backup system, or compatibility-tested configuration for machines the maintainer does not use.

## Scope and evidence triggers

Maintenance work enters the plan only through one of these triggers:

| Trigger | In scope | Deliberately deferred |
|---|---|---|
| Reproducible daily-use failure | Minimal fix at the existing owner, regression coverage where practical, recovery behavior, and current documentation | Redesigns unrelated to the failure |
| System, compositor, shell, application, or firmware upgrade | Required API, configuration, package, service, and host-policy compatibility changes | Pre-emptive compatibility layers for uninstalled versions |
| Stable configuration leaf discovered through ordinary use | Credential-free leaf with a clear owner that remains unchanged during normal use | Browser/Electron profiles, histories, databases, generated state, learned input data, and mixed volatile preference files |
| Repeated failure exposes an ownership problem | Small architecture change that removes competing writers or ambiguous lifecycle ownership | New frameworks, daemons, abstractions, or options without repeated evidence |
| Supported hardware or application is retired | Remove its configuration only after a replacement path and rollback boundary are known | Cleanup that would break the active workstation merely to reduce file count |

## Architecture and ownership

| Boundary | Owner and maintenance rule |
|---|---|
| Portable user configuration | Direct children of `dot/` are GNU Stow packages; link and unlink only through the guarded repository command |
| Desktop behavior | Hyprland owns compositor policy; AGS/Astal owns the bar, launcher, panels, tray presentation, and notification UI; the systemd user target owns their lifecycle |
| Host inventory and diagnosis | `manifest/` records reviewed packages and services; `doctor` reports drift but never installs, enables, or rewrites the host |
| Privileged and hardware policy | `system/hosts/fa507xv/` records individually applied policy and patched package recipes; it is never ordinary Stow input |
| Shared colour contract | `vendor/mambocolour/` pins one reviewed provider revision; generated Hyprlock and AGS adapters remain MamboDot-owned |
| Documentation | Canonical pages live in the Notes workspace and synchronize into MamboDot and MamboWiki |
| Personal and volatile data | Credentials, cookies, vault state, histories, caches, databases, device state, and session state stay outside Git |

Authentication, power, sleep, package, and root-policy changes cross a trust boundary. They must retain password fallback, avoid logging secrets or notification bodies, and never weaken hibernation or device protection to make an integration appear convenient.

## Stage 0: Bound the incident or improvement

Start from an observed failure, host drift report, upgrade delta, or stable configuration leaf. Reproduce it when safe, identify the current owner, inspect every affected caller and lifecycle edge, and record any physical behavior that cannot be automated. Preserve unrelated worktree changes and do not broaden the supported hardware or application scope implicitly.

Exit gate: the current and desired behavior are distinguishable, the smallest affected boundary is known, recovery or rollback is identified, and the required narrow, repository, and physical checks are listed.

## Stage 1: Apply the smallest owned change

Change the existing owner instead of adding a competing script, daemon, setting, or state store. Update affected callers, tests, fixtures, manifests, host files, and canonical documentation in the same increment. A stable leaf must pass the configuration-ownership rules before entering Stow. A privileged file must remain explicit and individually reviewable.

Exit gate: the focused reproduction passes, failure behavior remains safe, relevant regression coverage exists where practical, and no credential, runtime state, or unrelated host preference entered the diff.

## Stage 2: Prove workstation compatibility

Run the narrow checks first and the full repository gate for any executable or configuration change. Exercise only the live journeys reached by the change: login and authentication, monitor hotplug, fullscreen and Fcitx overlays, tray menus, screenshots, idle/lock, or suspend/hibernate and recovery. Hardware-dependent acceptance stays manual and explicit rather than being reported as automated evidence.

Exit gate: automated checks pass, the affected live journey works on the FA507XV, a failed service or reload has a documented recovery path, and the machine returns to a usable session without hidden competing owners.

## Stage 3: Synchronize and deliver

Update canonical Notes documentation, synchronize MamboDot and MamboWiki, inspect every generated change, and run each repository's gate. Commit only scoped files, deliver the canonical provider before generated consumers, and leave unrelated local settings untouched.

Exit gate: MamboDot and MamboWiki contain the same current contract, their checks pass, intended commits are pushed, and the worktree contains no new unexplained change.

## Data, compatibility, and recovery

MamboDot owns configuration, not user data, so it has no database migration path. Git history is the configuration rollback source. Stow operations preview the complete action and never adopt conflicting home files; after a rollback, relink only reviewed affected packages. Root policy is recovered by restoring the previously reviewed file or package and applying it deliberately, not by an automatic repository rollback.

Rolling-system compatibility is evidence-driven. Preserve the existing interface until the installed provider changes, then update the smallest consumer boundary and record the new assumption. Vendored MamboColour updates remain provider-pin changes with regenerated adapters and full consumer checks.

## Validation

Use the narrow check for the touched surface, then the documented repository gate when runtime configuration changes:

~~~bash
bash -n script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh dot/script/.local/bin/powermenu.sh
shellcheck script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh dot/script/.local/bin/powermenu.sh
lua script/sync_mambocolour.lua --check
./script/test.sh
find dot/hypr/.config/hypr -name '*.lua' -print0 | xargs -0 -n1 luac -p
Hyprland --verify-config --config "$PWD/dot/hypr/.config/hypr/hyprland.lua"
git diff --check
~~~

Run `./script/mambodot.sh doctor` when a change affects packages, services, links, or host drift. Documentation-only changes require synchronization, generated-diff review, MamboWiki's documented check, and diff validation; they do not require disruptive physical desktop tests.

## Maintenance milestones

| Milestone | Outcome |
|---|---|
| Daily-driver baseline — achieved | The implemented roadmap supplies the complete intended workstation configuration and shell |
| Maintenance increment | One observed problem or evidence-backed improvement passes Stages 0 through 3 without expanding scope accidentally |
| Compatibility review | A material platform upgrade is reconciled across configuration, manifests, live behavior, and documentation |
| Retirement | A replaced application, service, or hardware path is removed only after the replacement and recovery path are proven |

No maintenance increment is complete while an earlier exit gate is open. Detailed bug churn belongs in issues, branches, and commits; this page changes only when ownership, trust boundaries, maintenance stages, compatibility rules, or supported scope changes.

## Known risks

- Rolling Arch and upstream Hyprland, AGS, Astal, PAM, and application changes can invalidate working configuration without repository changes.
- Several acceptance paths depend on the physical FA507XV, its camera, GPU, displays, firmware, and sleep state and cannot be fully proven in a headless test.
- Tracking volatile application files would create noisy commits or expose private state; add a leaf only after ordinary-use stability is observed.
- A second writer for power, idle, notification, authentication, or shell lifecycle can reintroduce failures that static validation misses.

Introduce a new delivery phase only when repeated evidence cannot be handled by this maintenance loop or when the supported workstation scope deliberately changes.
