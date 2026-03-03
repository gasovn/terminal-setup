# Neovim IDE Cheatsheet

Leader key: `Space`

## Navigation & Search (Telescope)
| Key | Action |
|---|---|
| `<leader><leader>` | Find files (fuzzy) |
| `<leader>fg` | Live grep (ripgrep) |
| `<leader>fb` | Switch buffers |
| `<leader>fr` | Recent files |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |
| `<leader>fd` | Diagnostics |
| `<leader>fh` | Help tags |
| `<leader>fw` | Grep word under cursor |
| `<leader>f/` | Fuzzy find in buffer |
| `<leader>ft` | Find TODOs |
| `<leader>cp` | Command palette |
| `<leader>ck` | Search keymaps |

## File Explorer & Outline
| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer (Neo-tree) |
| `<leader>E` | Reveal current file in explorer |
| `<leader>o` | Toggle code outline (Aerial) |
| `R` (in Neo-tree) | Refresh file tree |
| `Y` (in Neo-tree) | Copy relative path |
| `gy` (in Neo-tree) | Copy absolute path |

### Neo-tree Git Status Icons
| Icon | Meaning |
|---|---|
| ✚ | Added (new tracked) |
| ★ | Untracked |
|  | Modified |
| ✖ | Deleted |
| 󰄱 | Unstaged |
| 󰱒 | Staged |
|  | Conflict |

Directories show the highest-priority icon from their children. File names are colored by git status.

## Buffers
| Key | Action |
|---|---|
| `S-h` | Previous buffer |
| `S-l` | Next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bp` | Pin buffer |
| `<leader>bo` | Close other buffers |

## Harpoon (Bookmarks)
| Key | Action |
|---|---|
| `<leader>ha` | Add file to harpoon |
| `<leader>hh` | Harpoon menu |
| `<leader>1-5` | Jump to harpoon file 1-5 |

## LSP
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cd` | Line diagnostics |
| `<leader>cf` | Format buffer |
| `[d` / `]d` | Prev/Next diagnostic |

## Diagnostics (Trouble)
| Key | Action |
|---|---|
| `<leader>xx` | All diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xs` | Symbols |
| `<leader>xl` | Location list |
| `<leader>xq` | Quickfix list |

## Git
| Key | Action |
|---|---|
| `<leader>gg` | Lazygit |
| `<leader>gd` | Diff view |
| `<leader>gD` | Diff vs last commit |
| `<leader>gh` | File history |
| `<leader>gH` | Branch history |
| `]c` / `[c` | Next/Prev hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage buffer |
| `<leader>ghR` | Reset buffer |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame line |
| `<leader>ghB` | Toggle line blame |
| `co/ct/cb/c0` | Conflict: ours/theirs/both/none |
| `]x` / `[x` | Next/Prev conflict |

## Debug (DAP)
| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Eval expression |
| `<leader>dr` | Restart |
| `<leader>dq` | Terminate |

## Tests (Neotest)
| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run file tests |
| `<leader>ts` | Test summary |
| `<leader>to` | Test output |
| `<leader>tO` | Test output panel |
| `<leader>td` | Debug nearest test |
| `]T` / `[T` | Next/Prev failed test |

## Search & Replace
| Key | Action |
|---|---|
| `<leader>sr` | Search & Replace (Spectre) |
| `<leader>sw` | Search word (Spectre) |
| `s` | Flash jump |
| `S` | Flash treesitter |

## Editing
| Key | Action |
|---|---|
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle block comment |
| `ys{motion}{char}` | Add surround |
| `ds{char}` | Delete surround |
| `cs{old}{new}` | Change surround |
| `C-d` | Multi-cursor (add next match) |
| `<leader>u` | Undotree |
| `<leader>a` | Swap next argument |
| `<leader>A` | Swap prev argument |

## Textobjects
| Key | Action |
|---|---|
| `af/if` | Around/Inside function |
| `ac/ic` | Around/Inside class |
| `aa/ia` | Around/Inside argument |
| `ai/ii` | Around/Inside conditional |
| `al/il` | Around/Inside loop |
| `]f/[f` | Next/Prev function |
| `]c/[c` | Next/Prev class |

## Folding
| Key | Action |
|---|---|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zK` | Peek fold |

## Terminal
| Key | Action |
|---|---|
| `C-\` | Toggle floating terminal |

## Session
| Key | Action |
|---|---|
| `<leader>qs` | Save session |
| `<leader>qr` | Restore session |
| `<leader>qd` | Delete session |
| `<leader>qf` | Search sessions |
| `<leader>qq` | Quit all |

## Misc
| Key | Action |
|---|---|
| `<leader>z` | Zen mode |
| `<leader>mp` | Markdown preview |
| `<leader>Db` | Database UI |
| `<leader>Da` | Add DB Connection |
| `<leader>sn` | Notification history |
| `]]` / `[[` | Next/Prev reference (illuminate) |

## Language-Specific

### TypeScript/JavaScript
| `<leader>co` | Organize imports |
| `<leader>ci` | Add missing imports |
| `<leader>cu` | Remove unused imports |
| `<leader>cR` | Rename file |

### Go
| `<leader>cgt` | Add json tags |
| `<leader>cgT` | Remove json tags |
| `<leader>cgm` | Go mod tidy |
| `<leader>cge` | Go if err |
| `<leader>cgs` | Generate test |

### Rust
| `<leader>cr` | Runnables |
| `<leader>ct` | Testables |
| `<leader>ce` | Explain error |
| `<leader>cR` | Cargo run |

### Package Management (package.json)
| `<leader>ns` | Show package versions |
| `<leader>nu` | Update package |
| `<leader>nd` | Delete package |
| `<leader>ni` | Install package |
| `<leader>nc` | Change version |

### Python
| `<leader>cv` | Select virtualenv |

### HTTP (.http files)
| `<leader>hr` | Run request |
| `<leader>hl` | Replay last request |
| `<leader>hi` | Inspect request |
| `[r` / `]r` | Prev/Next request |

## Russian Layout (langmap)

Normal/Visual/Operator-pending modes work with Russian keyboard layout via `langmap`:

- Letters: А-Я / а-я → A-Z / a-z (by QWERTY position)
- `Ж` → `:` (command mode), `ж` → `;` (repeat f/t)
- `Э` → `"` (registers), `э` → `'` (marks)
- `Б` → `<` (unindent), `Ю` → `>` (indent)
- `б` → `,` (reverse f/t), `ю` → `.` (repeat)
- `х` → `[`, `ъ` → `]`, `Х` → `{`, `Ъ` → `}`
- `ё` → `` ` `` (exact mark), `Ё` → `~` (toggle case)

Does NOT affect Insert mode. Some plugins using `getchar()` may not respect langmap.
