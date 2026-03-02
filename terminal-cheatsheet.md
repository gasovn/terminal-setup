# Terminal Cheatsheet: WezTerm + Fish + Starship

## Хоткеи WezTerm

### Табы
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+T` | Новый таб |
| `Ctrl+Tab` | Переключение между двумя последними табами (MRU) |
| `Ctrl+Shift+Tab` | Предыдущий таб по порядку |
| `Ctrl+Shift+1..9` | Таб по номеру |
| `Ctrl+Shift+Q` | Закрыть таб |

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

### SSH / Прочее
| Хоткей | Действие |
|--------|----------|
| `Ctrl+Shift+H` | SSH меню (из ~/.ssh/config) |
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

## Кастомные функции Fish

| Функция | Описание |
|---------|----------|
| `mkcd dir` | Создать директорию и перейти в неё |
| `extract file` | Распаковать любой архив (tar, zip, gz, bz2, xz, 7z, rar, zst) |
| `backup file` | Бэкап файла с таймстампом (file.bak.YYYYMMDD-HHMMSS) |

## SSH — добавление серверов

Файл: `~/.ssh/config`

```
# === ПРОЕКТ: Production ===
Host prod-web
    HostName 10.0.1.10
    User deploy
    Port 22
    IdentityFile ~/.ssh/id_rsa

Host prod-db
    HostName 10.0.1.11
    User admin
    IdentityFile ~/.ssh/id_rsa

# === ПРОЕКТ: Staging ===
Host staging-web
    HostName 10.0.2.10
    User deploy
    IdentityFile ~/.ssh/staging_key
```

После добавления хоста он автоматически появится в меню `Ctrl+Shift+H`.
Комментарий `# === ГРУППА ===` группирует хосты в меню.

## Структура конфигов

```
~/.config/wezterm/          — WezTerm (Lua, модульный)
~/.config/fish/             — Fish shell
~/.config/starship.toml     — Starship prompt
~/.ssh/config               — SSH серверы
```

Бэкап старых конфигов: `~/config-backup-2026-02-27/`
