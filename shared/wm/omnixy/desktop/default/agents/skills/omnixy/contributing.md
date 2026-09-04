# Reporting Issues and Submitting PRs

Read this when the user wants to report an Omnixy bug, suggest a feature, or
contribute a fix upstream.

Omnixy lives at https://github.com/basecamp/omarchy. Route requests to the
right place:

- **Verified bugs** -> GitHub issues. Issues are for validated bugs only, not
  support requests.
- **Feature ideas and suggestions** ->
  https://github.com/basecamp/omarchy/discussions/categories/suggestions
- **Support and "is this a bug?" questions** -> the Discord community at
  https://omarchy.org/discord. Start here when the problem isn't clearly a bug
  in Omnixy itself.

## Filing a Good Bug Report

The bug template asks for system details (CPU, GPU, Omnixy version), a
description with steps to reproduce, and diagnostics. Gather them:

```bash
omnixy version

# Generate the diagnostic log (also written to /tmp/omnixy-debug.log)
omnixy debug --no-sudo --print

# Interactive variant: `omnixy debug` offers to upload the log to
# logs.omarchy.org (expires after 24h) and prints a shareable URL to
# include in the issue.
```

**Capture the problem on screen.** A screenshot or short recording of the bug
is often worth more than the description — see [`capture.md`](capture.md) for
`omnixy capture screenshot` and `omnixy screenrecord`. Keep recordings short
and focused on the misbehavior. GitHub issue attachments are added by
drag-and-drop in the web form, so save the capture and hand the user the file
path to attach (`gh` cannot upload media).

For screen-recording failures specifically, rerun with
`OMNIXY_SCREENRECORD_DEBUG=true` and attach `/tmp/omnixy-screenrecord.log`.

File the issue with `gh` when available:

```bash
gh issue create --repo basecamp/omarchy --title "..." --body "..."
```

Include: what happened, what was expected, steps to reproduce, system details,
the debug log URL (or attached log), and the capture.

## Submitting a PR

Never develop against `/usr/share/omnixy`. Clone a working copy instead:

```bash
gh repo fork basecamp/omarchy --clone
cd omnixy
```

Follow the repository's own `AGENTS.md` for style, testing, and commit
conventions — it is the authority on contributions. Keep commits atomic, run
`./test/all` before pushing, and open the PR with `gh pr create`. A PR that
fixes a visual problem should include before/after captures (again, see
[`capture.md`](capture.md)).
