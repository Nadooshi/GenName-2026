/// @desc Load the combined database (.txt): syllable sections + lexicon sections
function sc_load_database() {
	var _path = get_open_filename("*.txt", "database.txt")

	// dialog cancelled or file not readable
	if (_path == "") exit
	if not file_exists(_path) {
		show_message("Не удалось открыть базу:" + chr(13) + _path)
		exit
	}

	// reset state before (re)loading
	syll_ready = false
	lex_ready = false
	lexicon = {}

	var _section = ""
	var _is_syll = false
	var _n = 0
	var _line, _word, _rating
	var _file = file_text_open_read(_path)

	while not file_text_eof(_file) {
		_line = file_text_readln(_file)
		// strip the line ending (CR, LF or CRLF, whichever the file uses)
		_line = string_replace_all(_line, "\r", "")
		_line = string_replace_all(_line, "\n", "")

		// a "------" line is followed by the name of the section
		if (string_pos("------", _line) > 0) {
			_line = file_text_readln(_file)
			_section = string_replace_all(_line, "\r", "")
			_section = string_replace_all(_section, "\n", "")

			_is_syll = (_section == "common") or (_section == "reverse") or (_section == "triple") or (_section == "triprev")
			_n = 0
			if (_section != "") and not _is_syll and not variable_struct_exists(lexicon, _section)
				lexicon[$ _section] = []
			continue
		}

		// skip blank lines and anything before the first section header
		if (_line == "") continue
		if (_section == "") continue

		if (_is_syll) {
			// syllable line: "syllable | rating"
			if (string_pos(" | ", _line) == 0) continue
			_word   = string_copy(_line, 1, string_pos(" | ", _line) - 1)
			_rating = real(string_digits(_line))
			switch (_section) {
				case "common":
					syll_common[_n, 0] = _word; syll_common[_n, 1] = _rating; break
				case "reverse":
					syll_common_reverse[_n, 0] = _word; syll_common_reverse[_n, 1] = _rating; break
				case "triple":
					syll_triple[_n, 0] = _word; syll_triple[_n, 1] = _rating; break
				case "triprev":
					syll_triple_reverse[_n, 0] = _word; syll_triple_reverse[_n, 1] = _rating; break
			}
			_n++
			syll_ready = true
		} else {
			// lexicon line: a plain word
			array_push(lexicon[$ _section], _line)
			lex_ready = true
		}
	}

	file_text_close(_file)

	if syll_ready sc_prepare_ranges()

	show_debug_message("database loaded: " + _path)
}

/// @desc Load syllable data (kept for the existing button; loads the whole database)
function sc_sylldata_load() {
	sc_load_database()
}
