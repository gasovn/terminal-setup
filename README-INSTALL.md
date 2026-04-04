# Terminal Setup: WezTerm + Fish + Starship + Neovim (Theme Switcher)

Полная инструкция по ручной установке терминальной среды на чистую Fedora Linux + KDE Plasma.

---

## 1. Системные зависимости

### Через dnf

```bash
# Терминальная среда
sudo dnf install -y wezterm fish starship fd-find bat zoxide fzf ripgrep

# Neovim и зависимости
sudo dnf install -y neovim gcc gcc-c++ make cmake nodejs npm python3 python3-pip go unzip curl wget wl-clipboard lazygit
```

### Через Rust/Cargo (eza и yazi нет в dnf)

```bash
# Установить Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Установить eza (замена ls)
cargo install eza

# Установить yazi (файл-менеджер)
cargo install --force yazi-build
yazi-build
```

### Шрифт: FiraCode Nerd Font

Если не установлен:

```bash
mkdir -p ~/.local/share/fonts
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip FiraCode.zip -d FiraCode
cp FiraCode/*.ttf ~/.local/share/fonts/
fc-cache -fv
```

Проверка: `fc-list | grep -i "FiraCode Nerd"`

---

## 2. Сменить shell по умолчанию на Fish

```bash
chsh -s /usr/bin/fish
```

Потребуется пароль. Проверка: `grep $USER /etc/passwd` — в конце строки должно быть `/usr/bin/fish`.

---

## 3. Копирование конфигов

`setup.sh` создаёт все симлинки автоматически:

```bash
git clone --recurse-submodules <repo-url>
cd terminal-setup
./setup.sh
```

Если приватный сабмодуль недоступен — SSH-хосты и deploy-окружение не подтянутся. Это ожидаемо.

### Themes (theme switcher)

Тему нужно установить вручную — `setup.sh` это не делает:

```bash
echo "gruvbox-material" > ~/.config/current-theme
```

После первого запуска Neovim автоматически установит все плагины через lazy.nvim.
Зависимости для LSP, линтеров и форматтеров устанавливаются через Mason (`:Mason`).

---

## 4. Проверка после установки

```bash
# Fish работает
fish -c 'echo "Fish OK"'

# Starship рендерится без ошибок
fish -c 'starship prompt 2>&1'

# Все утилиты доступны
fish -c 'which eza bat fd zoxide fzf yazi'

# WezTerm загружает конфиг
wezterm ls-fonts 2>&1 | head -1
```

---

## 5. Что где лежит

| Компонент | Расположение конфига |
|-----------|---------------------|
| Themes | `~/.config/themes/` (каталоги тем) + `~/.config/current-theme` |
| WezTerm | `~/.config/wezterm/` (10 lua-файлов) |
| Fish | `~/.config/fish/` (config.fish + conf.d/ + functions/ + completions/) |
| Starship | `~/.config/starship.toml` |
| Neovim | `~/.config/nvim/` (init.lua + lua/config/ + lua/plugins/ — 33 файла) |
| SSH | `~/.ssh/config` |

---

## 6. Структура конфига WezTerm

```
~/.config/wezterm/
├── wezterm.lua              — точка входа, подключает все модули
├── appearance.lua           — тема, шрифт (FiraCode 13), табы (процесс + директория, git dirty ●), GPU
├── keybinds.lua             — хоткеи (табы, сплиты, workspaces, SSH, copy mode, мышь)
├── kitty-cyrillic-fix.lua   — фикс Kitty protocol для русской раскладки (Shift/Ctrl + кириллица)
├── ssh.lua                  — SSH-домены (меню подключений, SFTP) из ssh-hosts.lua
├── ssh-hosts.lua            — загрузчик хостов из private/ (fallback на пустой список)
├── ssh-hosts.example.lua    — шаблон для создания своего списка хостов
├── workspaces.lua           — workspace по умолчанию
├── statusbar.lua            — powerline статусбар (workspace, SSH host, dir, время)
├── hyperlinks.lua           — URL + file:line ссылки (nvim:// scheme) + шаблон для тикетов
├── nvim-open.lua            — Ctrl+Click file:line → открытие в Neovim через RPC (cross-pane)
└── utils.lua                — иконки процессов, нормализация имён, git dirty
```

---

## 7. Структура конфига Fish

```
~/.config/fish/
├── config.fish           — Starship, zoxide, fzf, pyenv
├── conf.d/
│   ├── aliases.fish      — abbreviations (ls→eza, cat→bat, git, docker, cdc→~/code, cdl→~/homelab)
│   ├── theme.fish        — цвета для подсветки синтаксиса (управляется theme switcher)
│   ├── env.fish          — LANG, EDITOR, PAGER, Rust/Go/Node переменные
│   ├── path.fish         — PATH (.local/bin, cargo, go, npm-global, opencode)
│   └── wezterm.fish      — shell integration (уведомления, заголовки табов)
├── functions/
│   ├── mkcd.fish         — mkdir + cd
│   ├── extract.fish      — универсальная распаковка архивов
│   ├── backup.fish       — бэкап файла с таймстампом
│   ├── theme.fish        — переключение темы: theme <name>, theme list
│   └── (кастомные: nts, cherry-pick, claude-team, _my_deploy*)
└── completions/
    └── pnpm.fish
```

---

## 8. Структура конфига Neovim

```
~/.config/nvim/
├── init.lua              — точка входа (lazy.nvim bootstrap + подключение модулей)
├── lazy-lock.json        — pinned-версии плагинов
├── cheatsheet.md         — шпаргалка хоткеев
└── lua/
    ├── config/
    │   ├── options.lua   — базовые настройки, langmap (кириллица в Normal mode)
    │   ├── keymaps.lua   — хоткеи (leader=Space)
    │   └── autocmds.lua  — автокоманды (автосохранение, позиция курсора, WezTerm RPC сокет)
    └── plugins/          — 33 файла: по одному на плагин/группу
        ├── colorscheme.lua   — Gruvbox Material (через theme switcher)
        ├── lualine.lua       — статусбар
        ├── lsp.lua           — LSP (Mason + mason-lspconfig)
        ├── cmp.lua           — автодополнение (nvim-cmp + LuaSnip)
        ├── treesitter.lua    — подсветка синтаксиса
        ├── telescope.lua     — fuzzy finder
        ├── git.lua           — gitsigns, diffview, git-conflict
        ├── dap.lua           — отладка (DAP)
        ├── neotest.lua       — тесты
        ├── formatting.lua    — форматирование (conform.nvim)
        ├── linting.lua       — линтинг (nvim-lint)
        ├── neo-tree.lua      — файловый менеджер с git status иконками
        ├── ui.lua            — UI: indent guides, TODO comments, dressing, zen mode, scrollbar (nvim-scrollview), colorizer
        ├── terminal.lua      — toggleterm
        ├── session.lua       — авто-сессии
        └── ... (aerial, alpha, bufferline, database, editing, flash,
            harpoon, lang-*, markdown, noice, packages, rest,
            spectre, trouble, which-key)
```

---

## 9. Тема и переключение

Темы: **Gruvbox Material** (по умолчанию), **Catppuccin Mocha**
Акцент: **Orange** (Gruvbox) / **Teal** (Catppuccin)

Переключение одной командой:

```bash
theme                    # показать текущую тему
theme list               # список доступных тем
theme gruvbox-material   # переключить на Gruvbox Material
theme catppuccin-mocha   # переключить на Catppuccin Mocha
```

Тема меняется сразу в WezTerm (автоперезагрузка), Fish и Starship. Neovim — после рестарта.

Добавление новых тем: см. `~/.config/themes/README.md`

---

## 10. SSH — добавление серверов

Для добавления нового хоста нужно обновить **два файла** в приватном сабмодуле:

### 1. `private/ssh/hosts.config` — для системного ssh и WezTerm SSH-доменов

```
# === ГРУППА ===
Host alias
    HostName 10.0.0.XXX
    User your_username
    Port 22
```

### 2. `private/wezterm/ssh-hosts.lua` — для меню и авто-команд

```lua
{ name = 'alias', group = 'Группа', host = '10.0.0.XXX' },
-- с авто-командой:
{ name = 'alias', group = 'Группа', host = '10.0.0.XXX', cmd = 'sudo -iu deploy' },
```

После редактирования — закоммитить и запушить оба репозитория: приватный сабмодуль и основной.

После добавления:
- `ssh alias` — подключение из терминала
- `Ctrl+Shift+H` — SSH-меню WezTerm (SSH-домен, сплиты на удалённом хосте)
- `Ctrl+Shift+F` — SFTP-меню (открывает Dolphin)

---

## 11. Ключевые хоткеи WezTerm

| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+T` | Новый таб (домашний каталог) |
| `Ctrl+Shift+Enter` | Новый таб (текущий каталог) |
| `Ctrl+Tab` | Переключение на последний используемый таб (MRU) |
| `Ctrl+Shift+Tab` | Предыдущий таб (последовательно) |
| `Ctrl+Shift+1..9` | Таб по номеру |
| `Ctrl+Shift+Q` | Закрыть таб |
| `Ctrl+Shift+<` / `>` | Переместить таб влево / вправо |
| `Ctrl+Shift+\` | Сплит вправо |
| `Ctrl+Shift+-` | Сплит вниз |
| `Ctrl+Shift+стрелки` | Фокус между панелями |
| `Alt+стрелки` | Ресайз панелей |
| `Ctrl+Shift+W` | Закрыть панель |
| `Ctrl+Shift+Z` | Zoom панели |
| `Ctrl+Shift+S` | Список workspaces |
| `Ctrl+Shift+N` | Новый workspace |
| `Ctrl+Shift+H` | SSH меню |
| `Ctrl+Shift+F` | SFTP в Dolphin |
| `Ctrl+Shift+X` | Copy mode (vim) |
| `Ctrl+Shift+Space` | Quick select |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+C/V` | Копировать / вставить |
| `Правый клик` | Копировать выделенное в буфер |
| `Ctrl+Click` на `file:line` | Открыть в Neovim (соседний pane) |
| `Ctrl+Shift+K` | Очистить экран |

### Особенности

- **Delete**: WezTerm с kitty keyboard protocol отправляет `ctrl-h` вместо `\e[3~`. Фикс в `keybinds.lua` (явный SendString) и `wezterm.fish` (bind ctrl-h/\e[3~)
- **Ctrl+Delete**: удаление слова вперёд. Фикс в `keybinds.lua` (SendString `\e[3;5~`) и `wezterm.fish` (bind → kill-word)
- **Копирование мышью**: автокопирование при выделении отключено. Копировать: правый клик или Ctrl+Shift+C
- **Прокрутка мыши**: 3 строки за щелчок колёсика (вместо дефолтных ~5)
- **Заголовки табов**: шеллы показывают `fish ~/path`, TUI-программы — `process dirname` (например, `claude my-repo`, `nvim my-project`), SSH-домены — имя хоста (`stage`, `gitlab`). Жёлтый ● если есть незакоммиченные git-изменения
- **Нормализация процессов**: Claude Code использует version-based бинарник (`~/.local/share/claude/versions/X.Y.Z`), `utils.lua` нормализует имя обратно в "claude"

---

## 12. Русская раскладка (Kitty protocol fix)

WezTerm с включённым Kitty keyboard protocol (`enable_kitty_keyboard = true`) некорректно обрабатывает модификаторы для не-латинских раскладок: Shift и Ctrl не «потребляются» как для латиницы.

Фикс: `kitty-cyrillic-fix.lua` перехватывает клавиши ДО Kitty-кодирования:

| Комбинация | Что делает фикс |
|------------|----------------|
| Shift + кириллица (А-Я) | `mapped:` prefix → SendString(символ) |
| Shift + цифровой ряд (№, ", ?) | `mapped:` prefix → SendString(символ) |
| Ctrl + кириллица | Маппинг на латинский эквивалент по QWERTY-позиции (raw control code) |

**Известное ограничение**: `mapped:` не работает для ASCII-пунктуации (`;`, `:`) на русском цифровом ряду. Эти символы работают в Neovim (через langmap) и Claude Code, но не в plain Fish.

**Neovim langmap** (`options.lua`): маппит кириллические символы на латинские эквиваленты в Normal/Visual/Operator-pending modes. Включает буквы (А-Я ↔ A-Z) и пунктуацию (Ж→:, ж→;, э→', Б→<, Ю→> и т.д.).

Удалять `kitty-cyrillic-fix.lua` когда WezTerm починит потребление модификаторов для не-латинских раскладок. См.: WezTerm #1746, #2546.

---

## 13. Git интеграция

### WezTerm: заголовки табов

Формат заголовка зависит от типа процесса:
- **Шеллы** (fish, bash, zsh): `fish ~/code/my-repo`
- **TUI-программы** (claude, nvim, lazygit и др.): `claude my-repo` — имя процесса + название директории
- **SSH-домен**: `hostname` — имя хоста из домена (например, `stage`, `gitlab`)
- **SSH (обычный)**: `ssh hostname`

Жёлтый символ ● в конце заголовка если в текущей директории есть незакоммиченные git-изменения. Реализация в `utils.lua` (`git_dirty()`) с кэшированием (5 сек TTL).

**Нормализация имён процессов**: некоторые программы (напр. Claude Code) используют version-based бинарники (`~/.local/share/claude/versions/X.Y.Z`). Функция `basename()` в `utils.lua` нормализует такие пути обратно в читаемое имя.

### Neovim Neo-tree: git status иконки

| Символ | Значение |
|--------|----------|
| ✚ | Новый файл (added) |
|  | Изменённый (modified) |
| ✖ | Удалённый (deleted) |
| 󰁕 | Переименованный |
| ★ | Untracked |
| 󰄱 | Unstaged |
| 󰱒 | Staged |
|  | Конфликт |

Иконки отображаются справа от имени файла. Для директорий — иконка наивысшего приоритета среди дочерних файлов (видна даже при развёрнутом каталоге). Имена файлов окрашиваются по git-статусу (`use_git_status_colors = true`).
