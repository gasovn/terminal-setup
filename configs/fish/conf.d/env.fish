# Locale: English messages, ISO 8601 dates
set -gx LANG en_US.UTF-8

# Interactive only — the graphical session inherits en_DK and Qt renders time as HH.mm
if status is-interactive
    set -gx LC_TIME en_DK.UTF-8
end

# Editors
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER bat

# Rust
set -gx CARGO_HOME $HOME/.cargo
set -gx RUSTUP_HOME $HOME/.rustup

# Go
set -gx GOPATH $HOME/go

# Node.js — npm global without sudo
set -gx NPM_CONFIG_PREFIX $HOME/.npm-global

# n (Node version manager) — without sudo
set -gx N_PREFIX $HOME/n
