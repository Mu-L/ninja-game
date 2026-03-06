class_name Util extends Object

static func generate_boilerplate_animation_names(animation_speed: float) -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	var directions := ["down", "left", "right", "up"]
	var states := ["idle", "walk"]
	for state in states:
		for dir in directions:
			var name := "%s %s" % [state, dir]
			sprite_frames.add_animation(name)
			sprite_frames.set_animation_loop(name, true)
			sprite_frames.set_animation_speed(name, animation_speed)
	return sprite_frames
