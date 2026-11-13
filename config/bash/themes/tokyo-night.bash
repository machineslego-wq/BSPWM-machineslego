# ==========================================================
# tokyo-night.bash — промпт Bash в палитре Tokyo Night
# ==========================================================
# Репозиторий: config/bash/themes → ~/.config/bash/themes
# Подключение: BASH_PROMPT в ~/.bashrc (см. комментарий там).
# Сегменты: Debian → папка → git (ветка/статус/stash) → стрелка.
# Внутри git-репозитория — несколько вызовов git на каждый промпт.
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
    local bg_muted_purp="\[\033[48;2;74;62;104m\]"  # #4a3e68 (Фон Git)
    local bg_dark="\[\033[48;2;26;27;38m\]"         # #1a1b26 (Фон терминала)

    # --- ЯРКИЕ ЦВЕТА ТЕКСТА И ИКОНОК ---
    local fg_cyan="\[\033[38;2;125;207;255m\]"      # #7dcfff (Иконка дебиана)
    local fg_light="\[\033[38;2;192;202;245m\]"     # #c0caf5 (Светлый текст папки)
    local fg_purple="\[\033[38;2;187;154;247m\]"    # #bb9af7 (Фиолетовый текст Git)
    
    # Стрелка (зеленая при успехе, красная при ошибке)
    local fg_arrow="\[\033[38;2;158;206;106m\]"     # #9ece6a
    [ $exit_code -ne 0 ] && fg_arrow="\[\033[38;2;247;118;142m\]" # #f7768e

    # --- ПЕРЕХОДЫ (POWERLINE) ---
    local sep_c_b="\[\033[38;2;41;46;66m\]\[\033[48;2;61;89;161m\]"
    local sep_b_p="\[\033[38;2;61;89;161m\]\[\033[48;2;74;62;104m\]"
    local sep_p_d="\[\033[38;2;74;62;104m\]\[\033[48;2;26;27;38m\]"
    local sep_b_d="\[\033[38;2;61;89;161m\]\[\033[48;2;26;27;38m\]"

    if [ "$tty" = true ]; then
        # ФОЛБЭК ДЛЯ TTY
        PS1="\u@\h:\w"
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            local branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
            local dirty=""
            [ -n "$(git status --porcelain -uno 2>/dev/null)" ] && dirty="*"
            PS1="${PS1} (git:${branch}${dirty})"
        fi
        PS1="${PS1} $ "
    else
        # ====================================================
        # ГРАФИЧЕСКИЙ РЕЖИМ
        # ====================================================
        
        # 1. Блок Дебиана
        PS1="${bg_muted_cyan}${fg_cyan}  "
        
        # 2. Блок Папки
        PS1+="${sep_c_b}${bg_muted_blue}${fg_light}  \w "
        
        # 3. Блок Гита (ОПТИМИЗИРОВАННЫЙ)
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            local branch=$(git branch --show-current 2>/dev/null)
            [ -z "$branch" ] && branch=$(git rev-parse --short HEAD 2>/dev/null)
            
            local git_icon=""
            local git_color="${fg_purple}" 
            local git_stash="" 
            
            # Один быстрый запрос (флаг -uno отключает сканирование новых файлов)
            local status_out=$(git status --porcelain -uno 2>/dev/null)
            
            if [ -n "$status_out" ]; then
                # Проверка на конфликты внутри быстрого вывода
                if echo "$status_out" | grep -qE '^(DD|AU|UD|UA|DU|AA|UU)'; then
                    git_icon="" # <--- ЗАМЕНЕНО НА ТРЕУГОЛЬНИК (nf-fa-exclamation-triangle)
                    git_color="\[\033[38;2;247;118;142m\]"
                else
                    git_icon=""
                    branch="${branch}*"
                    git_color="\[\033[38;2;224;175;104m\]"
                fi
            else
                # Если грязных файлов нет, проверяем ahead/behind
                local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
                local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
                if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
                    git_icon=""
                    git_color="\[\033[38;2;125;207;255m\]"
                elif [ "$ahead" -gt 0 ]; then
                    git_icon=""
                elif [ "$behind" -gt 0 ]; then
                    git_icon=""
                fi
            fi

            # Мгновенная проверка на stash
            if git rev-parse --verify refs/stash >/dev/null 2>&1; then
                git_stash=" 󰀘" 
            fi

            # Вывод блока Git
            PS1+="${sep_b_p}${bg_muted_purp}${git_color} ${git_icon} ${branch}${git_stash} "
            # Переход на темный фон
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
