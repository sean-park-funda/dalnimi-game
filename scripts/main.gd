extends Node2D

const IDLE_FRAMES := 65
const IDLE_FPS := 10.0
const MOTION_FPS := 15.0
const FRAME_SIZE := 512

var motion_names := [
	"손 흔들기", "폴짝 점프", "박수치기",
	"빙글 돌기", "하트", "깜짝 놀람",
	"댄스", "졸음", "만세"
]

var btn_colors := [
	Color(1.0, 0.52, 0.67, 1.0),
	Color(1.0, 0.70, 0.30, 1.0),
	Color(1.0, 0.92, 0.25, 1.0),
	Color(0.40, 0.85, 0.50, 1.0),
	Color(0.30, 0.85, 0.78, 1.0),
	Color(0.38, 0.75, 1.0, 1.0),
	Color(0.52, 0.52, 1.0, 1.0),
	Color(0.80, 0.45, 1.0, 1.0),
	Color(1.0, 0.45, 0.82, 1.0),
]

var motion_sprites := {
	"idle": "res://assets/sprites/dalnimi_idle.png",
	1: "res://assets/sprites/motion_1_wave.png",
	2: "res://assets/sprites/motion_2_jump.png",
	3: "res://assets/sprites/motion_3_clap.png",
	4: "res://assets/sprites/motion_4_spin.png",
	5: "res://assets/sprites/motion_5_heart.png",
	6: "res://assets/sprites/motion_6_surprise.png",
	7: "res://assets/sprites/motion_7_dance.png",
	8: "res://assets/sprites/motion_8_sleepy.png",
	9: "",
}

var motion_frame_counts := {
	"idle": 65,
	1: 53,
	2: 29,
	3: 52,
	4: 65,
	5: 52,
	6: 46,
	7: 60,
	8: 55,
}

var current_motion := "idle"
var _dalnimi_pos := Vector2(430.0, 540.0)
var _frame_count := 0

@onready var dalnimi: AnimatedSprite2D = $Dalnimi
@onready var button_grid: GridContainer = $ButtonGrid


func _ready() -> void:
	_setup_sprite()
	_setup_buttons()


# PNG 파일을 읽어 Image 반환 (Godot import 파이프라인 우회)
func _load_raw_image(path: String) -> Image:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("파일 열기 실패: %s" % path)
		return null
	var buf := f.get_buffer(f.get_length())
	f.close()
	var img := Image.new()
	if img.load_png_from_buffer(buf) != OK:
		push_error("PNG 파싱 실패: %s" % path)
		return null
	return img


# 스프라이트시트(Image)를 프레임별 개별 텍스처로 분리해 SpriteFrames 생성
func _apply_sprite_frames_from_image(img: Image, anim_name: String, frame_count: int, loop: bool) -> void:
	var frames := SpriteFrames.new()
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, loop)
	frames.set_animation_speed(anim_name, IDLE_FPS if anim_name == "idle" else MOTION_FPS)
	for i in frame_count:
		var sub := img.get_region(Rect2i(i * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE))
		frames.add_frame(anim_name, ImageTexture.create_from_image(sub))
	dalnimi.sprite_frames = frames


func _setup_sprite() -> void:
	var img := _load_raw_image(motion_sprites["idle"])
	if img == null:
		push_error("idle 스프라이트 로드 실패")
		return
	_apply_sprite_frames_from_image(img, "idle", IDLE_FRAMES, true)
	dalnimi.scale = Vector2(1.6, 1.6)
	dalnimi.offset = Vector2.ZERO
	dalnimi.centered = true
	dalnimi.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	dalnimi.play("idle")
	dalnimi.animation_finished.connect(_on_animation_finished)


func _setup_buttons() -> void:
	button_grid.add_theme_constant_override("h_separation", 15)
	button_grid.add_theme_constant_override("v_separation", 15)
	for i in range(1, 10):
		var btn := Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(0, 0)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 90)
		btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		btn.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
		btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
		btn.add_theme_stylebox_override("normal", _make_btn_style(btn_colors[i - 1], 6))
		btn.add_theme_stylebox_override("hover", _make_btn_style(btn_colors[i - 1].lightened(0.12), 6))
		btn.add_theme_stylebox_override("pressed", _make_btn_style(btn_colors[i - 1].darkened(0.10), 2))
		btn.add_theme_stylebox_override("focus", _make_btn_style(btn_colors[i - 1], 6))
		btn.pressed.connect(_on_motion_pressed.bind(i))
		button_grid.add_child(btn)


func _make_btn_style(color: Color, shadow_s: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left = 30
	s.corner_radius_top_right = 30
	s.corner_radius_bottom_left = 30
	s.corner_radius_bottom_right = 30
	s.shadow_color = Color(0, 0, 0, 0.25)
	s.shadow_size = shadow_s
	s.shadow_offset = Vector2(0, 4)
	return s


func _on_motion_pressed(num: int) -> void:
	var sprite_path: String = motion_sprites.get(num, "")
	if sprite_path == "":
		_flash_button(num)
		return
	var img := _load_raw_image(sprite_path)
	if img == null:
		push_error("모션 %d 스프라이트 로드 실패" % num)
		return
	var frame_count: int = motion_frame_counts.get(num, 30)
	current_motion = str(num)
	_apply_sprite_frames_from_image(img, current_motion, frame_count, false)
	dalnimi.play(current_motion)


func _on_animation_finished() -> void:
	if current_motion != "idle":
		current_motion = "idle"
		var img := _load_raw_image(motion_sprites["idle"])
		if img:
			_apply_sprite_frames_from_image(img, "idle", IDLE_FRAMES, true)
			dalnimi.play("idle")


func _flash_button(num: int) -> void:
	if num < 1 or num > button_grid.get_child_count():
		return
	var btn := button_grid.get_child(num - 1) as Button
	if not btn:
		return
	btn.add_theme_stylebox_override("normal", _make_btn_style(Color(1.0, 1.0, 1.0, 0.95), 3))
	var tween := create_tween()
	tween.tween_interval(0.18)
	tween.tween_callback(func(): btn.add_theme_stylebox_override("normal", _make_btn_style(btn_colors[num - 1], 6)))


func _process(_delta: float) -> void:
	_frame_count += 1
	if _frame_count % 60 == 0:
		print("[POS] pos=%s  offset=%s  scale=%s" % [dalnimi.position, dalnimi.offset, dalnimi.scale])
	if dalnimi.position.distance_to(_dalnimi_pos) > 1.0:
		dalnimi.position = _dalnimi_pos
	if dalnimi.offset.length() > 1.0:
		dalnimi.offset = Vector2.ZERO
	if dalnimi.scale.distance_to(Vector2(1.6, 1.6)) > 0.05:
		dalnimi.scale = Vector2(1.6, 1.6)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var num: int = int(event.keycode) - int(KEY_0)
		if num < 1 or num > 9:
			num = int(event.keycode) - int(KEY_KP_0)
		if num >= 1 and num <= 9:
			_on_motion_pressed(num)
