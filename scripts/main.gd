extends Node2D

const IDLE_FRAMES := 65
const IDLE_FPS := 5.0
const MOTION_FPS := 15.0
const FRAME_SIZE := 512

# 모션 이름 (1~9번 순서)
var motion_names := [
	"손 흔들기", "폴짝 점프", "박수치기",
	"빙글 돌기", "하트", "깜짝 놀람",
	"댄스", "졸음", "만세"
]

# 버튼 색상 (파스텔 계열, 아이들 취향)
var btn_colors := [
	Color(1.0, 0.52, 0.67, 1.0),  # 1 핑크
	Color(1.0, 0.70, 0.30, 1.0),  # 2 오렌지
	Color(1.0, 0.92, 0.25, 1.0),  # 3 노랑
	Color(0.40, 0.85, 0.50, 1.0), # 4 초록
	Color(0.30, 0.85, 0.78, 1.0), # 5 민트
	Color(0.38, 0.75, 1.0, 1.0),  # 6 하늘
	Color(0.52, 0.52, 1.0, 1.0),  # 7 파랑
	Color(0.80, 0.45, 1.0, 1.0),  # 8 보라
	Color(1.0, 0.45, 0.82, 1.0),  # 9 마젠타
]

# 모션별 스프라이트 파일명 (추후 순차 추가)
var motion_sprites := {
	"idle": "res://assets/sprites/dalnimi_idle.png",
	1: "res://assets/sprites/motion_1_wave.png",
	2: "res://assets/sprites/motion_2_jump.png",
	3: "",  # 박수치기 — 추가 예정
	4: "",  # 빙글 돌기 — 추가 예정
	5: "",  # 하트 — 추가 예정
	6: "",  # 깜짝 놀람 — 추가 예정
	7: "",  # 댄스 — 추가 예정
	8: "",  # 졸음 — 추가 예정
	9: "",  # 만세 — 추가 예정
}

# 모션별 프레임 수
var motion_frame_counts := {
	"idle": 49,
	1: 53,  # 손 흔들기
	2: 29,  # 폴짝 점프
}

var current_motion := "idle"
var _dalnimi_pos := Vector2(430.0, 540.0)
var _frame_count := 0

@onready var dalnimi: AnimatedSprite2D = $Dalnimi
@onready var button_grid: GridContainer = $ButtonGrid


func _ready() -> void:
	_setup_title()
	_setup_sprite()
	_setup_buttons()


func _setup_title() -> void:
	var label := $TitleLabel as Label
	label.add_theme_font_size_override("font_size", 72)
	label.add_theme_color_override("font_color", Color(0.88, 0.3, 0.52, 1.0))


func _load_raw_texture(path: String) -> ImageTexture:
	print("[TEX] 로드 시작: ", path)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("[TEX] 파일 열기 실패: %s (err=%d)" % [path, FileAccess.get_open_error()])
		return null
	var buf := f.get_buffer(f.get_length())
	f.close()
	print("[TEX] 파일 읽기 완료, 크기=%d bytes" % buf.size())
	var img := Image.new()
	var err := img.load_png_from_buffer(buf)
	if err != OK:
		push_error("[TEX] PNG 파싱 실패: err=%d" % err)
		return null
	print("[TEX] 이미지 크기: %dx%d" % [img.get_width(), img.get_height()])
	var tex := ImageTexture.create_from_image(img)
	print("[TEX] 텍스처 생성 완료: %s" % ("OK" if tex else "null"))
	return tex

func _setup_sprite() -> void:
	var texture := _load_raw_texture(motion_sprites["idle"])
	if not texture:
		push_error("dalnimi_idle.png를 찾을 수 없습니다.")
		return
	_apply_sprite_frames(texture, "idle", IDLE_FRAMES, true)
	dalnimi.scale = Vector2(1.6, 1.6)
	dalnimi.offset = Vector2.ZERO
	dalnimi.centered = true
	dalnimi.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	dalnimi.play("idle")
	dalnimi.animation_finished.connect(_on_animation_finished)


func _apply_sprite_frames(texture: Texture2D, anim_name: String, frame_count: int, loop: bool) -> void:
	var frames := SpriteFrames.new()
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, loop)
	frames.set_animation_speed(anim_name, IDLE_FPS if anim_name == "idle" else MOTION_FPS)
	for i in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
		atlas.filter_clip = true
		frames.add_frame(anim_name, atlas)
	dalnimi.sprite_frames = frames


func _setup_buttons() -> void:
	button_grid.add_theme_constant_override("h_separation", 15)
	button_grid.add_theme_constant_override("v_separation", 15)
	for i in range(1, 10):
		var btn := Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(0, 270)
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
		# 아직 스프라이트 없음 — 버튼만 반짝이기
		_flash_button(num)
		return
	var texture := _load_raw_texture(sprite_path)
	if not texture:
		push_error("모션 %d 스프라이트를 찾을 수 없습니다." % num)
		return
	var frame_count: int = motion_frame_counts.get(num, 30)
	current_motion = str(num)
	_apply_sprite_frames(texture, current_motion, frame_count, false)
	dalnimi.play(current_motion)


func _on_animation_finished() -> void:
	# 모션 완료 후 idle 복귀
	if current_motion != "idle":
		current_motion = "idle"
		_apply_sprite_frames(_load_raw_texture(motion_sprites["idle"]), "idle", IDLE_FRAMES, true)
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
		print("[DRIFT-POS] %s → 복귀" % dalnimi.position)
		dalnimi.position = _dalnimi_pos
	if dalnimi.offset.length() > 1.0:
		print("[DRIFT-OFFSET] %s → 리셋" % dalnimi.offset)
		dalnimi.offset = Vector2.ZERO
	if dalnimi.scale.distance_to(Vector2(1.6, 1.6)) > 0.05:
		print("[DRIFT-SCALE] %s → 리셋" % dalnimi.scale)
		dalnimi.scale = Vector2(1.6, 1.6)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var num: int = int(event.keycode) - int(KEY_0)
		if num < 1 or num > 9:
			num = int(event.keycode) - int(KEY_KP_0)  # 넘패드 지원
		if num >= 1 and num <= 9:
			_on_motion_pressed(num)
