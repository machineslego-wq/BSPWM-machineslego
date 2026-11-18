v1.8.1 — Recording Hotfix

What's done

A patch for the new screen recorder: full-screen recording now works on Intel integrated graphics, and audio is taken only from the monitor of the active output — the microphone is never used and there is no silent fallback to it.

## 🎥 Full-screen recording on Intel

- VAAPI (`h264_vaapi`) is now used only on `amdgpu`, where it is verified. On Intel iGPUs that path failed and the recording did not start, so full-screen recording falls back to `libx264` — the same encoder region recording already used.
- NVIDIA and any other GPU also get `libx264`; nothing to configure, the driver is detected through `/sys/class/drm/renderD128`.
- AMD keeps hardware encoding: full screen stays on `h264_vaapi`, regions stay on `libx264` because the AMD encoder does not accept frames below 128×128.

## 🔊 Audio: active output only

- The previous fallback to `-a` is gone: `-a` records the default *source*, which on a laptop is often the webcam rather than the system sound.
- The recorder always passes `--audio="<sink>.monitor"` for the current default sink, i.e. the monitor of the active output.
- If no active sink is found, recording refuses to start and shows a notification instead of silently recording silence or the microphone.

## ⚠️ Migration notes

- No new packages or configs: `git pull` and a Sway reload (`Super + Escape`) are enough.
- The script itself does not even need the reload: it is executed fresh from the repository through the existing symlink on every hotkey press.

🚀 Update Instructions

```bash
cd ~/BSPWM-machineslego
git pull origin main
```

Nothing else is required — the command is read from the repository on every launch.

---

v1.8.1 — хотфикс записи

Что сделано

Патч к новой записи экрана: запись всего экрана теперь работает на встроенной графике Intel, а звук берётся только с монитора активного выхода — микрофон не используется и тихого фолбэка на него нет.

## 🎥 Запись всего экрана на Intel

- VAAPI (`h264_vaapi`) теперь используется только на `amdgpu`, где он проверен. На Intel iGPU этот путь падал и запись не стартовала, поэтому весь экран пишется через `libx264` — тем же энкодером, что уже использовался для области.
- NVIDIA и остальные GPU тоже получают `libx264`; настраивать ничего не нужно, драйвер определяется через `/sys/class/drm/renderD128`.
- AMD сохраняет аппаратное кодирование: весь экран по-прежнему на `h264_vaapi`, область — на `libx264` (энкодер AMD не принимает кадры меньше 128×128).

## 🔊 Звук: только активный выход

- Фолбэк на `-a` убран: `-a` пишет источник по умолчанию, а на ноутбуке это часто веб-камера, а не звук системы.
- Запись всегда идёт с `--audio="<sink>.monitor"` текущего выхода по умолчанию, то есть с монитора активного выхода.
- Если активного выхода нет, запись не стартует и показывает уведомление — вместо тишины или микрофона.

## ⚠️ Что сделать после обновления

- Новых пакетов и конфигов нет: достаточно `git pull` и перезапуска Sway (`Super + Escape`).
- Самому скрипту reload не нужен: он запускается заново из репозитория через существующий симлинк при каждом нажатии хоткея.

🚀 Инструкция по обновлению

```bash
cd ~/BSPWM-machineslego
git pull origin main
```

Больше ничего не требуется — команда читается из репозитория при каждом запуске.
