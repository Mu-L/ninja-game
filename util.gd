class_name Util extends Object

static func generate_sprite_frames(texture: Texture, is_ally: bool=false ,animation_speed: float=5.0, is_flying:bool=false) -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	var directions := ["down", "up", "left", "right"]
	
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
	
	
		# Idle animations:
	if is_flying:
		for dir in directions:
			sprite_frames.duplicate_animation("walk %s" % dir, "idle %s" % dir)
	else:
		for i in range(len(directions)):
			var name := "idle %s" % directions[i]
			sprite_frames.add_animation(name)
			sprite_frames.set_animation_loop(name, true)
			sprite_frames.set_animation_speed(name, animation_speed)
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(16*i, 0, 16, 16)
			sprite_frames.add_frame(name, atlas)
	
	
	if not is_ally:
		sprite_frames.duplicate_animation("walk left", "attack")
		sprite_frames.set_animation_loop("attack", false)
		sprite_frames.set_animation_speed("attack", animation_speed*2.0)
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
