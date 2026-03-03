class_name Util extends Object

static func seconds_to_minutes(time: float) -> String:
	var minutes: int = floor(time / 60.0)
	var seconds: float = fmod(time, 60)
	return "%02d:%02d" % [minutes, seconds]
