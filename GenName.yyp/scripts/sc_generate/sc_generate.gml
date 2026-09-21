/// @desc Return a new word
function sc_generate() {
	// no syllable data loaded yet
	if not syll_ready return ""

	var syll_arr
	var cap_word = ""
	var len_word = irandom(3)+1
	for (var i=0; i<len_word; i++) {
		var syll_type = irandom_range(0,3)
		switch (syll_type) {
		case 0: //common
			syll_arr[i] = sc_generate_syll_common()
			cap_word += syll_common[syll_arr[i], 0]
			show_debug_message(cap_word)
			break;
		case 1: // reverse common
			syll_arr[i] = sc_gen_rev_syll_common()
			cap_word += syll_common_reverse[syll_arr[i], 0]
			show_debug_message(cap_word)
			break;
		case 2: // triple
			syll_arr[i] = sc_generate_syll_triple()
			cap_word += syll_triple[syll_arr[i], 0]
			show_debug_message(cap_word)
			break;
		case 3: // reverse triple
			syll_arr[i] = sc_gen_rev_syll_triple()
			cap_word += syll_triple_reverse[syll_arr[i], 0]
			show_debug_message(cap_word)
			break;
		} 
	}

	return cap_word




}

/// @desc Return every generator result joined by "#" (one line each when drawn)
function sc_generate_all() {
	var _lines = []

	var _word = sc_generate()
	if (_word != "") array_push(_lines, _word)

	var _serial = sc_generate_serial()
	if (_serial != "") array_push(_lines, _serial)

	var _phrase = sc_lexicon_use()
	if (_phrase != "") array_push(_lines, _phrase)

	var _text = ""
	for (var i = 0; i < array_length_1d(_lines); i++) {
		if (_text != "") _text += "\n"
		_text += _lines[i]
	}
	return _text
}
