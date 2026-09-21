/// @desc Get maximal value
/// @arg Array
function sc_syll_getmax(argument0) {

	var arr = argument0

	var mx = 0;

	for (var i=0; i<array_height_2d(arr); i++) {
		if (mx == 0) or (arr[i,1]>mx)
			mx = arr[i,1]
	}

	return mx;



}
