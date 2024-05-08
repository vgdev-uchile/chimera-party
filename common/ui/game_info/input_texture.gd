@tool
class_name InputTexture
extends TextureRect


enum Inputs {
	LEFT  = 1 << 0,
	RIGHT = 1 << 1,
	UP    = 1 << 2,
	DOWN  = 1 << 3,
	A     = 1 << 4,
	B     = 1 << 5,
}

@export_flags("Left", "Right", "Up", "Down", "A", "B") var inputs: int:
	set(value):
		inputs = value
		var atlas_texture = texture as AtlasTexture
		if not atlas_texture:
			return
		if inputs == (Inputs.LEFT | Inputs.RIGHT | Inputs.UP | Inputs.DOWN):
			atlas_texture.region = Rect2(96, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.LEFT | Inputs.RIGHT | Inputs.UP):
			atlas_texture.region = Rect2(64, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.LEFT | Inputs.RIGHT | Inputs.DOWN):
			atlas_texture.region = Rect2(64, 0, 16, 16)
			flip_h = false
			flip_v = true
		elif inputs == (Inputs.RIGHT | Inputs.UP | Inputs.DOWN):
			atlas_texture.region = Rect2(80, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.LEFT | Inputs.UP | Inputs.DOWN):
			atlas_texture.region = Rect2(80, 0, 16, 16)
			flip_h = true
			flip_v = false
		elif inputs == (Inputs.LEFT | Inputs.RIGHT):
			atlas_texture.region = Rect2(32, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.UP | Inputs.DOWN):
			atlas_texture.region = Rect2(48, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.LEFT):
			atlas_texture.region = Rect2(0, 0, 16, 16)
			flip_h = true
			flip_v = false
		elif inputs == (Inputs.RIGHT):
			atlas_texture.region = Rect2(0, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.UP):
			atlas_texture.region = Rect2(16, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.DOWN):
			atlas_texture.region = Rect2(16, 0, 16, 16)
			flip_h = false
			flip_v = true
		elif inputs == (Inputs.A | Inputs.B):
			atlas_texture.region = Rect2(144, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.A):
			atlas_texture.region = Rect2(112, 0, 16, 16)
			flip_h = false
			flip_v = false
		elif inputs == (Inputs.B):
			atlas_texture.region = Rect2(128, 0, 16, 16)
			flip_h = false
			flip_v = false
		else:
			atlas_texture.region = Rect2(160, 0, 16, 16)
			flip_h = false
			flip_v = false
