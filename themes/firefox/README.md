# Firefox — Tokyo Night

Тема-аддон для Firefox в формате магазина AMO: не `userChrome.css`, а
декларативный WebExtension `manifest.json` с `theme.colors`.

## Файлы

- `TokyoNight/manifest.json` — исходник темы;
- `TokyoNight/icon-48.png`, `icon-96.png` — иконки аддона;
- `TokyoNight-1.0.0.xpi` — собранный пакет для установки.

Палитра: фон `#1a1b26`, текст `#c0caf5`, классический синий акцент
`#7aa2f7` (вкладка, фокус URL-бара, внимание). Тёмная схема для страниц
включена через `properties.colorScheme` / `contentColorScheme`.

## Собрать заново

```bash
cd themes/firefox/TokyoNight
zip -r ../TokyoNight-1.0.0.xpi manifest.json icon-48.png icon-96.png
```

После правки `manifest.json` подними `version`, иначе Firefox/AMO не
увидит обновление.

## Установить

**Временно, без подписи** — до перезапуска Firefox:

1. `about:debugging#/runtime/this-firefox`
2. «Load Temporary Add-on»
3. выбрать `themes/firefox/TokyoNight/manifest.json`.

**Постоянно** — нужен подписанный `.xpi`:

- загрузить `TokyoNight-1.0.0.xpi` на [addons.mozilla.org](https://addons.mozilla.org/developers/)
  и установить подписанную версию;
- либо в Firefox ESR отключить обязательную подпись
  (`xpinstall.signatures.required = false` в `about:config`) и открыть `.xpi`
  через `File → Open` — это менее безопасно.

## Акцент

Сейчас акцент классический синий `#7aa2f7`. Для тёплого варианта
поменяй в `theme.colors`:

- `tab_line`
- `tab_loading`
- `toolbar_field_border_focus`
- `toolbar_field_highlight`
- `icons_attention`

на `#ff9e64` и пересобери `.xpi`.

## Ограничения

Тема магазина не умеет менять форму вкладок, отступы, меню и адресную
строку — только цвета и картинки. Для полного вида нужен `userChrome.css`,
а не аддон.
