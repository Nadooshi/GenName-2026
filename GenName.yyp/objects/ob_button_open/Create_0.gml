/// @desc Init
event_inherited()

caption = ""
// keep a script assigned to this instance in the room; otherwise default to noone
if not variable_instance_exists(id, "script") script = noone
