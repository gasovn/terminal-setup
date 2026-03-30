# Terminal Cheatsheet: WezTerm + Fish + Starship

## Хоткеи WezTerm

### Табы
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+T` | Новый таб (домашний каталог) |
| `Ctrl+Shift+Enter` | Новый таб (текущий каталог) |
| `Ctrl+Tab` | Переключение между двумя последними табами (MRU) |
| `Ctrl+Shift+Tab` | Предыдущий таб по порядку |
| `Ctrl+Shift+1..9` | Таб по номеру |
| `Ctrl+Shift+Q` | Закрыть таб |
| `Ctrl+Shift+<` / `>` | Переместить таб влево / вправо |

### Сплиты (панели)
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+\` | Сплит вправо |
| `Ctrl+Shift+-` | Сплит вниз |
| `Ctrl+Shift+стрелки` | Фокус между панелями |
| `Alt+стрелки` | Ресайз панелей |
| `Ctrl+Shift+W` | Закрыть панель |
| `Ctrl+Shift+Z` | Zoom панели |

### Workspaces
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+S` | Список workspaces |
| `Ctrl+Shift+N` | Новый workspace |

### SSH / SFTP
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+H` | SSH меню (группы хостов, fuzzy-поиск, SSH-домены) |
| `Ctrl+Shift+F` | SFTP меню (открыть в Dolphin) |

### Быстрый доступ к проектам
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+E` | Список каталогов в CWD → открыть nvim в новом табе (показывает git-ветку) |

> В SSH-домене сплиты (`Ctrl+Shift+\`) открываются на **удалённом хосте**.
> Прод-серверы (app/matchflow/docker -ru/-kz) автоматически переключаются на пользователя deploy.

### Навигация в Neovim (cross-pane)
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Click` на `file:line` | Открыть файл в Neovim в соседнем pane на нужной строке |

> Работает когда nvim запущен в соседнем pane того же таба. Относительные пути резолвятся от cwd терминального pane.

### Прочее
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+X` | Copy mode (vim-навигация) |
| `Ctrl+Shift+Space` | Quick select (URL, IP, хеши) |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+C/V` | Копировать / вставить |
| `Ctrl+Shift+K` | Очистить экран |

### Copy Mode (после Ctrl+Shift+X)
| Клавиша | Действие |
|---------|----------|
| `h j k l` | Навигация |
| `/` / `?` | Поиск вперёд / назад |
| `n` / `N` | Следующее / предыдущее совпадение |
| `v` / `V` | Выделение посимвольное / построчное |
| `y` | Скопировать и выйти |
| `w` / `b` | Слово вперёд / назад |
| `0` / `$` | Начало / конец строки |
| `g` / `G` | Начало / конец буфера |
| `Esc` / `q` | Отмена |

## Fish Abbreviations

### Замены утилит
| Сокращение | Раскрывается в |
|-----------|---------------|
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -la --icons --group-directories-first` |
| `lt` | `eza --tree --level=2 --icons` |
| `cat` | `bat` |
| `grep` | `rg` (ripgrep) |
| `find` | `fd` |

### Git
| Сокращение | Раскрывается в |
|-----------|---------------|
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gd` | `git diff` |
| `glog` | `git log --oneline --graph` |
| `gco` | `git checkout` |
| `gbr` | `git branch` |

### Docker
| Сокращение | Раскрывается в |
|-----------|---------------|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dps` | `docker ps` |

### Навигация и прочее
| Сокращение | Раскрывается в |
|-----------|---------------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `v` | `nvim` |
| `cls` | `clear` |
| `cdc` | `cd ~/code` |
| `cdl` | `cd ~/code/homelab` |

## Кастомные функции Fish

| Функция | Описание |
|---------|----------|
| `mkcd dir` | Создать директорию и перейти в неё |
| `extract file` | Распаковать любой архив (tar, zip, gz, bz2, xz, 7z, rar, zst) |
| `backup file` | Бэкап файла с таймстампом (file.bak.YYYYMMDD-HHMMSS) |

## SSH — добавление серверов

Для добавления нового хоста нужно обновить **два файла**:

1. **`private/ssh/hosts.config`** — для системного ssh и WezTerm SSH-доменов:
```
# === Группа ===
Host myhost
    HostName 10.0.0.XXX
    User your_username
```

2. **`private/wezterm/ssh-hosts.lua`** — для меню и авто-команд:
```lua
{ name = 'myhost', group = 'Группа', host = '10.0.0.XXX' },
-- с авто-командой:
{ name = 'myhost', group = 'Группа', host = '10.0.0.XXX', cmd = 'sudo -iu deploy' },
```

После изменений хост появится в меню `Ctrl+Shift+H`.

> После редактирования private-файлов — закоммитить изменения в submodule, затем в основном репо.

## Структура конфигов

```
~/.config/wezterm/          — WezTerm (Lua, модульный)
  ssh-hosts.lua             — загрузчик хостов из private/
  ssh.lua                   — SSH-домены и меню подключений
  nvim-open.lua             — Ctrl+Click file:line → открытие в Neovim (cross-pane)
~/.config/fish/             — Fish shell
~/.config/starship.toml     — Starship prompt
~/.ssh/config               — SSH серверы (порты, ключи)
private/                    — приватные данные (SSH хосты, env vars) — git submodule
```
