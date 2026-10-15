# Port Yogstation#13033 (Eldritch Horror): zależności i decyzje

Gałąź: `port-yogs-13033-horror` (od `aq33/master` @ ac8cfef8a8), worktree `Desktop/NSV13-horror`.
Źródło: https://github.com/yogstation13/Yogstation/pull/13033 (merge 4d369ae1dbd, 2022-02-02), +2147 linii, 38 plików.

## 1. Poprawki po merge'u

Przejrzałem wszystkie 33 commity Yogs, które później dotykały plików horrora.

### Do uwzględnienia (zmiany samego horrora)

| PR | Co zmienia |
| --- | --- |
| #13234 | Nerf: dłuższe czasy (wejście 4 s, pożeranie 30 s, wyjście 30 s, przeskok 30/20/10/5/3 s), usunięte ulepszenia „Electrocharged tentacle” i „Reflective fluids” |
| #13610 | Własny opis przy oglądaniu horrora, poprawne zaimki w komunikatach |
| #14314 | Przywraca „Electrocharged tentacle” (w nowej wersji), komunikat o wejściu do głowy, wyjście 10 s, regeneracja chemikaliów +3 |
| #14511 | Panel Check Antagonists pokazuje hosta horrora |
| #15488 | Pasek przewijania w menu mutacji (TGUI) |
| #15490 | Balance 1.1: smar 50 chem / 2 dusze bez pętli `sleep`, ząbki +5 obrażeń z bonusem na cyborgi |
| #15641 | `see_in_dark` 8 |
| #15917 | Poprawka wskrzeszania (zła zmienna: `target` zamiast `victim`) |
| #16548 | Wejście do głowy 3 s |
| #19032 | `return ..()` w `AltClickOn` |
| #20439 | `lighting_alpha` (lepsze widzenie w ciemności) |
| #20936 | Nowa zdolność „Host Scan”, komunikat o ilości wstrzykniętych jednostek |
| #21326 | Literówka: salicylic acid |
| #19619 | Cena w uplinku 16 → 14 TC |
| #22996 | Linki `byond://` w oknie chemikaliów (zgodność z BYOND 516, działa też na 515) |

### Pomijam (tylko line endings, refaktory Yogs albo rzeczy, których nie mamy)

| PR | Powód |
| --- | --- |
| #13406 | Wyłącznie zmiana końców linii |
| #13370, #19203, #17366, #14207, #14161 | Kosmetyka, styl i kolejność argumentów; tam, gdzie pasuje, stosuję je przy dostosowaniu do naszego API |
| #16178, #19632 | `obj/screen` → `atom/movable/screen`: u nas już jest nowa nazwa, więc piszę od razu tak |
| #18669 | `PROC_REF`: używam tego, co mamy u nas |
| #18514 | API Yogs (weakref `enslaved_to`, `ANTAG_MAPTEXT`, `show_to`); u nas zostaje stare API |
| #17216 | Nowy system keybindów Yogs |
| #17381 | Menu preferencji TGUI Yogs (ikona podglądu) |
| #19115 | Sygnatura `Life()` z Yogs |
| #19813 | Usunięcie `do_mob` w Yogs; u nas `do_mob` nadal istnieje |
| #21221 | Nowy system oświetlenia Yogs |
| #21883 | Combat mode zamiast intencji; u nas są intencje |
| #13538, #21995 | Przeniesienie ikon między plikami .dmi w Yogs |
| #22661 | Yogs usunął event na rzecz storytellerów; my zostajemy przy evencie |
| #22910 | Yogs wyłączył traumę split personality i zakomentował jej sprawdzenie w horrorze; u nas trauma działa, więc blokada zostaje |

## 2. Zależności w naszym kodzie

Prawie wszystko istnieje: `do_mob`, `healthscan`, `chemscan`, `hasSoul`, `enslaved_to`, `agent_pinpointer`, `TRAIT_BADDNA`/`CHANGELING_DRAIN`, `reverseRange`, `generic_event_spawns` (landmarki są na mapach statków), `MakeSlippery`, `grippedby`, `split_personality`, `span_*`, wszystkie 10 reagentów i interfejsy TGUI w .js.

| Brak lub różnica | Rozwiązanie |
| --- | --- |
| `COMSIG_MOB_APPLY_DAMAGE` | U nas ten sygnał nazywa się `COMSIG_MOB_APPLY_DAMGE` (z literówką); używam go |
| `do_after(..., stayStill = FALSE)` | U nas nie ma tego argumentu: gdy host chodzi, `do_after` się przerywa. Dostosowuję wywołania, żeby zachowanie było jak w oryginale |
| `get_candidates(ROLE, null, ROLE)` | U nas wymaga datumu preferencji roli: dodaję `/datum/role_preference/midround_ghost/horror` (wzór: paradox_clone) |
| `special_roles` / lista banów | U nas bany idą przez `GLOB.antagonist_bannable_roles`; tam dopisuję `ROLE_HORROR` zamiast edytować `sql_ban_system.dm` |
| `/obj/effect/temp_visual/summon` | Brak, dodaję z PR (1 typ + ikona) |
| `/mob/living/simple_animal/hostile/abomination` | Brak. Róg kuratora ma 20% szans przywołać losową „abominację” zamiast horrora. To moby Yogs (`yogstation/.../abominations.dm`, 68 linii, 6 typów, `horrors.dmi`), używane też przez changelinga Yogs. Decyzja 5 |
| Stat panel hosta (`human.dm`) | U nas `get_stat_tab_status()`; dostosowuję |
| Sprite'y | Stany w `animal.dmi`, `effects.dmi`, `beam.dmi`, `screen_gen.dmi`, `items_and_weapons.dmi` + 3 nowe pliki .dmi |

## 3. Miejsca kolizji z naszymi zmianami

| Plik | Nasze zmiany | Uwagi |
| --- | --- | --- |
| `human.dm` | 3× AQ, 12× Nsv13 | Hunk stat panelu; dopisuję obok |
| `gun.dm` | 3× AQ, 1× Nsv13 | Blokada strzału do siebie; sprawdzę przed edycją |
| `headcrab.dm` | `dna_cost` (Nsv13) | PR usuwa też `req_stat = DEAD`, czyli zmiana dla changelinga niezwiązana z horrorem (decyzja 4) |
| `scanners.dm`, `names.dm` | 1–3 znaczniki | Bez nakładania |
| `organ_manipulation.dm`, `brain_item.dm`, `suicide.dm`, `death.dm`, `transform_procs.dm`, `panacea.dm`, `traumas.dm` | Brak | Czyste |

## 4. Licencje

Kod Yogstation jest na AGPLv3 (jak u nas), a ikony i dźwięki na CC BY-SA 3.0. Dźwięki pochodzą z istniejących plików, nowych nie ma. W commicie i changelogu podam pochodzenie sprite'ów (Yogstation#13033, autor ChesterTheCheesy).

## 5. Decyzje do podjęcia

1. **Miejsce kodu:** proponuję `aquila/code/modules/antagonists/horror/` i `aquila/icons/` (nowe pliki .dmi zamiast dopisywania stanów do wspólnych `animal.dmi` itd.), a zmiany w core jako jednolinijkowe `AQ EDIT` z wpisem w `LEGACY_OVERRIDES.md`.
2. **Teksty:** zostawić po angielsku jak w PR czy przetłumaczyć na polski (ok. 250 linii z tekstem dla gracza)?
3. **Spawn:** PR ma tylko event (max 2, min. 15 graczy, od 20. minuty) i przedmiot w uplinku kuratora. Ruleset dynamic nie jest częścią PR, więc go nie dodaję, chyba że chcesz.
4. **Headcrab changelinga:** przenieść zdjęcie wymogu „martwy” (`req_stat = DEAD`) z PR czy tylko wyrzucanie horrora przed gibem?
5. **Abominacje z rogu:** przenieść 6 mobów z Yogs (68 linii + sprite'y), uprościć (np. przywołać istniejącego wrogiego moba) czy pominąć tę 20-procentową szansę?
