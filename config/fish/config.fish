# ==========================================================
# config.fish — Fish shell для BSPWM-machineslego
# ==========================================================

# --- Отключаем приветствие ---
set -g fish_greeting ""

# --- Переменные окружения ---
set -gx EDITOR nvim
set -gx VISUAL nvim
# TERM выставляет сам терминал (alacritty, kitty, foot, wezterm).
# Принудительный xterm-256color может отключить truecolor в TUI.
# set -gx TERM xterm-256color

# --- PATH: добавляем ~/.local/bin (для AppImage и pip --user) ---
if test -d "$HOME/.local/bin"
    fish_add_path --prepend --global "$HOME/.local/bin"
end

# --- Цветной вывод ---
# GNU coreutils не включает цвет по умолчанию; флаг нужен явно.
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# --- Навигация ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Остальные алиасы намеренно убраны ---
# Были: ll/la/lt, df, du, up, in, sr, rm, bspwmreload.
# Полные команды короче и переносимее:
#   sudo apt update && sudo apt upgrade -y
#   sudo apt install <pkg>
#   sudo apt remove  <pkg>
#   bspc wm -r
# `in` был багом (зарезервированное слово fish),
# `rm='sudo apt remove'` — опасный футган.
# При необходимости добавляйте точечно здесь.

# --- Цвета Fish (Tokyo Night) ---
set -g fish_color_normal c0caf5
set -g fish_color_command 7aa2f7
set -g fish_color_keyword bb9af7
set -g fish_color_quote 9ece6a
set -g fish_color_redirection 89ddff
set -g fish_color_end c0caf5
set -g fish_color_error f7768e
set -g fish_color_param e0af68
set -g fish_color_comment 565f89
set -g fish_color_selection --background=2f334d
set -g fish_color_search_match --background=2f334d
set -g fish_color_operator 89ddff
set -g fish_color_escape 89ddff
set -g fish_color_autosuggestion 565f89

# --- Подсветка в pager / man ---
set -gx PAGER less
set -gx LESS "-R"

# Tide инициализируется автоматически через ~/.config/fish/conf.d/

# --- npm глобальные пакеты без sudo ---
if test -d "$HOME/.npm-global/bin"
    fish_add_path --prepend --global "$HOME/.npm-global/bin"
end