# Plan przejścia na BYOND 516

Gałąź: `byond-516` (worktree `NSV13-516`, baza `aq33/master` = 254a9a8328).
Źródło: Bee #12240 „516 Support” (+464/−429, 106 plików) i poprawki #12366, #12503, #12707, #12888, #12919, #12936, #12937, #13029, #14444.
Nic w kodzie jeszcze nie zmieniono. To analiza diffów Bee porównana z naszym drzewem.

## Co zmienia 516 i dlaczego to boli

1. **Klient wyświetla HTML przez WebView2 (Chromium) zamiast Internet Explorera.** Dotyczy TGUI, czatu (tgui-panel), okien `browse()` i `datum/browser`.
2. **Względne linki `?src=...` w `browse()` przestają trafiać do `Topic()`.** Trzeba je zamienić na `byond://?src=...`. U nas: **1426 wystąpień w `code/`, 21 w `nsv13/`**, 183 miejsca już mają `byond://`.
3. **`localStorage` nie działa w WebView2.** Zamiast niego jest `byondstorage` (`window.hubStorage`). Bez tej zmiany czat nie zapamiętuje ustawień ani historii.
4. **`caller` jest słowem zastrzeżonym kompilatora.** U nas **120 użyć w ~30 plikach**. To blokuje kompilację.
5. Drobiazgi: CSS Chromium, pasek menu przy wyjściu z pełnego ekranu, auto-scroll czatu, 404 przy ładowaniu CSS w `tgui.html`.

## Co u nas wygląda inaczej niż u Bee (w momencie #12240)

| Element | Bee | My | Skutek |
|---|---|---|---|
| TGUI | React (#12204) | Inferno 8 | Zmiany `.tsx` w #12240 przenosimy ręcznie, nie 1:1. Są małe (CSS, `Window.tsx`, `Box.tsx`). |
| `render_plate.dm` (plane cube) | jest | **nie ma** | Poprawka `relay.screen_loc` nas nie dotyczy. |
| `spritesheet_batched` (IconForge) | jest | **nie ma** | Pomijamy. |
| Screentips | są | **nie ma** | #13029 pomijamy. |
| Pref pełnego ekranu | datum `fullscreen.dm` | w `preferences.dm` (nasz kod, „NSV13 - fullscreen”) | #12919, #12936 nakładamy ręcznie w naszym miejscu. |
| `HTML_SKELETON` makro | dodaje w `html_assistant.dm` | **nie mamy** tego pliku | Makro dodamy w istniejącym pliku z makrami HTML (do wskazania przy porcie). |
| `tgui-panel` przełączanie output | `winset` na `output`/`browseroutput` | tak samo (`index.js:81-114`, `skin.dmf:261`) | #12888 (z-fighting) pasuje do naszego kodu. |
| Node/Yarn do budowy TGUI | w repo bootstrap | mamy `tools/bootstrap/node_.ps1` (pobiera Node 18.14.2 z `dependencies.sh`) | Rebuild TGUI powinien działać bez instalacji Node. Do sprawdzenia. |
| Atmosfera | LINDA | auxmos 2.5.2-b przez byondapi | Teoretycznie niezależne od 516. Test w grze. |

## Etapy

### Etap 0: narzędzia (po Twojej stronie)
- Zainstalować BYOND **516.1688** (instalator w `Downloads`) do **osobnego folderu**, np. `C:\BYOND516`, żeby 515 zostało do porównań.
- Potem w `CLAUDE.md` dopisać drugą ścieżkę do `dm.exe`.

### Etap 1: kompilacja na 516 (tani test, pokazuje skalę)
- `dm.exe -DCBT nsv13.dme` kompilatorem 516.
- Spodziewane błędy:
  - `caller` jako nazwa argumentu/zmiennej → zmiana nazwy na `requester`/`user`/`invoker` tak jak u Bee (lista plików w załączniku A).
  - `#warn` o wersji ponad `MAX_COMPILER_VERSION 515` (`code/_compile_options.dm:78`) → podnieść do 516.
  - Rzeczy z #14444 (kompilacja na najnowszym BYOND): `food.dm`, `station.dm`, `immutable_mixtures.dm`, `reactions.dm`, `mining_corpses.dm`, `stylesheet.dm`. Sprawdzimy po pierwszym logu, czy nas dotyczą.
- Wynik etapu: lista błędów i ostrzeżeń w `raport/516_kompilacja.md`.

### Etap 2: strona DM (z #12240)
- `client_procs.dm` przy logowaniu: `winset(src, null, list("browser-options" = "find,refresh,byondstorage"))` dla `byond_version >= 516`.
- Verb `OOC → Enable TGUI Devtools` (`tgui_panel/external.dm`), żeby dało się debugować okna.
- Makro `HTML_SKELETON` i owinięcie nim okien `browse()` bez `<html>` (Bee zrobiło to w ~20 miejscach; u nas `browse()` występuje 167 razy, większość ma własny szkielet lub idzie przez `datum/browser`).
- `MAX_COMPILER_VERSION` → 516; `client_max_version` w konfigu.
- `manuals.dm`: usunięcie ręcznego `<html><head>` z książek (duplikuje się ze szkieletem).
- Poprawki pełnego ekranu (#12919, #12936) w naszym kodzie prefów.

### Etap 3: strona TGUI (wymaga rebuildu bundla)
- `tgui/packages/common/storage.js` → backend `hubStorage` (z #12240; diff jest czysty, przeniesiemy jako JS bez TypeScriptu).
- `tgui/global.d.ts`: typy `BLINK`, `hubStorage` itd.
- CSS pod Chromium: `Layout.scss`, `Dimmer.scss`, `Input.scss`, `TextArea.scss`, `PopupWindow.scss`, `Box.tsx` (`!important` w inline style nie działa w Chromium).
- `tgui/public/tgui.html`: `onerror` dla CSS (#12503). To plik publiczny, bez rebuildu.
- `tgui-panel/chat/renderer.jsx`: auto-scroll (#12707).
- `tgui-panel/index.js` + `skin.dmf` + `external.dm`: przełącznik `legacy_output_selector` zamiast ukrywania (#12888).
- `tgui-say`: skalowanie DPI (#12937), tylko jeśli mamy TGUI Say (NSV13 #2618 przeniósł TGUI Say, więc prawdopodobnie tak).

### Etap 4: linki `byond://` (#12366)
- Mechaniczna zamiana `href='?src=` → `href='byond://?src=` (i warianty `?_src_=`, `href="?`) w ~1450 miejscach.
- Robimy skryptem, nie ręcznie. Potem reguła w `tools/ci/check_grep.sh`, jak u Bee.
- Osobny commit, żeby diff dało się przejrzeć.

### Etap 5: test w grze (po Twojej stronie, klient 516)
1. Logowanie: czy pojawia się czat (tgui-panel) i czy po restarcie klienta pamięta ustawienia i historię.
2. Panel statystyk i zakładki verbów.
3. Kilka okien TGUI: preferencje, PDA, autolathe, dowolne okno NSV (np. konsola overmapy).
4. Okna `browse()`: książka z `manuals.dm`, panel admina (Player Panel), VV, prefy postaci (nasze stare okno `preferences.dm` oparte o `?_src_=prefs`).
5. Pełny ekran włącz/wyłącz, pasek menu.
6. Atmosfera: czy auxmos startuje bez błędów w logu (`SSair`).
7. To samo na kliencie 515, bo nadal ma działać.

## Czego nie przenosimy z #12240

- `render_plate.dm` (nie mamy plane cube).
- `spritesheet_batched` (nie mamy IconForge).
- Zmiany w interfejsach React (`Newscaster.jsx`, `PreferencesMenu/*`, `ColorPickerModal`, `LanguageMenu`) – nie mamy tych okien lub mamy inne wersje. Każde sprawdzimy osobno.
- #13029 (ikony screentips).
- #14285 „Kills 515 TGUI support” – dopiero po tym, jak 515 przestanie być potrzebne.

## Ryzyka

- **TGUI Inferno vs React:** CSS i `Window.tsx` są podobne, ale trzeba czytać nasz kod, nie kopiować.
- **Rebuild bundla TGUI:** bootstrap Node z `tools/bootstrap` może nie działać offline albo na nowszym Windowsie. Sprawdzimy przy pierwszym buildzie.
- **1450 linków:** skrypt może trafić w teksty po polsku lub w `nsv13/`. Diff przejrzeć przed commitem.
- **Auxmos:** jeśli nie wstanie na 516, osobne zadanie (nowsza wersja auxmos lub LINDA).

## Załącznik A: pliki z `caller` (30, 120 użyć)

```
code/datums/holocall.dm
code/game/machinery/doors/airlock.dm
code/game/machinery/doors/firedoor.dm
code/game/machinery/porta_turret/portable_turret.dm
code/game/objects/objs.dm
code/game/objects/structures/girders.dm
code/game/objects/structures/grille.dm
code/game/objects/structures/plasticflaps.dm
code/game/objects/structures/railings.dm
code/game/objects/structures/tables_racks.dm
code/game/objects/structures/window.dm
code/game/turfs/turf.dm
code/modules/admin/verbs/adminpm.dm
code/modules/antagonists/clock_cult/scriptures/_clockwork_scripture.dm
code/modules/antagonists/cult/blood_magic.dm
code/modules/antagonists/cult/cult_comms.dm
code/modules/antagonists/traitor/equipment/Malf_Modules.dm
code/modules/asset_cache/asset_cache_client.dm
code/modules/guardian/abilities/minor/teleport.dm
code/modules/guardian/abilities/_ability.dm
code/modules/mob/living/carbon/alien/humanoid/alien_powers.dm
code/modules/mob/living/simple_animal/bot/bot.dm
code/modules/mob/living/simple_animal/hostile/giant_spider.dm
code/modules/modular_computers/computers/item/computer.dm
code/modules/modular_computers/computers/item/processor.dm
code/modules/modular_computers/computers/item/tablet.dm
code/modules/paperwork/paper.dm
code/modules/spells/spell.dm
code/modules/spells/spell_types/aimed.dm
code/modules/spells/spell_types/pointed.dm
```
Większość to `CanAStarPass(..., atom/movable/caller)` (pathfinding) i `InterceptClickOn(mob/living/caller, ...)`. Bee zmieniło na `requester` i `user`.
