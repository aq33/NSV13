# Projekt: Aquila NSV13 (fork BeeStation/NSV13)
Język: DM (BYOND). Kod ma polskie elementy, które są ważne.
## Środowisko
- BYOND 515.1633 (źródło prawdy: `dependencies.sh`).
- Plik projektu: `nsv13.dme`.
- Budowanie na Windows: `BUILD.bat` (woła `tools/build`, buduje też TGUI). Sama kompilacja DM: `dm.exe nsv13.dme` z folderu `BYOND\bin`.
- Przed oddaniem zmian zawsze kompiluj. Nowe ostrzeżenia i błędy dreamcheckera napraw.
## Język i teksty
- Nazwy typów, procedur i zmiennych zostają po angielsku.
- Teksty widoczne dla gracza są po polsku.
- Tytuły PR-ów, opisy PR-ów i wpisy changelogu też są po polsku.
- Nie ruszaj istniejących polskich tekstów ani naszych zmian bez pytania.
## Kod Aquili (modularność)
- Nowy kod, ikony i dźwięki idą tylko do `aquila/` (`aquila/code/`, `aquila/icons/`, `aquila/sound/`, `aquila/_maps/`).
- Nowy plik `.dm` dopisz do `aquila/aquila.dm` (ścieżka względna od `aquila/`, backslashe), nie do `nsv13.dme`.
- `aquila/aquila.dm` jest dołączany na końcu `nsv13.dme`. Define potrzebny wcześniej w core musi być w core, z markerem.
- Zmiana zachowania upstreamowego typu: nadpisanie w `aquila/` z wywołaniem `..()`.
- Pełne nadpisanie procki bez `..()` tylko gdy inaczej się nie da, i wtedy obowiązkowo wpis do `aquila/LEGACY_OVERRIDES.md`.
- Edycja pliku core: najmniejszy możliwy hook, oznaczony `// AQ EDIT - powód` (jedna linia) albo `// AQ EDIT START` ... `// AQ EDIT END` (blok). Nowy hook dopisz do tabeli „Core hooks” w `LEGACY_OVERRIDES.md`.
- Same polskie tłumaczenia tekstów w core nie wymagają markera.
- Pełne ścieżki typów i procek (`/obj/item/foo/proc/bar()`). Dreamchecker zabrania definicji względnych (`SpacemanDMM.toml`).
- Zmienne globalne tylko przez `GLOBAL_VAR*` / `GLOBAL_LIST*`.
## Zasady ogólne
- Zanim napiszesz nową funkcję, makro, typ lub system, przeszukaj kod (grep) i sprawdź, czy coś podobnego już istnieje. Jeśli tak, użyj tego albo rozbuduj, zamiast duplikować.
- Rób najmniejszą zmianę, która załatwia zadanie. Nie dodawaj systemów, abstrakcji ani opcji, o które nie proszono.
- Naśladuj styl i wzorce sąsiedniego kodu (nazewnictwo, rejestracja sygnałów, użycie podsystemów).
- Nie refaktoryzuj ani nie formatuj kodu, którego zadanie nie dotyczy.
- Przed zmianą pliku przeczytaj go oraz miejsca, które z niego korzystają (grep po nazwie).
- Jeśli zadanie jest niejasne albo wymaga dużego systemu, napisz krótki plan i listę plików, po czym poczekaj na zgodę.
## Testy
- Nowa logika (nie same sprite'y) dostaje unit test w `aquila/code/modules/unit_tests/`, dołączony w bloku `#ifdef UNIT_TESTS` na końcu `aquila/aquila.dm`.
- Makra `TEST_ASSERT*` są `#undef` na końcu `code/modules/unit_tests/_unit_tests.dm`, więc test modularny ma własne kopie (wzór: `polish_content.dm`).
## CI (`.github/workflows/continuous_integration.yml`)
- Lintery: `tools/ci/check_grep.sh` (m.in. pisownia `CentCom`, mapy w TGM, brak `pixel_x = 0`, zdublowanych obiektów na kafelku), `check_filedirs.sh` (nie zaznaczaj folderów w drzewie DreamMakera), `check_changelogs.sh` (nie ruszaj `html/changelogs/example.yml`), dreamchecker.
- Kompilacja wszystkich map i `run_all_tests`: każdy runtime w trakcie testów to porażka.
- Jeśli CI jest czerwone, najpierw sprawdź, czy master też jest czerwony, zanim zaczniesz szukać błędu w swoim PR.
## Git
- Każde zadanie na osobnej gałęzi. Przed zadaniem sprawdź `git status`.
- Commit po udanej kompilacji. Nie rób commitów z kodem, który się nie buduje.
- Nie pushuj na GitHuba bez wyraźnej prośby.
## Pull request
- Tytuł po polsku: `Obszar: krótki opis (port Repo #NNNN)`.
- Opis według `.github/PULL_REQUEST_TEMPLATE.md`. Przy porcie: link do oryginału i lista różnic względem niego z powodem.
- Changelog między `:cl:` a `/:cl:`, wpisy po polsku, tylko prefiksy z szablonu. Przy porcie autor oryginału po pierwszym `:cl:`.
- Napisz, czy zmiana była testowana w grze i czy TGUI wymaga przebudowy.
## Porty z innych kodów (tgstation, Bee, Yogstation i inne)
- Trzymaj się oryginalnego PR-a. Nie dodawaj funkcji ani refaktorów, których w nim nie ma.
- Przy większych PR-ach najpierw wypisz zależności (czego brakuje w naszym kodzie) i poczekaj na „dalej”.
- Jeśli PR zależy od czegoś, czego nie mamy, zapytaj: portować zależność, uprościć czy pominąć.
- Nie nadpisuj naszych modyfikacji. Wypisz miejsca kolizji.
- Sprawdź, czy PR miał poprawki po wcieleniu w oryginalnym repo, i je uwzględnij.
- Pomijaj mapy, testy screenshotowe i inne elementy, których nasz kod nie obsługuje, chyba że napisano inaczej.
- Licencje: zwróć uwagę, skąd pochodzą ikony i dźwięki.
## Synchronizacja z upstreamem (BeeStation/NSV13)
- Historia jest squashowana, `git merge-base` nic nie znajduje: porównuj drzewa, nie historię.
- Przejdź `aquila/LEGACY_OVERRIDES.md` i każdy `AQ EDIT` w zmienionych plikach.
## Mapy (.dmm)
- Zmiany tylko precyzyjne i drobne (na podstawie współrzędnych lub jednoznacznego opisu).
- Nie ruszaj instalacji (rury, kable, zasilanie, wentylacja) bez pytania.
- Zapisuj w formacie TGM (hooki mapmerge: `tools/hooks/Install.bat`), inaczej CI odrzuci mapę.
- Po zmianie napisz, co dokładnie zmieniłeś, żeby dało się to obejrzeć w StrongDMM.
## Koniec każdego zadania
Napisz:
1. Co zmieniłeś (pliki).
2. Co odbiega od oryginału lub od planu i dlaczego.
3. Co mogło się zmienić w innych miejscach.
4. Jak to przetestować w grze.
## Recenzje i analizy
- Przy przeglądzie kodu nie zmieniaj plików, tylko pisz raport (numery linii, ocena ryzyka).
- Raporty zapisuj partiami poza repo (nie commituj ich).
## Błędy, których nie powtarzamy
(Dopisuj tu wnioski, np. „Nie używaj X, bo u nas psuje Y”.)
