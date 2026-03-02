# WezTerm shell integration for Fish

# Delete key — forward delete (WezTerm sends ctrl-h instead of proper delete with kitty keyboard)
bind ctrl-h delete-char
bind \e\[3~ delete-char

# Set tab title to current command while running
function __wezterm_preexec --on-event fish_preexec
    printf '\e]0;%s\e\\' (string sub -l 60 -- $argv)
end

# Reset tab title to directory after command
function __wezterm_postexec_title --on-event fish_postexec
    printf '\e]0;%s\e\\' (prompt_pwd)
end
