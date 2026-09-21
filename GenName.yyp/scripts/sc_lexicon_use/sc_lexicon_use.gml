/// @desc True if a lexicon section exists and holds at least one word
function sc_lexicon_has(_section) {
	if not variable_struct_exists(lexicon, _section) return false
	return array_length_1d(lexicon[$ _section]) > 0
}

/// @desc Random word from a section, or "" if the section is empty
function sc_lexicon_pick(_section) {
	if not sc_lexicon_has(_section) return ""
	var _arr = lexicon[$ _section]
	return _arr[irandom_range(0, array_length_1d(_arr) - 1)]
}

/// @desc Build a phrase from the loaded lexicon, matching adjective gender to the noun
function sc_lexicon_use() {
	// pick a grammatical gender that actually has nouns
	var _genders = []
	if (sc_lexicon_has("thing_m")) array_push(_genders, "m")
	if (sc_lexicon_has("thing_f")) array_push(_genders, "f")
	if (sc_lexicon_has("thing_n")) array_push(_genders, "n")
	if (array_length_1d(_genders) == 0) return ""

	var _g   = _genders[irandom_range(0, array_length_1d(_genders) - 1)]
	var _sfx = "_" + _g

	var _grade  = sc_lexicon_pick("grade" + _sfx)
	var _thing  = sc_lexicon_pick("thing" + _sfx)
	var _decor  = sc_lexicon_pick("decoration" + _sfx)
	var _attach = sc_lexicon_pick("attachment")

	// adjectives always go before the thing:
	// 0 = thing + attach, 1 = decor + thing + attach,
	// 2 = grade + thing + attach, 3 = grade + decor + thing + attach
	var _variant = irandom_range(0, 3)
	var _parts

	switch (_variant) {
		case 0:  _parts = [_thing, _attach]; break
		case 1:  _parts = [_decor, _thing, _attach]; break
		case 2:  _parts = [_grade, _thing, _attach]; break
		default: _parts = [_grade, _decor, _thing, _attach]; break
	}

	// join the chosen words, skipping any empty section
	var _phrase = ""
	for (var i = 0; i < array_length_1d(_parts); i++) {
		if (_parts[i] == "") continue
		_phrase += (_phrase == "") ? _parts[i] : " " + _parts[i]
	}

	return _phrase
}
