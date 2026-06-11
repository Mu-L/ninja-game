class_name Util extends Object

static func generate_sprite_frames(texture: Texture, is_ally: bool=false ,animation_speed: float=5.0) -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	var directions := ["down", "up", "left", "right"]
	
	# Idle animations:
	for i in range(len(directions)):
		var name := "idle %s" % directions[i]
		sprite_frames.add_animation(name)
		sprite_frames.set_animation_loop(name, true)
		sprite_frames.set_animation_speed(name, animation_speed)
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(16*i, 0, 16, 16)
		sprite_frames.add_frame(name, atlas)
	
	# Walk animations:
	for i in range(len(directions)):
		var name := "walk %s" % directions[i]
		sprite_frames.add_animation(name)
		sprite_frames.set_animation_loop(name, true)
		sprite_frames.set_animation_speed(name, animation_speed)
		
		for j in range(4):
			var atlas := AtlasTexture.new()
			atlas.filter_clip = true
			atlas.atlas = texture
			atlas.region = Rect2(i*16, j*16, 16, 16)
			sprite_frames.add_frame(name, atlas)
	
	if not is_ally:
		return sprite_frames
	
	# Attack animations:
	for i in range(len(directions)):
		var name := "attack %s" % directions[i]
		sprite_frames.add_animation(name)
		sprite_frames.set_animation_loop(name, true)
		sprite_frames.set_animation_speed(name, animation_speed)
		var atlas := AtlasTexture.new()
		atlas.filter_clip = true
		atlas.atlas = texture
		atlas.region = Rect2(i*16, 64, 16, 16)
		sprite_frames.add_frame(name, atlas)
	
	return sprite_frames
