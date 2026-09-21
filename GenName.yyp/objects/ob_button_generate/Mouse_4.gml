/// @desc Run the assigned script, otherwise show all generators (one per line)
event_inherited()

if (script == noone) {
	// nothing loaded yet: ask the user to pick the database file
	if not (syll_ready or lex_ready) sc_load_database()

	var _text = sc_generate_all()
	if (_text != "") caption = _text
}
