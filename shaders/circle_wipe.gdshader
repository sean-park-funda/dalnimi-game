shader_type canvas_item;

// progress 0 = 완전 투명, 1.1 이상 = 전체 화면 덮음
uniform float progress : hint_range(0.0, 1.5) = 0.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	// 세로 모바일(1080x1920) 비율 보정 — 타원이 아닌 정원으로
	uv.x *= (1920.0 / 1080.0);
	float dist = length(uv);
	// 중심에서 바깥으로 퍼지는 검정 원
	float alpha = smoothstep(dist, dist + 0.06, progress);
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
