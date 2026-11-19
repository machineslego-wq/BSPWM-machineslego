# start-llm — локальный LLM-стек на llama.cpp

RX 7700 XT 12 ГБ (gfx1101) · i5-11600K 6c/12t · 32 ГБ DDR4-3600 · Debian 13 · Docker

## 0. Что это и что НЕ трогает

Один контейнер `llama` с `llama-server` в **router mode**: модели лежат GGUF-файлами
в `/home`, сервер сам подгружает нужную по имени из API и выгружает предыдущую.
Клиенты: **opencode** (агентный кодинг) и встроенный **WebUI** llama.cpp (чат/vision).

```
opencode ──┐
           ├──► http://127.0.0.1:8080 ──► llama-server (router)
браузер ───┘                                  │
                                              ├─ /models  ← ~/llm_models (GGUF, ro)
                                              └─ /config  ← ~/llm_config/presets.ini (ro)
```

**Никогда не трогает:** контейнеры/образы `comfyui` и `portainer`, их данные.
Никаких `docker system prune`. Удаление — только по явным именам `ollama`/`openwebui`.

Не используется: Ollama-сервер, её Go-парсеры тулов (`qwen35.go`), OpenWebUI, SQLite,
docker-volume с моделями в `/var`.

---

## 1. Подготовка системы (один раз)

```bash
sudo apt update
sudo apt install -y docker.io curl python3-venv
sudo usermod -aG docker,video,render "$USER"
sudo systemctl enable --now docker
# ПЕРЕЛОГИНЬСЯ (или reboot) — иначе группы не применятся
```

Опционально: `zram-tools` (страховка от OOM при 20+ ГБ весов), `firmware-amd-graphics`.

Проверка:
```bash
docker info >/dev/null && echo "docker ok"
ls -l /dev/kfd /dev/dri/renderD*
start-llm --check
```

---

## 2. Где что лежит

| Что | Путь | Раздел |
|---|---|---|
| GGUF-модели | `~/llm_models/<слот>/` | /home |
| Пресеты сервера | `~/llm_config/presets.ini` | /home |
| hf CLI (venv) | `~/.local/share/hf-cli-venv` | /home |
| Конфиг opencode | `~/.config/opencode/opencode.json` | /home |
| Сабагенты opencode | `~/.config/opencode/agents/*.md` | /home |
| Docker-образ llama.cpp | `/var/lib/docker` | **/var** |
| Логи контейнера | `docker logs llama` (ротация 20 МБ × 3) | /var |
| Этот документ | `~/.local/share/doc/start-llm.md` | /home |

Модели **не копируются** в контейнер: bind-mount read-only, одна копия на диске.
Внутри контейнера путь `/models/<слот>/…` = снаружи `~/llm_models/<слот>/…`.

---

## 3. Первый запуск с нуля

```bash
start-llm --check                  # GPU, группы, диск, swap, comfy
start-llm --models fast            # ~3.4 ГБ — смоук-тест
start-llm                          # образ + контейнер + сервер
# открыть http://127.0.0.1:8080, выбрать fast, написать «привет»
start-llm --models                 # базовый набор: coder chat fast reason (~45 ГБ)
start-llm --opencode               # конфиг + агенты для opencode
start-llm --tune coder             # подобрать n-cpu-moe (comfy остановлен!)
```

Если `ghcr.io` отдаёт 1 КБ/с — см. §9. По умолчанию тянется **Vulkan-образ (~0.5 ГБ)**,
а не ROCm (~18 ГБ). ROCm включается флагом `--rocm` (быстрее prefill, но в 36 раз больше качать).

---

## 4. Команды

| Команда | Что делает |
|---|---|
| `start-llm` | быстрый запуск: образ (если нет) → контейнер → сервер → URL |
| `start-llm --setup [слоты]` | всё с нуля: preflight + образ + модели + запуск + opencode |
| `start-llm --models [слоты\|all]` | скачать GGUF, пересобрать presets.ini |
| `start-llm --list` | таблица слотов: скачано / размер / репозиторий |
| `start-llm --check` | preflight-диагностика |
| `start-llm --status` | контейнер + статусы моделей + VRAM |
| `start-llm --stop` | остановить контейнер `llama` |
| `start-llm --logs [-f]` | логи (`-f` — следить) |
| `start-llm --bench [слот]` | замер prompt/gen t/s + VRAM |
| `start-llm --tune [слот]` | автоподбор `n-cpu-moe` под VRAM |
| `start-llm --opencode` | записать конфиг V2 + сабагенты (старый конфиг → `.bak`) |
| `start-llm --recreate` | пересоздать контейнер (**пресеты сохраняются**) |
| `start-llm --update` | обновить образ и пересоздать контейнер |
| `start-llm --cleanup-old` | удалить ollama/openwebui (comfy/portainer целы) |

**Модификаторы** (ставятся в любом месте, комбинируются с действием):

| Флаг | Эффект |
|---|---|
| `--vulkan` | образ ~0.5 ГБ через зеркала (по умолчанию) |
| `--rocm` | образ ~18 ГБ, быстрее prefill |
| `--ollama` / `--reuse` | взять `llama-server` из локального `ollama/ollama:rocm` (0 ГБ) |
| `--build` | собрать Vulkan-образ локально из github (ghcr не нужен) |
| `--hf-mirror` | модели через hf-mirror.com |
| `--speed N` | порог watchdog в МБ/с (default 2) |
| `--image REF` | произвольный образ вручную |

Примеры:
```bash
start-llm --models fast --hf-mirror --speed 1
start-llm --vulkan --setup coder chat
DEBIAN_BASE=dockerhub.timeweb.cloud/library/debian:trixie-slim start-llm --build
```

> `--ollama` работает **только если образ `ollama/ollama:rocm` ещё на диске**.
> После `--cleanup-old` он удалён → используйте `--vulkan` / `--build` / `--rocm`.

---

## 5. Слоты моделей

| Слот | Модель / квант | Размер | Роль | ctx |
|---|---|---|---|---|
| `coder` | Qwen3.6-35B-A3B **MTP** UD-Q4_K_XL | 22.9 ГБ | основной агент (thinking + MTP) | 64k |
| `coder-std` | Qwen3.6-35B-A3B UD-Q4_K_XL | 22.4 ГБ | то же без MTP (запасной) | 64k |
| `coder30` | Qwen3-Coder-30B-A3B-Instruct UD-Q4_K_XL | 17.7 ГБ | быстрый кодер без think | 64k |
| `chat` | Qwen3.5-9B Q4_K_M + mmproj | 6.6 ГБ | повседнев, русский, vision | 64k |
| `fast` | Qwen3.5-4B Q4_K_M + mmproj | 3.4 ГБ | утилита, ~80 t/s | 32k |
| `reason` | gpt-oss-20b MXFP4 | 12.1 ГБ | быстрый резерв, мало RAM | 32k |
| `ornith` | Ornith-1.5-35B-A3B Q4_K_M | 21.7 ГБ | экспериментальный coder-alt | 64k |
| `chat-unc` | DSv4-Pro-Qwen3.5-9B-heretic + mmproj | 6.4 ГБ | uncensored чат + vision | 32k |
| `fast-unc` | DSv4-Pro-Qwen3.5-4B-heretic + mmproj | 3.2 ГБ | uncensored быстрый | 32k |
| `gemma` | gemma-4-26B-A4B-it UD-Q4_K_XL + mmproj | 18.2 ГБ | daily-alt, ревью, vision | 64k |
| `creative` | DavidAU Defiant-Fable-9B MTP Q4_K_M | 7.0 ГБ | тексты/креатив | 32k |
| `fim` | Qwen2.5-Coder-1.5B-Instruct Q8_0 | 1.9 ГБ | автодополнение `/infill` | 8k |

Базовый набор (`--models` без аргументов) = `coder chat fast reason` ≈ **45 ГБ**.
Все слоты (`--models all`) ≈ **140 ГБ**.

Ориентировочная скорость генерации (не гарантия, смотрите `--bench`):
`fast` ~80 t/s · `chat` ~35–45 · `reason` ~25–35 · `coder`/`coder30` ~15–25 · `gemma` ~20–30 · `ornith` ~12–20.

---

## 6. Пресеты и тюнинг

Файл `~/llm_config/presets.ini`. Секция `[*]` — общее, `[слот]` — per-model.
Ключи = длинные аргументы `llama-server` без `--`. Комментарии — **отдельной строкой** с `;`.

Общее:
```ini
[*]
jinja = true          ; нативные шаблоны и tool-calling
flash-attn = on
threads = 6           ; 6 физических ядер 11600K
threads-batch = 6
n-gpu-layers = 99
parallel = 1
batch-size = 1024
ubatch-size = 512
cache-ram = 2048      ; prompt-кэш в RAM, МБ (дефолт llama.cpp 8192 — слишком много для 32 ГБ)
repeat-penalty = 1.0
```

Главная ручка для MoE — **`n-cpu-moe`**: сколько слоёв MoE-экспертов держать в RAM.
Внимание, общие веса и KV-кэш остаются на GPU. **Меньше = быстрее, но больше VRAM.**

| Значение | Что происходит |
|---|---|
| 34 (старт) | безопасно, ~10–11 ГБ VRAM |
| 32 / 30 | быстрее, следите за VRAM |
| 28 и ниже | риск OOM на 64k контексте |
| 999 | все эксперты в RAM (медленно, но всегда влезает) |

Автоподбор:
```bash
docker stop comfyui          # обязательно: иначе VRAM считается вместе с comfy
start-llm --tune coder
start-llm --bench coder
```
Алгоритм: от текущего значения вниз шагом 4 → перезагрузка пресетов через API →
загрузка модели → замер VRAM через sysfs → стоп при превышении `VRAM_LIMIT` (10800 MiB) →
лучшее значение записывается в presets.ini.

Ручная правка: отредактируйте секцию, затем `start-llm --recreate`.

> ⚠️ **`--models` перегенерирует presets.ini** и сбросит ручной тюнинг.
> После докачки моделей прогоните `--tune` заново. `--recreate` пресеты НЕ трогает.

### KV-кэш
`coder`, `coder-std`, `coder30`, `ornith`, `gemma` используют `q8_0` (экономия ~половины VRAM под контекст).
Если вывод превращается в «кашу» — замените в секции на `f16` и поднимите `n-cpu-moe` на 2–4:
```ini
cache-type-k = f16
cache-type-v = f16
```

### MTP (спекулятивное декодирование)
У `coder` и `creative` включено:
```ini
spec-type = draft-mtp
spec-draft-n-max = 2
```
Даёт ×1.3–2 к генерации без потери качества. Если нестабильно — закомментируйте обе строки
(или переключитесь на слот `coder-std`). Можно попробовать `spec-draft-n-max = 3`.
У `gemma` MTP-драфт качается отдельно (0.46 ГБ), строки в пресете закомментированы.

---

## 7. opencode

Конфиг: `~/.config/opencode/opencode.json` (формат **V2**), агенты: `~/.config/opencode/agents/`.

Что генерит `--opencode`:
- провайдер `local` → `package: @opencode/ai/providers/openai-compatible`, `baseURL: http://127.0.0.1:8080/v1`
- модели = только скачанные слоты, с `capabilities.tools`, `limit.context/output`, `reasoningField`
- агенты `build`, `plan`, `general`, `explore`, `title`, `summary`, `compaction` → **все на одной модели**
- сабагенты `review` (read-only ревью диффа) и `tests` (гоняет тесты/линтеры, чинит)
- запреты: `sudo *`, `rm -rf *`; `git push*` — ask
- отключены плагины автодискавери ollama/lmstudio/vllm

**Почему все агенты на одной модели:** при `--models-max 1` смена модели = выгрузка/загрузка
20+ ГБ и потеря KV-кэша. Если отдать заголовки (`title`) другой модели — сервер будет
свапать веса на каждом сообщении.

Использование:
```bash
cd ~/проект && opencode
# Tab — переключение build/plan, /models — ручная смена модели
# «Use the review subagent to review my changes»
```

В корне проекта положите `AGENTS.md` (стек, структура, команды тестов) — заметно сокращает
число шагов агента на поиск по проекту.

---

## 8. ComfyUI, VRAM и RAM

- Сервер сам засыпает после **30 минут простоя** (`--sleep-idle-seconds 1800`) и освобождает
  VRAM/RAM. Следующий запрос будит модель. Так ComfyUI можно запускать без ручных stop.
- **Не запускайте тяжёлые MoE одновременно с работающим comfyui**: 12 ГБ VRAM и 32 ГБ RAM на двоих не хватит.
- `--tune` откажется работать, если контейнер `comfyui` запущен.
- Бюджет RAM: `coder` ~15–17 ГБ (CPU-эксперты) + prompt-кэш 2 ГБ + ОС/браузер. Впритык, но влезает.
  Лёгкая альтернатива при занятой RAM — `reason` (~4 ГБ RAM).

### Место на /var
Docker-образ живёт в `/var` (LVM `debian-vg/lv-var`). Проверка: `docker system df`, `df -h /var`.
Если мало — сначала `--cleanup-old`, затем Vulkan-образ. Есть 40 ГБ unallocated → можно расширить:
```bash
sudo vgs                                              # смотрим VFree
sudo lvextend -r -L +30G /dev/debian-vg/lv-var        # -r = resize FS онлайн
```

---

## 9. Сеть: зеркала и watchdog

Порядок попыток (образ):
1. `ghcr.nju.edu.cn` — зеркало GHCR (Нанкинский университет)
2. `m.daocloud.io/ghcr.io` — DaoCloud (префикс)
3. `ghcr.m.daocloud.io` — DaoCloud (замена хоста)
4. `swr.cn-north-4.myhuaweicloud.com/ddn-k8s/ghcr.io` — Huawei (только синхронизированные теги)
5. `ghcr.io` — оригинал, последним

**Watchdog скорости**: замер каждые `PROBE=5` с, разогрев `GRACE=15` с, если скорость
ниже `MIN_SPEED_MB=2` — обрыв и переход к следующему зеркалу (~15–20 с вместо 5 минут).
Жёсткий лимит на попытку — `PULL_MAX=900` с. В терминале видно живой счётчик МБ/с.

Модели качаются тем же watchdog; при медленном HuggingFace автоматически ретраятся через
`hf-mirror.com`. Обрыв **не теряет прогресс** — повтор продолжает с места обрыва.

Если канал сам по себе медленный:
```bash
start-llm --speed 1 --models chat        # порог 1 МБ/с
PULL_MAX=3600 start-llm --rocm           # дать часу на большой образ
start-llm --build                        # вообще без ghcr: debian-база + apt + git (~300 МБ)
```

---

## 10. Отмена и аварийная остановка

Ctrl+C может не убивать загрузку: фоновые задачи (`&`) в bash игнорируют SIGINT.
Патч (если ещё не применён) — в начало скрипта:
```bash
set -m
CHILD_PGID=""
on_stop() {
    printf '\n'
    [ -n "$CHILD_PGID" ] && kill -TERM -"$CHILD_PGID" 2>/dev/null
    sleep 1
    [ -n "$CHILD_PGID" ] && kill -KILL -"$CHILD_PGID" 2>/dev/null
    rm -f "${SG_LOG:-}"
    echo "Прервано пользователем."
    exit 130
}
trap on_stop INT TERM
```
и в `speed_guard` после `local pid=$!` добавить `CHILD_PGID=$pid`, а перед каждым `return` — `CHILD_PGID=""`.

Аварийно из другого терминала:
```bash
pgrep -af 'start-llm|hf-cli-venv|docker pull'
pkill -TERM -f 'start-llm'
pkill -TERM -f "$HOME/.local/share/hf-cli-venv/bin/hf"
pkill -TERM -f 'docker pull'
# если не помогло: заменить -TERM на -KILL
```
Смерть клиента `docker pull` не останавливает демон — он докачивает слои.
Реально прервать: `sudo systemctl restart docker` (поднимутся контейнеры с restart-политикой;
`comfyui` в статусе Exited сам не стартует).

Мусор после обрыва: `rm -f ~/llm_config/presets.ini.tmp`; недокачанное лежит в
`~/llm_models/<слот>/.cache/huggingface` (можно оставить — докачается).

---

## 11. Troubleshooting

| Симптом | Причина / решение |
|---|---|
| `presets.ini: моделей 0` / «нет скачанных моделей» | сначала `start-llm --models fast` |
| `--ollama: не вышло использовать` | образ `ollama/ollama:rocm` удалён через `--cleanup-old` → `--vulkan` / `--build` / `--rocm` |
| Образ качается 1 КБ/с | watchdog сам оборвёт; можно `--speed 1`, `--build`, или ночью `--rocm` |
| `нет /dev/kfd` | ROCm не заработает; Vulkan-образ не требует kfd |
| «Docker не запущен или нет доступа» | группа `docker` + **перелогин** |
| OOM VRAM при загрузке | поднять `n-cpu-moe` на 2–4, снизить `ctx-size`, остановить comfy |
| «Каша» в выводе гибрида | KV `q8_0` → `f16` в секции слота |
| Тулзы приходят сырым XML в content | обновить образ (`--update`); для `ornith` — фикс-шаблон (`chat-template-file`); Q4 иногда ломает структуру → Q5 |
| Модель перезагружается на каждом сообщении | все агенты opencode должны смотреть на одну модель (`--opencode` это делает) |
| Порт 8080 занят | скрипт сам останавливает openwebui/ollama/llama-moe/llama-ornith; проверьте прочие сервисы |
| `/var` кончился | `--cleanup-old`, Vulkan-образ, `lvextend` (§8) |
| В образе нет router-mode | `--build` (свежая сборка из master) |
| 120k контекст «тормозит» | prefill 120k токенов = минуты; рабочий режим 32–64k + автокомпакция |

---

## 12. Обслуживание

```bash
start-llm --update           # свежий образ: парсеры тулов Qwen3.5/3.6 активно чинят
start-llm --recreate         # пересоздать контейнер, пресеты целы
start-llm --status           # что загружено, сколько VRAM
docker system df             # место под образы (read-only, безопасно)
df -h /var /home
```

Логи: `--log-opt max-size=20m --log-opt max-file=3` — не съедят `/var`.
Контейнер `--restart unless-stopped` — поднимается после ребута.

---

## 13. Переменные окружения

| Переменная | Default | Смысл |
|---|---|---|
| `FLAVOR` | `vulkan` | `vulkan` \| `rocm` |
| `SOURCE` | `auto` | `auto` \| `ollama` \| `pull` \| `build` |
| `IMAGE` | canonical ghcr | явный образ |
| `OLLAMA_IMAGE` | `ollama/ollama:rocm` | донор бинаря для `--ollama` |
| `MIN_SPEED_MB` | `2` | порог watchdog, МБ/с |
| `PROBE` / `GRACE` | `5` / `15` | период замера / разогрев, с |
| `PULL_MAX` | `900` | жёсткий лимит попытки, с |
| `VRAM_LIMIT` | `10800` | потолок для `--tune`, MiB |
| `HF_ENDPOINT` | пусто | напр. `https://hf-mirror.com` |
| `DEBIAN_BASE` | `debian:trixie-slim` | база для `--build` (можно зеркало) |

---

## 14. API и полезные команды

```bash
curl -s localhost:8080/v1/models | jq '.data[].id'          # что видит opencode
curl -s localhost:8080/models   | jq '.data[] | {id, status}'
curl -s -X POST localhost:8080/models/load   -d '{"model":"coder"}'
curl -s -X POST localhost:8080/models/unload -d '{"model":"coder"}'
curl -s localhost:8080/health
curl -s localhost:8080/metrics | head                        # если образ поддерживает
```

WebUI: `http://127.0.0.1:8080` · OpenAI API: `http://127.0.0.1:8080/v1`
Порт привязан к 127.0.0.1 (в LAN не открыт). FIM-автодополнение: слот `fim`, эндпоинт `/infill`.

---

## 15. Шпаргалка на каждый день

```bash
start-llm                    # включить
start-llm --status           # что с ним
start-llm --bench coder      # скорость
start-llm --logs -f          # что внутри
start-llm --stop             # выключить (освободить GPU под comfy)
cd ~/проект && opencode      # работать
```

---

## 16. Известные ограничения

- **Vulkan vs ROCm**: генерация почти одинаковая, prefill на длинных промптах ниже.
  Для MoE с экспертами в RAM разница невелика; хотите максимум — `--rocm` (18 ГБ загрузки).
- **MTP** — свежая фича llama.cpp; при странностях отключается двумя строками в пресете.
- **`ornith`** — сильные self-reported бенчи, но независимые ниже; известны проблемы
  с chat-шаблоном/тулзами. Держите как эксперимент, не как основной агент.
- **uncensored-слоты** (`chat-unc`, `fast-unc`, `creative`) — для чата/текстов.
  Аблитерация часто задевает instruction following и формат тулзов → в агенты не ставить.
- **`gemma`** — были баги llama.cpp с тул-коллами и повторами на высоком контексте;
  как daily/ревью хорош, как агент — с осторожностью.
- Цифры скорости в §5 — ориентиры для этой машины, не гарантии. Меряйте `--bench`.