extends CanvasLayer

var overlay: ColorRect
var shader_mat: ShaderMaterial
var tween: Tween

# 원이 모서리까지 덮으려면 약 1.1 (비율 보정 포함)
const CIRCLE_MAX = 1.1

func _ready():
	layer = 10
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	# 셰이더 머티리얼 미리 준비
	var shader = load("res://shaders/circle_wipe.gdshader")
	shader_mat = ShaderMaterial.new()
	shader_mat.shader = shader
	shader_mat.set_shader_parameter("progress", 0.0)

# 기본 전환 — 원형 와이프
func change_scene(path: String) -> void:
	_circle_wipe_out(path)

# 치료 성공 전환 — 노란 플래시 후 원형 와이프
func change_scene_success(path: String) -> void:
	overlay.material = null
	overlay.color = Color(1.0, 0.92, 0.1, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.15)
	tween.tween_callback(func():
		overlay.color = Color(0, 0, 0, 0)
		get_tree().change_scene_to_file(path)
		_circle_wipe_in()
	)

# ── 원형 와이프 구현 ─────────────────────────────────────

func _circle_wipe_out(path: String) -> void:
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.color = Color.WHITE  # 셰이더가 색상 제어
	overlay.material = shader_mat
	shader_mat.set_shader_parameter("progress", 0.0)

	if tween: tween.kill()
	tween = create_tween()
	tween.tween_method(
		func(v: float): shader_mat.set_shader_parameter("progress", v),
		0.0, CIRCLE_MAX, 0.6
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(path)
		_circle_wipe_in()
	)

func _circle_wipe_in() -> void:
	overlay.material = shader_mat
	shader_mat.set_shader_parameter("progress", CIRCLE_MAX)
	# wipe-in은 이미 씬이 바뀐 후 — 입력 차단 즉시 해제
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	tween = create_tween()
	tween.tween_method(
		func(v: float): shader_mat.set_shader_parameter("progress", v),
		CIRCLE_MAX, 0.0, 0.6
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		overlay.material = null
		overlay.color = Color(0, 0, 0, 0)
	)
