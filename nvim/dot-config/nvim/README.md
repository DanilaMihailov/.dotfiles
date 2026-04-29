# Neovim config

- vim.pack for plugins
- `plugin` containing plugins, that are autoloaded by nvim (and `ftplugin`)
- init.lua with basic options and keymaps

## Local code review

`code_review` is a local-first review helper under `lua/code_review/`.

- `:CodeReviewStart branch` - review current branch against auto-detected `main`/`master`
- `:CodeReviewStart worktree` - review current working tree, including untracked files
- `:CodeReviewAnnotate` - annotate current line, or a visual range
- `:CodeReviewNotes` - open the notes scratch buffer
- `:CodeReviewCopy` - copy unresolved notes as markdown for Codex CLI
- `:CodeReviewResolve` / `:CodeReviewReopen` - update note status
- `:CodeReviewClose` - manually close the current session
- `:CodeReviewResetBase` - reset gitsigns review base and close quickfix

Notes are stored outside the repo under Neovim state, one JSON file per repo.
