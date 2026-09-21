/// @desc Load a lexicon (.txt) file into the `lexicon` struct
function sc_load_lexicon() {
	var _path = get_open_filename("*.txt", "lexicon.txt")

	// dialog cancelled or file not readable
	if (_path == "") exit
	if not file_exists(_path) {
		show_message("Не удалось открыть лексикон:" + chr(13) + _path)
		exit
	}

	// fresh struct: section name -> array of words
	lexicon = {}
	var _section = ""
	var _line

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
			if (_section != "") and not variable_struct_exists(lexicon, _section)
				lexicon[$ _section] = []
			continue
		}

		// skip blank lines and anything before the first section header
		if (_line == "") continue
		if (_section == "") continue

		array_push(lexicon[$ _section], _line)
	}

	file_text_close(_file)

	generation_mode = 1
	show_debug_message("lexicon loaded: " + _path)
}
