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
	// no lexicon data loaded yet
	if not lex_ready return ""

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

/// @desc Generate a full character name (first + patronymic + surname), gender-matched.
///      Sometimes returns a foreign name instead (given name + male name, no surname).
function sc_generate_name() {
	// with some probability, use a foreign-style name
	if (irandom(99) < 25) {
		var _f = sc_generate_foreign_name()
		if (_f != "") return _f
	}

	// pick a gender that has all three parts
	var _genders = []
	if (sc_lexicon_has("name_m") and sc_lexicon_has("patronymic_m") and sc_lexicon_has("surname_m")) array_push(_genders, "m")
	if (sc_lexicon_has("name_f") and sc_lexicon_has("patronymic_f") and sc_lexicon_has("surname_f")) array_push(_genders, "f")
	if (array_length_1d(_genders) == 0) return ""

	var _sfx = "_" + _genders[irandom_range(0, array_length_1d(_genders) - 1)]

	var _first   = sc_lexicon_pick("name" + _sfx)
	var _patro   = sc_lexicon_pick("patronymic" + _sfx)
	var _surname = sc_lexicon_pick("surname" + _sfx)
	var _parts   = [_first, _patro, _surname]

	// join the chosen words, skipping any empty section
	var _name = ""
	for (var i = 0; i < array_length_1d(_parts); i++) {
		if (_parts[i] == "") continue
		_name += (_name == "") ? _parts[i] : " " + _parts[i]
	}

	return _name
}

/// @desc Foreign-style name: given name + male name, no surname, optional belonging particle
function sc_generate_foreign_name() {
	// given name: male or female
	var _genders = []
	if (sc_lexicon_has("name_m")) array_push(_genders, "m")
	if (sc_lexicon_has("name_f")) array_push(_genders, "f")
	if (array_length_1d(_genders) == 0) return ""

	var _sfx = "_" + _genders[irandom_range(0, array_length_1d(_genders) - 1)]
	var _first = sc_lexicon_pick("name" + _sfx)

	// a male name instead of the patronymic
	var _second = sc_lexicon_pick("name_m")

	// optional belonging particle before the second name
	var _particle = ""
	if (sc_lexicon_has("particle")) and (irandom(99) < 40)
		_particle = sc_lexicon_pick("particle")

	var _parts = [_first, _particle, _second]
	var _name = ""
	for (var i = 0; i < array_length_1d(_parts); i++) {
		if (_parts[i] == "") continue
		_name += (_name == "") ? _parts[i] : " " + _parts[i]
	}

	return _name
}
