extends Node

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# 사운드 파일 경로 (에셋 준비 후 채워넣기)
const SOUNDS = {
	"bgm_main":       "res://assets/sounds/bgm_main.ogg",
	"sfx_beep":       "res://assets/sounds/sfx_beep.ogg",
	"sfx_click":      "res://assets/sounds/sfx_click.ogg",
	"sfx_success":    "res://assets/sounds/sfx_success.ogg",
	"sfx_bandage":    "res://assets/sounds/sfx_bandage.ogg",
	"sfx_heartbeat":  "res://assets/sounds/sfx_heartbeat.ogg",
	"sfx_swallow":    "res://assets/sounds/sfx_swallow.ogg",
	"sfx_brush":      "res://assets/sounds/sfx_brush.ogg",
	"sfx_drop":       "res://assets/sounds/sfx_drop.ogg",
}

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "BGM"
	add_child(bgm_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

func play_bgm(key: String):
	if not SOUNDS.has(key): return
	if not ResourceLoader.exists(SOUNDS[key]): return
	var stream = load(SOUNDS[key])
	if stream:
		bgm_player.stream = stream
		bgm_player.play()

func play_sfx(key: String):
	if not SOUNDS.has(key): return
	if not ResourceLoader.exists(SOUNDS[key]): return
	var stream = load(SOUNDS[key])
	if stream:
		sfx_player.stream = stream
		sfx_player.play()

func stop_bgm():
	bgm_player.stop()
