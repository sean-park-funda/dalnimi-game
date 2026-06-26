# 달님이 키즈앱

달님이 IP 기반 3세 타겟 키즈 인터랙티브 앱.

## 개발 워크플로우

1. Mac Mini에서 Claude가 코드 작성 → `git push`
2. Windows 랩탑에서 `git pull` → Godot 에디터에서 테스트

```bash
# 랩탑에서 처음 클론
git clone https://github.com/sean-park-funda/dalnimi-game.git
cd dalnimi-game
# Godot 에디터로 project.godot 열기
```

## 프로젝트 구조

```
dalnimi-game/
├── autoload/          # 싱글톤 (GameManager, SoundManager, SceneTransition, UIAnimations)
├── assets/
│   ├── sprites/       # 달님이 캐릭터 이미지
│   ├── sounds/        # BGM, 효과음
│   └── fonts/         # 폰트
├── scenes/            # .tscn 씬 파일
├── scripts/           # .gd 스크립트
├── shaders/           # 씬 전환 셰이더
└── docs/              # 기획 문서
```

## 타겟 & 방향

- 연령: 3세 / 조작: 터치 전용
- 언어 없음 → 글로벌 출시 가능
- BM: 무료 체험 + IAP 확장 (5~6천원)
- 카테고리: 교육 앱 포지셔닝

## 참고

- 회의록: `docs/meetings/` 폴더 참조
- 코딩 규칙: 달님이 의사 게임 `godot-coding-rules.md` 동일 적용
