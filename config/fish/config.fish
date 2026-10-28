# ==========================================================
# config.fish — Fish shell для BSPWM-machineslego
# ==========================================================

# --- Отключаем приветствие ---
set -g fish_greeting ""

# --- Переменные окружения ---
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx TERM xterm-256color

# --- PATH: добавляем ~/.local/bin (для AppImage и pip --user) ---
if test -d "$HOME/.local/bin"
    fish_add_path --prepend --global "$HOME/.local/bin"
end

# --- Алиасы (замена bash-алиасов) ---
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias lt='ls -lht'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'

# Навигация
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Пакеты Debian
alias up='sudo apt update && sudo apt upgrade -y'
alias in='sudo apt install'
alias sr='sudo apt search'
alias rm='sudo apt remove'

# BSPWM: удобный рестарт
alias bspwmreload='bspc wm -r'

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
# отсюда ничего вызывать не нужно.