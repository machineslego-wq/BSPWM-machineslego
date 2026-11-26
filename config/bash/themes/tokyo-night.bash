# ==========================================================
# tokyo-night.bash — промпт Bash в палитре Tokyo Night
# ==========================================================
# Репозиторий: config/bash/themes → ~/.config/bash/themes
# Подключение: BASH_PROMPT в ~/.bashrc (см. комментарий там).
# Сегменты: Debian → папка → git (ветка + грязно/чисто) → стрелка.
# Внутри git-репозитория — один вызов `git status` на каждый промпт.
# ==========================================================

# Собирается заново перед каждым промптом
prompt_command() {
    local exit_code=$?
    local tty=false
    [ "${TERM:-}" = linux ] && tty=true
    local reset="\[\033[0m\]"

    # --- ПРИГЛУШЕННЫЕ ФОНЫ (Tokyo Night) ---
    local bg_muted_cyan="\[\033[48;2;41;46;66m\]"   # #292e42 (Фон Дебиана)
    local bg_muted_blue="\[\033[48;2;61;89;161m\]"  # #3d59a1 (Фон папки)
    local bg_muted_purp="\[\033[48;2;59;66;97m\]"  # #3b4261 (Фон Git)
    local bg_dark="\[\033[48;2;26;27;38m\]"         # #1a1b26 (Фон терминала)

    # --- ЯРКИЕ ЦВЕТА ТЕКСТА И ИКОНОК ---
    local fg_cyan="\[\033[38;2;125;207;255m\]"      # #7dcfff (Иконка дебиана)
    local fg_light="\[\033[38;2;192;202;245m\]"     # #c0caf5 (Светлый текст папки)
    local fg_purple="\[\033[38;2;187;154;247m\]"    # #bb9af7 (Фиолетовый текст Git)
    local fg_amber="\[\033[38;2;224;175;104m\]"     # #e0af68 (Изменения в репозитории)
    
    # Стрелка (зеленая при успехе, красная при ошибке)
    local fg_arrow="\[\033[38;2;158;206;106m\]"     # #9ece6a
    [ $exit_code -ne 0 ] && fg_arrow="\[\033[38;2;247;118;142m\]" # #f7768e

    # --- ПЕРЕХОДЫ (POWERLINE) ---
    local sep_c_b="\[\033[38;2;41;46;66m\]\[\033[48;2;61;89;161m\]"
    local sep_b_p="\[\033[38;2;61;89;161m\]\[\033[48;2;59;66;97m\]"
    local sep_p_d="\[\033[38;2;74;62;104m\]\[\033[48;2;26;27;38m\]"
    local sep_b_d="\[\033[38;2;61;89;161m\]\[\033[48;2;26;27;38m\]"

    # --- GIT: один вызов; вне репозитория переменные остаются пустыми ---
    local git_branch="" git_oid=""
    local git_dirty=false dirty_mark=""
    local git_out
    if git_out=$(git status --porcelain=v2 --branch -uno 2>/dev/null); then
        local line
        while IFS= read -r line; do
            case $line in
                "# branch.head "*) git_branch="${line#\# branch.head }" ;;
                "# branch.oid "*)  git_oid="${line#\# branch.oid }" ;;
                "#"*) ;;
                *) git_dirty=true ;;
            esac
        done <<< "$git_out"
        [ "$git_branch" = "(detached)" ] && git_branch="${git_oid:0:7}"
        [ "$git_dirty" = true ] && dirty_mark="*"
    fi

    if [ "$tty" = true ]; then
        # ФОЛБЭК ДЛЯ TTY
        PS1="\u@\h:\w"
        [ -n "$git_branch" ] && PS1+=" (git:${git_branch}${dirty_mark})"
        PS1+=" $ "
    else
        # ====================================================
        # ГРАФИЧЕСКИЙ РЕЖИМ
        # ====================================================
        
        # 1. Блок Дебиана
        PS1="${bg_muted_cyan}${fg_cyan}  "
        
        # 2. Блок Папки
        PS1+="${sep_c_b}${bg_muted_blue}${fg_light}  \w "
        
        # 3. Блок Гита: ветка + иконка состояния
        if [ -n "$git_branch" ]; then
            local git_icon="" git_color="${fg_purple}"
            if [ "$git_dirty" = true ]; then
                git_icon=""
                git_color="${fg_amber}"
            fi
            PS1+="${sep_b_p}${bg_muted_purp}${git_color} ${git_icon} ${git_branch} "
            PS1+="${sep_p_d}"
        else
            # Если гита нет, сразу переход на темный фон
            PS1+="${sep_b_d}"
        fi
        
        # 4. Финальная стрелка
        PS1+="${bg_dark}${fg_arrow}${reset} "
    fi

    # Заголовок окна (только xterm-совместимые терминалы)
    case "${TERM:-}" in
        xterm*|rxvt*)
            PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]${PS1}"
            ;;
    esac
}

PROMPT_COMMAND=prompt_command
prompt_command
