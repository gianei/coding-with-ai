# Personal Preferences

When asked to create MD files, create them on the root of current working directory.

## Git

### Commits

Always prefix commit messages with `[TICKET-ID]`. If the current ticket is unknown, default to `[ADHOC]`.

### Branch naming

For ticket work, use `gianei/<TICKET_ID>`. Do not append a slug or description.

## Code style

Two rules govern comments and docs:

1. **No feature-describing prose.** Do not write comments or KDoc that restate what a function/class does feature-wise — "loads the user cart", "this wraps X", "ViewModel for the checkout screen". If a reader can derive it from the name and signature, ship no comment.

2. **No redundant or trivial commentary.** Do not comment simple things just to label them ("// reset state", "// emit loading"). Sign-flipping a value or returning a bounded delta does NOT qualify as worth commenting. The bar for "worth a comment" is high.

Comments are reserved for **genuinely non-obvious logic**: subtle invariants, why a workaround exists, ordering constraints that aren't visible from the call site, anything a reader would otherwise misread. KDoc is fine as the *format* when the content meets that bar — prefer it over inline blocks above declarations. Inline `//` is fine inside a function body.

After finishing a change, sweep the diff and delete any comment that just describes the feature or restates the code.

### Avoid subshells and `$(...)` — they break static analysis

These forms always prompt, even when each inner command is read-only ([ref](https://github.com/EveryInc/compound-engineering-plugin/issues/816)):
- `(cmd1; cmd2)` — subshell wrapping
- `$(cmd)` / `` `cmd` `` — command substitution
- `<(...)` / `>(...)` — process substitution

**Default: split into multiple parallel Bash calls** instead of one compound command — each runs through the read-only fast path independently. If you must chain, use flat `cmd1 ; cmd2` (no parens), where every subcommand is in the built-in read-only set or explicitly allow-listed.

### Never use `find -exec` or `find -delete` (always prompts)

Per the official permissions docs: `find -exec` and `find -delete` **always** prompt and **cannot** be auto-approved — not by `Bash(find:*)`, not by `Bash(find * -exec *)`, not by any prefix rule. Same for exec wrappers like `watch`, `setsid`, `ionice`, `flock`.

This includes the seductive `find . -exec grep -l "pattern" {} \;` pattern — it will always prompt. Use one of these instead, all of which run with zero prompts:

| Goal | Use instead | Why no prompt |
|------|-------------|---------------|
| Find files containing a string | **Grep tool**, or `grep -rl "pattern" dir/` | `grep` is built-in read-only |
| Find files by name only | **Glob tool**, or plain `find . -name "*.kt"` | `find` (without `-exec`/`-delete`) is built-in read-only |
| Pipe found files to a command | `find ... -print0 \| xargs -0 <cmd>` — but only if `<cmd>` is itself allowed. Bare `xargs` (no flags) is stripped, so `xargs grep pattern` is matched as `grep pattern` | `xargs` is stripped by the matcher when it has no flags |
| Delete found files | `rm` the files explicitly after locating them, or use the Glob/Read tools to confirm first | `find -delete` always prompts |

Other read-only builtins that never prompt: `ls cat echo pwd head tail grep find wc which diff stat du cd` plus read-only `git` subcommands (`status`, `log`, `diff`, `show`, `branch -l`, etc.).

**Gotcha:** unquoted globs on `find`, `git`, `sort`, `sed` re-trigger the prompt because the glob could expand to a write-capable flag like `-delete`. Quote the pattern (`find . -name "*.kt"`) to stay in the read-only path.

## Tool Usage (Non-Negotiable)

Bash is fine. The problem is long, chained, approval-triggering bash — not bash itself.

- **Keep Bash simple:** one command, one purpose. No `&&`-chained mega-commands, no `echo "==="`/`######` banners, no decorative/formatted output, no orientation scripts. A bare `ls`, `git status`, or single `find` is fine.
- **Keep Bash sandboxed so it auto-approves.** Don't reach for unsandboxed / `dangerouslyDisableSandbox` for routine work — that's what forces a manual prompt. (Git network/GPG ops are the sanctioned exception per org policy.)
- **Prefer built-in tools when they fit:** `Read` to view files; `Edit`/`Write` to change them (not `sed`/`awk`/`perl -i`/heredoc rewrites); `Glob`/`Grep`/`LS` for search where present, else delegate fan-out search to an `Explore` subagent.
- **GitOps & platform work:** reach for the MCP tool (github, etc.) before shelling out.

This correction has been given in nearly every session. Honor it by default, not on reminder.

## GitHub comments

When posting any comment on GitHub under my name (PR comments, issue comments, review comments, replies — via `mcp__github-gateway__*` or `gh` CLI), start the comment body with this blockquote header on its own line:

```
> 🤖 Antigravity
```

Then leave a blank line and write the content. This makes it clear to other reviewers that the comment was authored via Antigravity on my behalf.

### Atomic Commits

Please make commits atomic. Each commit should encompass a single logical change. Do not group unrelated changes into a single commit.
