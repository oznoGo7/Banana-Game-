extends CharacterBody2D

@export var speed = 300
@export var jump_speed = -600
@export var gravity = 2000
@export var health = 100


@onready var banana_sprite: AnimatedSprite2D = $"Banana Sprite"
@onready var anim: AnimationPlayer = $Anim
@onready var cam: Camera2D = $Camera2D
@onready var coyote_timer: Timer = $"Coyote Timer"
@onready var sword: Area2D = $Sword
@onready var attack_anim: AnimationPlayer = $"Sword/Attack Anim"





var can_jump = true
var can_attack = true
var already_jumped = false
var facing_right = false
var is_attacking = false

func _ready() -> void:
	cam.enabled = is_multiplayer_authority()

func _physics_process(delta):
	if !cam.is_multiplayer_authority():
		return
	# Add gravity every frame
	velocity.y += gravity * delta

	# Input affects x axis only
	velocity.x = Input.get_axis("left", "right") * speed

	#For Animations
	if velocity.x > 0:
		anim.play("Walk")
		banana_sprite.flip_h = true
		#Sword
		$Sword/CollisionShape2D.position = Vector2(13, -14)
		$"Sword/Sword Sprite".position = Vector2(9, -10)
		$Sword/CollisionShape2D.rotation = 45
		$"Sword/Sword Sprite".flip_h = true
		#Banana
		$Hitbox/CollisionShape2D.position = Vector2(-10, 0)
		$CollisionShape2D.position = Vector2(-10, 0)
		facing_right = true
	elif velocity.x < 0:
		anim.play("Walk")
		banana_sprite.flip_h = false
		#Sword
		$Sword/CollisionShape2D.position = Vector2(-13, -14)
		$"Sword/Sword Sprite".position = Vector2(-9, -10)
		$Sword/CollisionShape2D.rotation = -45
		$"Sword/Sword Sprite".flip_h = false
		#Banana
		$Hitbox/CollisionShape2D.position = Vector2(10, 0)
		$CollisionShape2D.position = Vector2(10, 0)
		facing_right = false
	else:
		pass

	if can_jump == false and is_on_floor():
		can_jump = true

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and can_jump:
		jump()
		
	if (is_on_floor() == false) and can_jump and coyote_timer.is_stopped():
		coyote_timer.start()
	
	#Attacking
	if Input.is_action_just_pressed("Attack") and can_attack == true:
		$Sword/CollisionShape2D.disabled = false
		can_attack = false
		is_attacking = true
		if facing_right == false:
			attack_anim.play("Sword Attack Right")
		else:
			attack_anim.play("Sword Attack Left")
		await attack_anim.animation_finished
		is_attacking = false
		$"Sword/Attack Timer".start()
	#Blocking
	if Input.is_action_just_pressed("Blocking") and is_attacking == false:
		if facing_right == false:
			attack_anim.play("Blocking Left")
		else:
			attack_anim.play("Blocking Right")
		await attack_anim.animation_finished
		attack_anim.play("Sword Reset")
	move_and_slide()

func _on_coyote_timer_timeout() -> void:
	can_jump = false

func jump():
	velocity.y = jump_speed
	can_jump = false


func _on_attack_timer_timeout() -> void:
	can_attack = true
	$Sword/CollisionShape2D.disabled = true


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Sword" and !is_multiplayer_authority():
		health -= 25
		if health <= 0:
			player_died()

func player_died():
	hide()
