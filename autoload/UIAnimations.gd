extends Node

# ── 등장 애니메이션 ───────────────────────────────────────

# scale 0 → 1 팝인 (버튼·카드 등장)
func pop_in(node: Node, delay: float = 0.0) -> void:
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "scale", Vector2.ONE, 0.38)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "modulate:a", 1.0, 0.2)

# 여러 노드를 delay 간격으로 순서대로 pop-in
func stagger_pop_in(nodes: Array, base_delay: float = 0.0, interval: float = 0.12) -> void:
	for i in nodes.size():
		pop_in(nodes[i], base_delay + i * interval)

# 아래에서 위로 슬라이드 + 페이드인
func fly_in_from_bottom(node: Node, offset_y: float = 80.0, delay: float = 0.0) -> void:
	var origin = node.position
	node.position.y += offset_y
	node.modulate.a = 0.0
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "position", origin, 0.38)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "modulate:a", 1.0, 0.25)

# 위에서 아래로 슬라이드 + 페이드인
func fly_in_from_top(node: Node, offset_y: float = 60.0, delay: float = 0.0) -> void:
	var origin = node.position
	node.position.y -= offset_y
	node.modulate.a = 0.0
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "position", origin, 0.35)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "modulate:a", 1.0, 0.25)

# 왼쪽에서 슬라이드인
func fly_in_from_left(node: Node, offset_x: float = 120.0, delay: float = 0.0) -> void:
	var origin = node.position
	node.position.x -= offset_x
	node.modulate.a = 0.0
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "position", origin, 0.38)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "modulate:a", 1.0, 0.25)

# 오른쪽에서 슬라이드인
func fly_in_from_right(node: Node, offset_x: float = 120.0, delay: float = 0.0) -> void:
	var origin = node.position
	node.position.x += offset_x
	node.modulate.a = 0.0
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "position", origin, 0.38)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "modulate:a", 1.0, 0.25)

# ── 반복 애니메이션 ───────────────────────────────────────

# 상하 부유 (Idle float bob) — set_loops()로 무한반복
func float_bob(node: Node, amplitude: float = 8.0, period: float = 2.0) -> Tween:
	var origin_y = node.position.y
	var tw = node.create_tween().set_loops()
	tw.tween_property(node, "position:y", origin_y - amplitude, period * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(node, "position:y", origin_y + amplitude, period * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tw

# 미세한 심장박동 스케일 펄스 (캐릭터 idle)
func idle_pulse(node: Node, scale_factor: float = 1.05, period: float = 1.2) -> Tween:
	var tw = node.create_tween().set_loops()
	tw.tween_property(node, "scale", Vector2.ONE * scale_factor, period * 0.45)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(node, "scale", Vector2.ONE, period * 0.55)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tw

# ── 버튼 인터랙션 ──────────────────────────────────────────

# 버튼 눌림
func button_press(node: Node) -> void:
	var tw = node.create_tween()
	tw.tween_property(node, "scale", Vector2(0.88, 0.88), 0.08)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var tw2 = node.create_tween()
	tw2.tween_property(node, "modulate", Color(1.6, 1.6, 0.6, 1), 0.06)
	tw2.tween_property(node, "modulate", Color(1, 1, 1, 1), 0.12)

# 버튼 복귀
func button_release(node: Node) -> void:
	var tw = node.create_tween()
	tw.tween_property(node, "scale", Vector2.ONE, 0.35)\
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

# 씬의 모든 Button 노드에 press/release 자동 연결
func connect_buttons(root: Node) -> void:
	for btn in _get_all_buttons(root):
		if not btn.button_down.is_connected(button_press.bind(btn)):
			btn.button_down.connect(button_press.bind(btn))
		if not btn.button_up.is_connected(button_release.bind(btn)):
			btn.button_up.connect(button_release.bind(btn))

func _get_all_buttons(node: Node) -> Array:
	var result = []
	if node is Button:
		result.append(node)
	for child in node.get_children():
		result.append_array(_get_all_buttons(child))
	return result

# ── 특수 효과 ──────────────────────────────────────────────

# 좌우 흔들기 — 잘못된 입력 피드백
func wobble(node: Node, intensity: float = 18.0) -> void:
	var origin_x = node.position.x
	var tw = node.create_tween()
	tw.tween_property(node, "position:x", origin_x + intensity, 0.05)
	tw.tween_property(node, "position:x", origin_x - intensity, 0.05)
	tw.tween_property(node, "position:x", origin_x + intensity * 0.5, 0.05)
	tw.tween_property(node, "position:x", origin_x - intensity * 0.5, 0.04)
	tw.tween_property(node, "position:x", origin_x, 0.04)

# 빨간 틴트 + 흔들기 — 실패/경고
func fail_shake(node: Node) -> void:
	wobble(node)
	var tw = node.create_tween()
	tw.tween_property(node, "modulate", Color(1.8, 0.4, 0.4, 1), 0.07)
	tw.tween_property(node, "modulate", Color(1, 1, 1, 1), 0.2)

# 결과 숫자/텍스트 강조 등장 (38.5°C 같은 결과 표시)
func result_pop_in(node: Node, delay: float = 0.0) -> void:
	node.scale = Vector2(2.2, 2.2)
	node.modulate.a = 0.0
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "scale", Vector2.ONE, 0.45)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "modulate:a", 1.0, 0.15)

# 성공 squash & stretch 팝
func celebration_pop(node: Node, delay: float = 0.0) -> void:
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "scale", Vector2(1.4, 0.7), 0.12)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2(0.85, 1.25), 0.1)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2.ONE, 0.35)\
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

# 낙하 후 바운스 착지
func bounce_land(node: Node, from_y: float, to_y: float, delay: float = 0.0) -> void:
	node.position.y = from_y
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "position:y", to_y, 0.5)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

# 텍스트 위에서 bounce 착지
func title_drop(node: Node, drop_distance: float = 80.0, delay: float = 0.0) -> void:
	var origin = node.position
	node.position.y -= drop_distance
	node.modulate.a = 0.0
	var tw = node.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(node, "position", origin, 0.5)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(node, "modulate:a", 1.0, 0.2)

# 성공 시 초록 반짝임
func success_flash(node: Node) -> void:
	var tw = node.create_tween()
	tw.tween_property(node, "modulate", Color(0.6, 1.8, 0.6, 1), 0.08)
	tw.tween_property(node, "modulate", Color(1, 1, 1, 1), 0.25)
