function _my_claude-team
    if set -q TMUX
        claude $argv
    else
        tmux new-session -s claude "claude $argv"
    end
end
