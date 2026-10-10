# Etap 1: kompilacja na BYOND 516.1688

Gałąź `byond-516`, baza `aq33/master` 254a9a8328. Kompilator: `C:\Program Files (x86)\byond 516\BYOND\bin\dm.exe`, polecenie `dm.exe -DCBT nsv13.dme`.

## Pierwsza kompilacja (bez zmian): 8 błędów, 1 ostrzeżenie

| Plik:linia | Błąd | Przyczyna |
|---|---|---|
| `code/_compile_options.dm:81` | `#warn` wersja ponad 515.1700 | nasz własny strażnik wersji |
| `code/modules/antagonists/clock_cult/items/clockwork_slab.dm:28` | numbers are not allowed as associative list keys | `list(1 = null, 2 = null, ...)` |
| `code/game/mecha/mecha.dm:29` | j.w. | `list(MECHA_FRONT_ARMOUR = 1.5, ...)`, makra = 1,2,3 |
| `code/datums/hud.dm:76` (lista z linii 6) | j.w. | `GLOB.huds` z kluczami `DATA_HUD_*`/`ANTAG_HUD_*` = 1..34 |
| `code/modules/antagonists/devil/devil.dm:143` (lista z linii 17) | j.w. | `GLOB.lawlorify` z kluczami `LORE`=1, `LAW`=2 |
| `code/controllers/subsystem/processing/station.dm:21` | j.w. | `STATION_TRAIT_*` = 1,2,3 |
| `code/modules/mob/living/silicon/ai/ai_portrait_picker.dm:51` | j.w. | `TAB_LIBRARY/SECURE/PRIVATE` = 1,2,3 |
| `code/modules/modular_computers/file_system/programs/portrait_printer.dm:56` | j.w. | j.w. |
| `code/modules/mob/living/simple_animal/hostile/mining_mobs/hivelord.dm:317` | j.w. | `pickweight(list(1 = 3, 2 = 2, 3 = 1))` |
| `interface/stylesheet.dm:125` | `invalid number: '5000ms'` | patrz niżej |

**`caller` (poprawione później, commit `d9a9369885`):** kompiluje się bez ostrzeżenia, ale w 516 to wbudowane słowo. Argumenty o tej nazwie działają normalnie, za to **zmienna datumu `caller` czytana bez `src.` wewnątrz procedury zwraca wbudowany obiekt wywołujący**. Dotyczyło to tylko `/datum/pathfind` w `code/__HELPERS/path.dm`: pathfinding wszystkich botów był zepsuty (wykryte w CI przez runtime „Invalid A* start or destination”). Zmienna przemianowana na `pathfinding_atom` jak u Bee, `check_grep.sh` blokuje nowe zmienne o tej nazwie.

## Co zrobiono (commit na `byond-516`)

Wszystko według Bee #14444 „Makes the codebase compile on the latest byond version”:

1. **Listy z kluczami liczbowymi → listy pozycyjne**, dawny klucz zostaje w komentarzu `/*KLUCZ = */wartość`. Działa identycznie na 515 i 516, bo DM i tak traktował `list(1 = x, 2 = y)` pozycyjnie. Sprawdziłem, że makra są ciągłe i w kolejności listy:
   - `GLOB.huds`: 1..34 (`code/__DEFINES/atom_hud.dm`), w tym NSV13 `ANTAG_HUD_BLOODLING`=30, `DATA_HUD_SQUAD`=31 i AQ 32–34.
   - `lawlorify`: `LORE`=1, `LAW`=2 (`contracts.dm`).
   - `tab2key` w obu pickerach portretów: TGUI wysyła `tab: tabIndex+1`, czyli 1..3.
2. **hivelord**: `pickweight` z kluczami liczbowymi → `switch(rand(1, 6))` o tych samych wagach 3:2:1 (kod Bee).
3. **stylesheet.dm**: usunięte `animation:` i bloki `@keyframes` dla `.ratvar`, `.ratvarsmall`, `.hypnophrase`, `.phobia` (jak Bee).
4. `MAX_COMPILER_VERSION` 515 → 516 w `_compile_options.dm`.

Wynik: **516.1688: 0 błędów, 0 ostrzeżeń. 515.1633: nadal się buduje.**

## Dlaczego `5000ms` nie przechodzi

Minimalny test (`scratchpad/csstest`): kompilator 516 odrzuca każdą liczbę z jednostką czasu (`5000ms`, `5s`, `5.0s`, `5000MS`, `5e3ms`) w stringu przypisanym do `/client/script`, także w zwykłym `"..."`. Ten sam string w innej zmiennej (`/datum/x/var/s = "x 5000ms y"`) przechodzi. `16px` i `5em` przechodzą. Wygląda na to, że 516 parsuje `/client/script` po swojemu. Nie znalazłem obejścia zachowującego animację, dlatego zrobiłem jak Bee.

## Efekt uboczny: HUD bloodlinga

W `hud.dm:36` klucz brzmiał `ANTAG_HUD_BLOODING`, a makro nazywa się `ANTAG_HUD_BLOODLING` (literówka). DM traktował niezdefiniowaną nazwę jako klucz tekstowy, więc pod indeksem 30 leżał tekst zamiast HUD-a. Po przejściu na listę pozycyjną HUD bloodlinga (`nsv13/code/modules/antagonists/bloodling.dm:274,283`) trafia na właściwy indeks. **Do sprawdzenia w grze**, czy bloodling widzi teraz swoich.

## Co dalej

Etapy 2–4 opisane w `raport/516_etapy_2-4.md`.
