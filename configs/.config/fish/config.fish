if status is-interactive
    fastfetch

    # ===== СОКРАЩЕНИЯ =====
    abbr -a gst "git status"
    abbr -a gct "git commit -m"
    abbr -a gps "git push"
    abbr -a ga "git add"

    abbr -a py "python"
    abbr -a work "cd ~/Projects/project-manager && nvim ."
    abbr -a venv "python -m venv .venv"
    abbr -a vrm "deactivate 2>/dev/null; rm -rf .venv: echo 'Виртульное окружение успешно удалено.'"

    # ===== АКТИВАЦИЯ-ДЕАКТИВАЦИЯ .VENV =====
    function auto_activate_venv --on-variable PWD
        if test -f .venv/bin/activate.fish
            source .venv/bin/activate.fish
        else if set -q VIRTUAL_ENV
            deactivate
        end
    end


end
starship init fish | source
