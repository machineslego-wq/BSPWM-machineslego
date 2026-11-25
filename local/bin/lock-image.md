# lock-image — обои для SDDM и экрана блокировки KDE

Берёт указанную картинку, конвертирует её в PNG (не больше 4K) и ставит
фоном входа SDDM и экрана блокировки Plasma.

Команда: `local/bin/lock-image` (после `link.sh` — `~/.local/bin/lock-image`).

## Использование

```bash
lock-image ~/Изображения/wallpaper.jpg
lock-image --dry-run ~/wallpaper.png
```

Для SDDM нужен root, поэтому команда сама вызовет `sudo -v`. Запускать
её нужно **без sudo**:

```bash
lock-image /path/to/image
```

## Флаги

| Флаг | Смысл |
|---|---|
| *(без флагов)* | поставить картинку в SDDM и на экран блокировки Plasma |
| `--dry-run`, `-n` | показать шаги, ничего не менять (работает без root) |
| `-h`, `--help` | справка |

## Что меняется

| Что | Где |
|---|---|
| нормализованная картинка | `/usr/share/sddm/backgrounds/custom.png` (root, 644) |
| фон текущей темы SDDM | `/usr/share/sddm/themes/<тема>/theme.conf`: `type=image`, `background=...` |
| бэкап темы | `/var/backups/lock-image/<тема>.theme.conf.<дата>` |
| экран блокировки Plasma | `~/.config/kscreenlockerrc`: `[Greeter] WallpaperPlugin=org.kde.image` и `[Greeter][Wallpaper][org.kde.image][General] Image=...` |

Картинка всегда конвертируется в PNG и уменьшается до 3840×2160, если она
больше. Пропорции не меняются — SDDM и Plasma сами обрезают под экран.

## Когда применяется

- **SDDM** — при следующем входе или перезагрузке. Не делай
  `systemctl restart sddm` из сессии: это её завершит.
- **Экран блокировки Plasma** — при следующей блокировке. Проверить можно
  через `loginctl lock-session` (для разблокировки понадобится пароль).

## Важно

- `theme.conf` принадлежит пакету темы SDDM. Обновление
  `sddm-theme-breeze` может вернуть старый фон — просто запусти
  `lock-image` снова. Бэкап лежит в `/var/backups/lock-image/`.
- `~/.config/kscreenlockerrc` — пользовательский конфиг KDE, репозиторий
  и остальные дотфайлы не затрагиваются.
- Если картинка не читается ImageMagick, команда завершится с ошибкой
  до каких-либо изменений.

## Откат

SDDM:

```bash
sudo cp /var/backups/lock-image/<тема>.theme.conf.<дата> \
        /usr/share/sddm/themes/<тема>/theme.conf
```

Экран блокировки Plasma — убрать привязку к картинке:

```bash
kwriteconfig6 --file ~/.config/kscreenlockerrc --group Greeter --delete --key WallpaperPlugin
kwriteconfig6 --file ~/.config/kscreenlockerrc \
  --group Greeter --group Wallpaper --group org.kde.image --group General \
  --delete --key Image
```
