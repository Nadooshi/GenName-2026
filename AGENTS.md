# AGENTS.md

## What this is
GameMaker Studio 2 (GMS2) desktop app that procedurally generates pseudo-Russian
words and phrases. IDE version `2024.14.4.222`. There is no package manager,
build script, test runner, linter, or CI in this repo. Do not invent `npm`/`make`
commands; verification is done by opening the project in the GameMaker IDE and
running it (F5).

## Unusual layout
The actual project is nested one level down: `GenName.yyp/` is a **directory**
containing the `GenName.yyp` project file plus every resource folder
(`scripts/`, `objects/`, `rooms/`, `datafiles/`, `sprites/`, `fonts/`, `options/`).
The git repo root contains only that directory. Paths in this file are relative
to `GenName.yyp/` unless noted.

- Editable logic lives in raw `.gml` files.
- `.yy` files are JSON resource metadata and `GenName.yyp/GenName.yyp` is the
  master resource manifest. The IDE normally owns these; if you add a resource
  by hand you must also register it in `GenName.yyp`.
- Object event files are named `<EventType>_<eventNum>.gml`: `Create_0.gml`,
  `Draw_0.gml`, `Mouse_4.gml`, etc.

## Architecture
- `objects/ob_sylldata/Create_0.gml` is the global-init hub. It declares every
  `globalvar` (`syll_*`, `mx_*`, `range_*`, `lexicon`, `generation_mode`) and
  calls `randomize()`. It must exist in the room and runs before other objects.
- `generation_mode` selects the generator: `0` = syllables (`sc_generate`),
  `1` = lexicon phrases (`sc_lexicon_use`). Set by `sc_sylldata_init`,
  `sc_sylldata_load` (0) and `sc_load_lexicon` (1).
- UI buttons are `ob_button_open` (child of `ob_butt`). Each instance carries
  two object properties, `caption` and `script`, overridden per-instance in
  `rooms/room0/room0.yy` and/or `rooms/room0/InstanceCreationCode_*.gml`. Left
  click runs `script_execute(script)`. To add a button, add a room instance and
  set both properties; do not hardcode behavior in the object.
- `ob_button_generate` and `ob_button_gen_serialNumber` are children of
  `ob_button_open` and call `event_inherited()`.

## Generation pipeline (scripts/)
1. `sc_sylldata_init` loads `datafiles/vowel.txt` + `conson.txt` via `sc_load_syll`
   (single-quoted, comma-separated Cyrillic letters).
2. `sc_make_syll_common` / `sc_make_syll_comrev` / `sc_make_triple` / `sc_make_triprev`
   build CV, VC, CVC, VCV arrays where column 1 is a rating (sum of letter indices).
3. `sc_syll_sort` sorts by rating; `sc_syll_getmax` + `sc_prepare_ranges` build
   exponentially-weighted cumulative `range_*` arrays.
4. `sc_generate_syll_*` / `sc_gen_rev_syll_*` pick a weighted index; `sc_generate`
   concatenates 1-4 syllables. `sc_generate_serial` appends `-<1..999>`.

## Persistence / file formats
- Syllables: `sc_sylldata_save` writes `syll | rating` lines grouped into
  `------` sections (`common`, `reverse`, `triple`, `triprev`); `sc_sylldata_load`
  reads them back. Keep both in sync if you change the format.
- Lexicon: `.txt` file with `------` sections keyed by name. Nouns and adjectives
  are split by gender (`grade_m/_f/_n`, `thing_m/_f/_n`, `decoration_m/_f/_n`);
  `attachment` is gender-invariant. `sc_load_lexicon` fills the `lexicon` struct
  (section name -> word array); `sc_lexicon_use` picks a gender, then matches
  adjectives to it. Adjectives precede the noun.
- File dialogs use `get_open_filename` / `get_save_filename`; file I/O uses the
  legacy `file_text_*` API. Code writes to the default working/save directory.
- `file_text_readln` keeps the line terminator, so always strip both `\r` and
  `\n` before using a line (lexicon files may be LF or CRLF).

## GML style notes
- Legacy dialect is mixed with modern function syntax: functions are declared as
  `function name() { }` but some still use `argument0`; array helpers are
  `array_length_1d/2d`, `array_height_2d`. Match surrounding code rather than
  modernizing.
- Heavy use of `show_debug_message` for tracing; leave debug output intact unless asked.
- Source and data files contain Cyrillic (UTF-8, no BOM). Preserve encoding.

## Repo
- Remote: `https://github.com/Nadooshi/GenName-2026.git`, default branch `master`.
- No `README`, `.gitignore`, or CI. Commit history is minimal.
