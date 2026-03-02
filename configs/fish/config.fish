if status is-interactive
    # Disable greeting
    set -g fish_greeting

    # Starship prompt
    starship init fish | source

    # Zoxide (smart cd)
    zoxide init fish | source

    # fzf key bindings (Ctrl+R history, Ctrl+T file search, Alt+C cd)
    fzf --fish | source

    # pyenv
    if test -d $HOME/.pyenv
        set -gx PYENV_ROOT $HOME/.pyenv
        fish_add_path $PYENV_ROOT/bin
        pyenv init --path | source
        pyenv init - fish | source
        pyenv virtualenv-init - | source
    end
end
