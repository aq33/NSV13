# Konwerter domen bitrunningu (tg -> Aquila)

Skrypt `convert_domains.py` przenosi mapy domen wirtualnych z tgstation
(`_maps/virtual_domains/*.dmm`) do naszego kodu i zapisuje je w `_maps/virtual_domains/`
pod tymi samymi nazwami (format TGM).

## Uruchomienie

Potrzebny jest checkout tgstation (wystarczy sparse z `code/`, `_maps/virtual_domains`,
`_maps/safehouses` i `strings/modular_maps`) oraz Python 3.

```
python tools/bitrunning/convert_domains.py <ścieżka do tg> [nazwa_mapy ...] [--report raport.md]
```

Bez nazw map konwertowane są wszystkie domeny. `--report` zapisuje listę pominiętych obiektów,
przybliżeń i odrzuconych zmiennych dla każdej mapy. Na końcu skrypt wypisuje typy tg, dla których
nie znalazł odpowiednika – trzeba je dopisać do `mapping.json`.

Po konwersji sprawdź kompilację: skopiuj `nsv13.dme` do pliku tymczasowego, dopisz
`#include "_maps\virtual_domains\<mapa>.dmm"` i skompiluj `dm.exe -DCBT`. CI robi to samo przez
`tools/ci/template_dm_generator.py` (folder `_maps/virtual_domains` jest na liście).

## Jak to działa

1. **Kryjówka** – `/obj/modular_map_root/safehouse{key}` jest zastępowany mapą
   `_maps/safehouses/<plik>.dmm` z tg (klucz -> plik z `strings/modular_maps/safehouse.toml`),
   wyrównaną do `/obj/modular_map_connector`, tak jak robi to tg w czasie gry. Podłoga/obszar
   `template_noop` kryjówki zostawia podłogę/obszar domeny; obiekty domeny na polach kryjówki
   zostają (mapy kładą tam sprzęt startowy), kryjówka dokłada swoje.
2. **Indeksy** – skrypt czyta nasz kod (`code`, `aquila`, `nsv13`, `_maps`) i buduje listę typów
   oraz zadeklarowanych zmiennych; z tg czyta makra `MAPPING_DIRECTIONAL_HELPERS` (przesunięcia
   pikseli) i definicje spawnerów `/obj/effect/spawner/random/*`.
3. **Tłumaczenie obiektu** (kolejność):
   `exact` z `mapping.json` -> warianty `/directional/<kierunek>` (jeśli u nas nie ma takiego
   podtypu: typ bazowy + `dir` i `pixel_x/y` z tg) -> `style_N`/`style_random` (zdejmowane) ->
   spawnery losowe (nasz `lootdrop` o tej samej nazwie albo `/obj/effect/spawner/lootdrop`
   z przetłumaczoną, spłaszczoną listą łupów tg) -> naklejki podłogowe (kafelki, siding, trimline
   z kolorem i stanem ikony) -> `prefix` -> typ istniejący u nas bez zmian. Czego nie da się
   przetłumaczyć, jest pomijane i trafia do raportu.
4. **Zmienne** – zmienne, których nasz typ nie ma, są odrzucane; `req_access` z nazwami tg
   zamieniane na `req_access_txt` (tabela `access`); ścieżki typów w wartościach też są tłumaczone;
   `var_rename` i `dir_fix` poprawiają różnice w znaczeniu zmiennych i kierunkach sprite'ów.
5. **Helpery tg** (`"helper"` w `mapping.json`): `turf_state` (uszkodzona/spalona podłoga),
   `turf_replace` (`broken_flooring`), `set_var` (np. dostęp syndykatu na drzwiach, zaspawane
   śluzy), `drop`.

## Pliki

- `convert_domains.py` – konwerter,
- `mapping.json` – tablice tłumaczeń (tu dopisuje się nowe typy),
- `dmm.py` – parser/zapis map (TGM i klasyczny format).

Drobne typy, których brakowało (np. `/turf/open/indestructible/permalube`), są w
`aquila/code/modules/bitrunning/virtual_domain/domains/domain_types.dm`.
