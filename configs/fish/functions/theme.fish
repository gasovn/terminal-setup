function theme --description "Switch terminal theme"
    set -l themes_dir ~/.config/themes
    set -l current_file ~/.config/current-theme

    # No arguments: show current theme
    if test (count $argv) -eq 0
        if test -f $current_file
            echo "Current theme: "(cat $current_file)
        else
            echo "No theme set (use 'theme <name>' to set one)"
        end
        return 0
    end

    # "list" subcommand
    if test "$argv[1]" = list
        echo "Available themes:"
        for dir in $themes_dir/*/
            set -l name (basename $dir)
            if test -f $current_file; and test "$name" = (cat $current_file)
                echo "  * $name (active)"
            else
                echo "    $name"
            end
        end
        return 0
    end

    set -l name $argv[1]
    set -l theme_dir $themes_dir/$name

    # Validate theme exists
    if not test -d $theme_dir
        echo "Theme '$name' not found."
        echo -n "Available: "
        for dir in $themes_dir/*/
            echo -n (basename $dir)" "
        end
        echo
        return 1
    end

    # Validate all required files exist
    for f in theme.conf wezterm-palette.lua wezterm-statusbar.lua nvim-colorscheme.lua fish-colors.fish starship-palette.toml
        if not test -f $theme_dir/$f
            echo "Missing theme file: $theme_dir/$f"
            return 1
        end
    end

    # ── 1. Replace between markers in appearance.lua ──
    set -l appearance ~/.config/wezterm/appearance.lua
    if test -f $appearance
        set -l begin_marker '-- ══ THEME: BEGIN ══'
        set -l end_marker '-- ══ THEME: END ══'
        # Build replacement: marker + content + marker
        set -l tmpfile (mktemp)
        awk -v bm="$begin_marker" -v em="$end_marker" -v rf="$theme_dir/wezterm-palette.lua" '
            $0 == bm { print bm; while ((getline line < rf) > 0) print line; close(rf); skip=1; next }
            $0 == em { print em; skip=0; next }
            !skip { print }
        ' $appearance > $tmpfile
        and mv $tmpfile $appearance
        or begin; rm -f $tmpfile; echo "Failed to update appearance.lua"; return 1; end
    end

    # ── 2. Replace between markers in statusbar.lua ──
    set -l statusbar ~/.config/wezterm/statusbar.lua
    if test -f $statusbar
        set -l begin_marker '-- ══ THEME: BEGIN ══'
        set -l end_marker '-- ══ THEME: END ══'
        set -l tmpfile (mktemp)
        awk -v bm="$begin_marker" -v em="$end_marker" -v rf="$theme_dir/wezterm-statusbar.lua" '
            $0 == bm { print bm; while ((getline line < rf) > 0) print line; close(rf); skip=1; next }
            $0 == em { print em; skip=0; next }
            !skip { print }
        ' $statusbar > $tmpfile
        and mv $tmpfile $statusbar
        or begin; rm -f $tmpfile; echo "Failed to update statusbar.lua"; return 1; end
    end

    # ── 3. Copy starship.toml (full replacement — themes may have different layouts) ──
    cp $theme_dir/starship-palette.toml ~/.config/starship.toml

    # ── 4. Copy nvim colorscheme ──
    cp $theme_dir/nvim-colorscheme.lua ~/.config/nvim/lua/plugins/colorscheme.lua

    # ── 5. Copy fish colors and source ──
    cp $theme_dir/fish-colors.fish ~/.config/fish/conf.d/theme.fish
    source ~/.config/fish/conf.d/theme.fish

    # ── 6. Save current theme ──
    echo $name > $current_file

    echo "Theme switched to $name."
    echo "WezTerm reloads automatically. Restart Neovim to apply."
end
