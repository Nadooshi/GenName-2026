/// @desc Run the assigned script, otherwise generate and show the result
event_inherited()

if (script == noone) {
	switch generation_mode {
		case 0:
			caption = sc_generate()
			break;
		case 1:
			caption = sc_lexicon_use()
			break;
	}
}
