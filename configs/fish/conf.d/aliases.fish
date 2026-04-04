# --- Modern replacements ---
abbr -a ls 'eza --icons --group-directories-first'
abbr -a ll 'eza -la --icons --group-directories-first'
abbr -a lt 'eza --tree --level=2 --icons'
abbr -a cat 'bat'
abbr -a grep 'rg'
abbr -a find 'fd'

# --- Git ---
abbr -a g 'git'
abbr -a gs 'git status'
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gp 'git push'
abbr -a gl 'git pull'
abbr -a gd 'git diff'
abbr -a glog 'git log --oneline --graph'
abbr -a gco 'git checkout'
abbr -a gbr 'git branch'

# --- Docker ---
abbr -a d 'docker'
abbr -a dc 'docker compose'
abbr -a dps 'docker ps'

# --- Navigation ---
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'

# --- Quick access ---
abbr -a v 'nvim'
abbr -a cls 'clear'
abbr -a cdc 'cd ~/code'
abbr -a cdl 'cd ~/homelab'
