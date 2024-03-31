@tool
class_name InputTexture
extends TextureRect

@export_flags("Left", "Right", "Up", "Down", "A", "B") var inputs: int:
	set(value):
		inputs = value
		var atlas_texture = texture as AtlasTexture
		if not atlas_texture:
			return
		if inputs == (Statics.Inputs.LEFT | Statics.Inputs.RIGHT | Statics.Inputs.UP | Statics.Inputs.DOWN):
			atlas_texture.region = Rect2(96, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.LEFT | Statics.Inputs.RIGHT | Statics.Inputs.UP):
			atlas_texture.region = Rect2(64, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.LEFT | Statics.Inputs.RIGHT | Statics.Inputs.DOWN):
			atlas_texture.region = Rect2(64, 0, 16, 16)
			flip_h = false
			flip_v = true
		elif inputs == (Statics.Inputs.RIGHT | Statics.Inputs.UP | Statics.Inputs.DOWN):
			atlas_texture.region = Rect2(80, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.LEFT | Statics.Inputs.UP | Statics.Inputs.DOWN):
			atlas_texture.region = Rect2(80, 0, 16, 16)
			flip_h = true
			flip_v = false
		elif inputs == (Statics.Inputs.LEFT | Statics.Inputs.RIGHT):
			atlas_texture.region = Rect2(32, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.UP | Statics.Inputs.DOWN):
			atlas_texture.region = Rect2(48, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.LEFT):
			atlas_texture.region = Rect2(0, 0, 16, 16)
			flip_h = true
			flip_v = false
		elif inputs == (Statics.Inputs.RIGHT):
			atlas_texture.region = Rect2(0, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.UP):
			atlas_texture.region = Rect2(16, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.DOWN):
			atlas_texture.region = Rect2(16, 0, 16, 16)
			flip_h = false
			flip_v = true
		elif inputs == (Statics.Inputs.A | Statics.Inputs.B):
			atlas_texture.region = Rect2(144, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.A):
			atlas_texture.region = Rect2(112, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Statics.Inputs.B):
			atlas_texture.region = Rect2(128, 0, 16, 16)
			flip_h = false
			flip_v = false
		else:
			atlas_texture.region = Rect2(160, 0, 16, 16)
			flip_h = false
			flip_v = false
