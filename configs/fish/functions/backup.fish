function backup --description 'Create a timestamped backup of a file'
    if test (count $argv) -eq 0
        echo "Usage: backup <file>"
        return 1
    end
    cp $argv[1] $argv[1].bak.(date +%Y%m%d-%H%M%S)
end
