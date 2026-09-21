/// @desc Make common syll
function sc_make_syll_common() {

	var arr, n;
	n=0
	for (var i = 0; i<array_length_1d(syll_vowel); i++) 
	for (var k = 0; k<array_length_1d(syll_cons); k++) {
		arr[n,0] = syll_cons[k] + syll_vowel[i]
		arr[n,1] = k+i
		show_debug_message(arr[n,0]+ " - " + string(arr[n,1]))
		n++
	}

	return arr



}
