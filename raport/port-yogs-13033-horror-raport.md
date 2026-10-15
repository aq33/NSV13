# Port Yogstation#13033 (Eldritch Horror): raport końcowy

Gałąź `port-yogs-13033-horror` (od `aq33/master` @ ac8cfef8a8), worktree `Desktop/NSV13-horror`.
Źródło: [Yogstation#13033](https://github.com/yogstation13/Yogstation/pull/13033) + 15 późniejszych poprawek horrora (lista w `port-yogs-13033-horror-zaleznosci.md`).
Kompilacja: `dm.exe -DCBT nsv13.dme` → 0 błędów, 0 ostrzeżeń. TGUI: `tools\build\build.bat tgui` → zbudowane bez błędów.
Unit testy (`-DCIBUILDING`, lokalny DreamDaemon bez SQL): 80 PASS, 0 FAIL, 0 runtime'ów, `clean_run.lk` = Success (m.in. `antag_datum_sanity`, `gamemode_sanity`, `polish_content`). Lint `check_grep.sh` bez błędów do kroku z `jq` (brak `jq` lokalnie); kroki `.proc/` i końcowych newline'ów sprawdzone ręcznie.

Decyzje: kod w `aquila/`, teksty dla gracza po polsku, event z wagą 10 + tryb secret „traitor+horror” (PROBABILITY 1, MIN_POP 10, MAX_POP -1), headcrab changelinga tylko wyrzuca horrora, bez rogu przywołania.

## 1. Co zmieniłem

### Nowe pliki

| Plik | Zawartość |
| --- | --- |
| `aquila/code/modules/antagonists/horror/horror.dm` | Mob horrora: infekcja, pożeranie dusz, przejmowanie kontroli, wskrzeszanie, wspomnienia, ukrywanie, niewidzialność |
| `aquila/code/modules/antagonists/horror/horror_abilities_and_upgrades.dm` | Zdolności (akcje) i ulepszenia |
| `aquila/code/modules/antagonists/horror/horror_chemicals.dm` | Wstrzykiwanie chemikaliów (`Topic()`) i lista substancji |
| `aquila/code/modules/antagonists/horror/horror_datums.dm` | Antag datum, cele, transporter z uplinku, macka, lokalizator duszy, uwięziony umysł |
| `aquila/code/modules/antagonists/horror/horror_html.dm` | Okno wyboru chemikaliów |
| `aquila/code/modules/antagonists/horror/horror_mutate.dm` | Kupowanie mutacji (backend TGUI) |
| `aquila/code/_onclick/hud/horror.dm` | HUD z licznikiem chemikaliów |
| `aquila/code/modules/events/horror.dm` | Event „Spawn Eldritch Horror” (waga 10, max 2, min. 15 graczy, od 20. minuty) |
| `aquila/code/modules/antagonists/role_preference/role_horror.dm` | Preferencje: roundstart (tryb secret) i duch (event) |
| `aquila/code/game/gamemodes/horror/traitor_horror.dm` | Tryb secret `traitorhorror` |
| `tgui/packages/tgui/interfaces/HorrorMutate.js` | Menu mutacji |
| `aquila/icons/mob/horror.dmi`, `aquila/icons/obj/horror.dmi`, `aquila/icons/effects/horror_beam.dmi`, `aquila/icons/mob/screen_horror.dmi` | Stany wycięte ze wspólnych `.dmi` Yogs |
| `aquila/icons/mob/actions/actions_horror.dmi`, `aquila/icons/mob/inhands/antag/horror_{left,right}hand.dmi` | Skopiowane z Yogs w całości |
| `strings/names/horror.txt` | Imiona horrorów |

### Zmienione pliki

| Plik | Zmiana |
| --- | --- |
| `code/__DEFINES/role_preferences.dm` | `ROLE_HORROR` + wpis w `antagonist_bannable_roles` |
| `code/__DEFINES/is_helpers.dm` | `ishorror()` |
| `code/game/objects/items/devices/scanners.dm` | Zaawansowany analizator wykrywa horrora |
| `code/modules/surgery/organ_manipulation.dm` | Wyciąganie horrora chirurgicznie |
| `code/modules/mob/living/brain/brain_item.dm` | Wyjęcie mózgu wyrzuca horrora |
| `code/modules/mob/living/carbon/death.dm` | Horror ginie przy gibie nosiciela |
| `code/modules/client/verbs/suicide.dm`, `code/modules/projectiles/gun.dm` | Zarażony nie może popełnić samobójstwa ani strzelić do siebie |
| `code/modules/mob/transform_procs.dm` | Zarażonego nie da się zamienić w małpę |
| `code/modules/mob/living/carbon/human/human.dm` | Chemikalia horroru w stat panelu kontrolowanego nosiciela |
| `code/modules/antagonists/changeling/powers/headcrab.dm` | Horror wychodzi przed gibem (bez zmiany `req_stat`) |
| `code/modules/antagonists/changeling/powers/panacea.dm` | Total Purge usuwa horrora |
| `code/controllers/subsystem/traumas.dm` | Horror i macka w fobiach |
| `aquila/code/__DEFINES/traits.dm`, `aquila/code/_globalvars/lists/game.dm` | `HORROR_TRAIT`, `GLOB.horror_names` |
| `aquila/code/modules/uplink/uplink_items.dm` | „Horror w pudełku” dla Bibliotekarza (14 TC, min. 20 graczy) |
| `aquila/aquila.dm` | Includy |
| `aquila/LEGACY_OVERRIDES.md` | Wpisy dla zmian w core |
| `config/game_options.txt` | `PROBABILITY TRAITORHORROR 1`, `CONTINUOUS TRAITORHORROR`, `MIN_POP 10`, `MAX_POP -1` |
| `strings/tips.txt` | 7 wskazówek o horrorze (po polsku) |

## 2. Co odbiega od oryginału i dlaczego

| Miejsce | Różnica | Powód |
| --- | --- | --- |
| Róg przywołania | Pominięty (wraz z abominacjami) | Decyzja 5. Kurator po przebudzeniu horrora nie dostaje rogu do przywoływania go |
| Transporter z uplinku | Usunięta linia `H.mind.add_antag_datum(C)` | W Yogs to błąd: dodaje jako antagonistę obiekt ducha (`observer`), a nie datum |
| Pożeranie duszy, wyjście z nosiciela, przejmowanie kontroli | Własna pętla `do_after_in_host()` zamiast `do_after(..., stayStill = FALSE)` | Nasz `do_after` nie ma `stayStill` i przerywa akcję, gdy nosiciel się ruszy. Pętla przerywa się tylko, gdy horror opuści nosiciela |
| Przejście do innego nosiciela | Zwykły `do_after`, bez `stayStill` | Ten sam brak. Skutek: nosiciel i cel muszą stać w miejscu (w Yogs wystarczyło pozostać obok) |
| Obrażenia | `melee_damage = 10` zamiast `lower/upper = 10`, bonus na cyborgi +7,5 zamiast +5..+10 | Nasze proste moby mają jedną zmienną obrażeń; 7,5 to ta sama średnia |
| Macka | `reach = 2` zamiast `weapon_stats` | Nie mamy systemu broni Yogs; `reach` daje ten sam zasięg 2 pól |
| Śluzy (macka) | `id_scan_hacked()` zamiast `!requiresID()` | Inna nazwa tej samej procedury u nas |
| Sygnał obrażeń | `COMSIG_MOB_APPLY_DAMGE` | U nas tak nazywa się ten sygnał (z literówką) |
| Okno chemikaliów | Wysyła klientowi jQuery przed otwarciem i ma `charset=UTF-8` | U nas jQuery jest assetem; bez tego licznik w oknie się nie odświeża. Charset dla polskich znaków |
| Event | `get_candidates(ROLE_HORROR, /datum/role_preference/midround_ghost/horror)`, waga 10 | Nasz system preferencji ról. Waga z decyzji 3; reszta parametrów jak w PR |
| Tryb `traitorhorror` | Nowy, nie ma go w PR | Decyzja 3. Wybrani gracze nie dostają pracy i na starcie stają się horrorem w punkcie spawnu eventów. Liczba horrorów: tak jak wampirów w traitor+vampire. `CONTINUOUS` jak w traitor+changeling |
| Headcrab changelinga | Bez usunięcia `req_stat = DEAD` | Decyzja 4 |
| Sklep mutacji (`ui_act`) | `text2path()` na typie zdolności i sprawdzanie punktów przed zakupem zdolności i ulepszenia | Błąd z Yogs: TGUI przysyła ścieżkę jako tekst, `istype()` jej nie dopasowuje, więc zdolność dało się kupować w nieskończoność; punktów nikt nie sprawdzał |
| Miejsce spawnu (event i tryb secret) | Tylko punkty `event_spawn` na z-levelu statku (`is_station_level`), przez `horror_spawn_locations()` | Gułag ma własne punkty spawnu eventów na z-levelu kosmosu; horror ma się pojawiać tylko na statku |
| Teksty | Po polsku | Decyzja 2. Nazwy chemikaliów zostały angielskie, bo tak nazywają się reagenty w grze. Nazwa w preferencjach to „Eldritch Horror”, jak Thief i Paradox Clone |
| Ikona podglądu w preferencjach, combat mode, storytellery itd. | Pominięte | Refaktory Yogs, których u nas nie ma |

## 3. Co mogło się zmienić w innych miejscach

- `death.dm` (`/mob/living/carbon/gib()`): każdy gib nosiciela zabija horrora. Wyjątek to headcrab changelinga, który wyrzuca go wcześniej.
- Panacea changelinga wyrzuca teraz horrora i powoduje wymioty.
- Chirurgia: przy manipulacji organami (wyciąganie) na zarażonym zawsze najpierw wychodzi horror. Dzieje się tak w każdej strefie ciała, nie tylko w głowie, bo PR nie sprawdza strefy.
- Zarażonego nie da się zamienić w małpę, nie może też popełnić samobójstwa ani strzelić sobie w usta.
- Tryb `traitorhorror` zastępuje ciało wybranego gracza na starcie rundy. Usuwane jest ludzkie ciało z lobby, które nie dostało pracy.
- Nowa rola w liście banów (`antagonist_bannable_roles`) i nowe wpisy w preferencjach ról.
- Fobia „the supernatural” reaguje na horrora i mackę, a fobia „anime” też na mackę (tak jak w PR).

## 4. Jak przetestować w grze

1. **Spawn:** jako admin uruchom event „Spawn Eldritch Horror” (Trigger Event) albo stwórz moba `/mob/living/simple_animal/horror` i dodaj mu antag datum `Pradawny horror`. Sprawdź HUD z licznikiem i komunikat powitalny.
2. **Infekcja:** Alt+klik na człowieku, 3 s, horror znika w głowie. Sprawdź akcje: rozmowa z nosicielem, skan, chemikalia (okno, wstrzyknięcie, licznik).
3. **Dusze:** „Szukaj duszy” → radial z 4 celami → lokalizator. Wejdź w cel i pożryj duszę (30 s). Nosiciel może przy tym chodzić. Po pożarciu punkty +1, cel traci 20 maks. HP.
4. **Mutacje:** otwórz „Mutacja”, kup np. mackę i „Naelektryzowaną mackę”. Macka w ręce nosiciela: zasięg 2 pól, intencje, podważanie śluzy.
5. **Kontrola:** „Przejmij kontrolę” (20 s). Gracz nosiciela trafia do uwięzionego umysłu i może się opierać. Obrażenia przy ≤75 HP oddają kontrolę. Mindshield i kultyści blokują przejęcie.
6. **Wykrywanie i usuwanie:** zaawansowany analizator pokazuje pasożyta. Operacja manipulacji organami (hemostat) wyciąga horrora. Wyjęcie mózgu też go wyrzuca.
7. **Blokady:** suicide, strzał w usta i monkeyize na zarażonym są zablokowane. Gib nosiciela zabija horrora.
8. **Uplink:** jako zdrajca-Bibliotekarz przy ≥20 graczach kup „Horror w pudełku” (14 TC) i użyj go. Duch dostaje horrora z celem „Służ swojemu przywoływaczowi”.
9. **Tryb secret:** wymuś tryb `traitor+horror` (≥10 graczy, ktoś z preferencją Eldritch Horror w sekcji antagonistów). Wybrany gracz startuje jako horror w punkcie spawnu eventów, bez ciała w lobby. Reszta dostaje zdrajców jak zwykle.
