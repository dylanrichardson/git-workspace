# git-workspace

Isolated git workspaces using worktrees with automatic locking for parallel work.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/dylanrichardson/git-workspace/main/install.sh | bash
```

Then follow the instructions to add shell integration to your `~/.bashrc` or `~/.zshrc`.

To update, just re-run the install command.

## Usage

```bash
# In your git repository:
cd my-repo

# Enter an isolated workspace (automatically switches you there)
git-workspace enter

# Work normally - commit, push, etc.
git commit -am "My changes"

# Done? Clean up and return to original location
git-workspace exit

# List all workspaces
git-workspace list

# Remove unused workspaces
git-workspace clean
```

## Why Use This?

Work on multiple tasks simultaneously without branch switching or stashing:
- Each workspace is isolated (separate working directory)
- Shared .git saves disk space vs. multiple clones
- Automatic locking prevents conflicts
- Fast setup (~2-3s vs. 30s+ for clones)

Perfect for:
- Parallel feature development
- AI agents working simultaneously
- Quick context switching

## Advanced Options

```bash
# Named workspaces (reusable)
git-workspace enter --name my-feature
git-workspace exit --name my-feature

# Force delete workspace with uncommitted changes
git-workspace exit --force
```

## How It Works

Uses git worktrees under the hood. Each workspace gets:
- Separate working directory (e.g., `my-repo-a7b3/`)
- Own tracking branch (`workspace-1` → `origin/main`)
- Lockfile for coordination (`.git/workspace-locks/`)

When you acquire a workspace, it's automatically locked. When you release it, the lock is removed and the worktree is deleted.

## Troubleshooting

**"Not in a git repository"**: Run this from inside a git repo
**Stale locks**: Run `git-workspace clean` to remove orphaned workspaces

Run `git-workspace --help` for full documentation.

## License

MIT
