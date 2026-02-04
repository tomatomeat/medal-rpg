extends CharacterBody2D

const SPEED := 80

# up = 背中(back) / down = 正面(front)
var facing := "down"   # "up" | "down" | "side"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	# ---- 入力 ----
	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	# ---- 移動前の位置を保存 ----
	var prev_pos := global_position

	# ---- 移動・アニメ ----
	if dir == Vector2.ZERO:
		play_idle()
		velocity = Vector2.ZERO
	else:
		play_walk(dir)
		velocity = dir.normalized() * SPEED

	move_and_slide()

	# ---- エンカウント用：移動距離通知 ----
	var moved_dist := global_position.distance_to(prev_pos)
	if moved_dist > 0:
		EncounterManager.on_player_moved(moved_dist, delta)


# ===============================
# アニメ制御
# ===============================

func play_walk(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		# 横移動（左右反転で対応）
		facing = "side"
		anim.flip_h = dir.x < 0   # 左なら反転
		anim.play("walk_side")
	else:
		anim.flip_h = false
		if dir.y > 0:
			facing = "down"
			anim.play("walk_down")
		else:
			facing = "up"
			anim.play("walk_up")


func play_idle():
	# side のときは flip_h を維持
	if facing != "side":
		anim.flip_h = false

	var idle_anim := "idle_" + facing
	if anim.animation != idle_anim:
		anim.play(idle_anim)

	anim.stop()  # ← 止まったらピタッと止める
