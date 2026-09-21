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
  `globalvar` (`syll_*`, `mx_*`, `range_*`, `lexicon`, `syll_ready`, `lex_ready`)
  and calls `randomize()`. It must exist in the room and runs before other objects.
- One data file (`datafiles/database.txt`) holds both syllable and lexicon
  `------` sections. `sc_load_database` (defined in `sc_sylldata_load.gml`) routes
  by section name: `common`/`reverse`/`triple`/`triprev` -> syllable arrays (sets
  `syll_ready`), anything else -> the `lexicon` struct (sets `lex_ready`).
  `sc_sylldata_load` and `sc_load_lexicon` are thin wrappers around it.
- UI buttons are `ob_button_open` (child of `ob_butt`). Each instance carries
  two object properties, `caption` and `script`, overridden per-instance in
  `rooms/room0/room0.yy` and/or `rooms/room0/InstanceCreationCode_*.gml`. Left
  click runs `script_execute(script)`. To add a button, add a room instance and
  set both properties; do not hardcode behavior in the object.
- `ob_button_generate` (child of `ob_button_open`) overrides `Mouse_4`, calls
  `event_inherited()` first, and when `script` is `noone` shows `sc_generate_all`
  (word + serial + lexicon phrase + character name, joined by `\n`). It asks for
  `sc_load_database` when neither `syll_ready` nor `lex_ready`.

## Generation pipeline (scripts/)
1. `sc_sylldata_init` loads `datafiles/vowel.txt` + `conson.txt` via `sc_load_syll`
   (single-quoted, comma-separated Cyrillic letters).
2. `sc_make_syll_common` / `sc_make_syll_comrev` / `sc_make_triple` / `sc_make_triprev`
   build CV, VC, CVC, VCV arrays where column 1 is a rating (sum of letter indices).
3. `sc_syll_sort` sorts by rating; `sc_syll_getmax` + `sc_prepare_ranges` build
   exponentially-weighted cumulative `range_*` arrays.
4. `sc_generate_syll_*` / `sc_gen_rev_syll_*` pick a weighted index; `sc_generate`
   concatenates 1-4 syllables. `sc_generate_serial` appends `-<1..999>`.
5. `sc_generate_all` calls `sc_generate`, `sc_generate_serial`, `sc_lexicon_use`
   and `sc_generate_name`, skips empty results and joins with `\n`.

## Persistence / file formats
- `datafiles/database.txt` is the combined file. Syllable sections
  (`common`, `reverse`, `triple`, `triprev`) use `syllable | rating` lines;
  lexicon sections (`grade_m/_f/_n`, `thing_m/_f/_n`, `decoration_m/_f/_n`,
  `attachment`) hold one word per line. Adjectives precede and agree in gender
  with the noun. Character-name sections are `name_m/_f`, `patronymic_m/_f`
  and `surname_m/_f` (gender-matched, combined by `sc_generate_name`).
- `sc_sylldata_save` still writes only the syllable sections (default
  `syll.txt`); it does not include the lexicon. Keep its output in sync with the
  loader if you change the format.
- File dialogs use `get_open_filename` / `get_save_filename`; file I/O uses the
  legacy `file_text_*` API. Code writes to the default working/save directory.
- `file_text_readln` keeps the line terminator, so always strip both `\r` and
  `\n` before using a line (data files may be LF or CRLF).

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
