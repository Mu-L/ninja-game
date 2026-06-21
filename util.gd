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
	
	# Death animation:
	sprite_frames.add_animation("dead")
	var atlas := AtlasTexture.new()
	atlas.filter_clip = true
	atlas.atlas = texture
	atlas.region = Rect2(0, 6*16, 16, 16)
	sprite_frames.add_frame("dead", atlas)
	
	
	return sprite_frames

static func seconds_to_minutes(time: float) -> String:
	var minutes: int = floor(time / 60.0)
	var seconds: float = fmod(time, 60)
	return "%02d:%02d" % [minutes, seconds]

@warning_ignore("shadowed_global_identifier")
static func BBCode_pulse(text: String, freq := 1.0, ease := -2.0, color := Color.WHITE) -> String:
	var args := [freq, color.to_html(), ease, text]
	return "[pulse freq=%f color=%s ease=%f]%s[/pulse]" % args

static func BBCode_wave(text: String, amp := 50.0, freq := 5.0, connected := 1) -> String:
	var args := [amp, freq, connected, text]
	return "[wave amp=%f freq=%f connected=%d]%s[/wave]" % args

static func BBCode_tornado(text: String, radius := 10.0, freq := 1.0, connected := 1) -> String:
	var args := [radius, freq, connected, text]
	return "[tornado radius=%f freq=%f connected=%d]%s[/tornado]" % args

static func BBCode_shake(text: String, rate := 20.0, level := 5, connected := 1) -> String:
	var args := [rate, level, connected, text]
	return "[shake rate=%f level=%d connected=%d]%s[/shake]" % args

static func BBCode_rainbow(text: String, freq:=1.0, sat:=0.8, val:=0.8, speed=1.0) -> String:
	var args := [freq, sat, val, speed, text]
	return "[rainbow freq=%f sat=%f val=%f speed=%f]%s[/rainbow]" % args

static func BBcode_color(text: String, color: Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(), text]
