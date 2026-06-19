extends Node3D

@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_state_machine = $AnimationTree.get("parameters/AttackStateMachine/playback")
@onready var extra_animation = $AnimationTree.get_tree_root().get_node('ExtraAnimation')

var attacking := false
var squash_and_stretch := 1.0:
	set(value):
		squash_and_stretch = value
		var negative = 1.0 + (1.0 - squash_and_stretch)
		scale = Vector3(negative,squash_and_stretch,negative)

func set_move_state(state_name : String) -> void:
	move_state_machine.travel(state_name)

func attack() -> void:
	if not attacking:
		attack_state_machine.travel('Slice' if $SecondAttackTimer.time_left else 'Chop')
		$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func attack_toggle(value: bool) -> void:
	attacking = value
	

func defend(forward: bool) -> void:
	var tween = create_tween()
	tween.tween_method(_defend_change, 1.0 - float(forward), float(forward), 0.25)
	
func _defend_change(value: float) -> void:
	$AnimationTree.set("parameters/ShieldBlend/blend_amount", value)

func switch_weapon(weapon_active : bool) -> void:
	if weapon_active:
		$init/GeneralSkeleton/RightHandSlot/sword.show()
		$init/GeneralSkeleton/RightHandSlot/Wand.hide()
	else:
		$init/GeneralSkeleton/RightHandSlot/sword.hide()
		$init/GeneralSkeleton/RightHandSlot/Wand.show()
		
func cast_spell() ->void:
	if not attacking:
		extra_animation.animation = 'throw2'
		$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)	
		
func hit() -> void:
	extra_animation.animation = 'hit'
	$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	attacking = false
		
func adjust_speed(value: float) -> void:
	$AnimationTree.set("parameters/TimeScale/scale", value)	

func can_damage(value : bool) -> void :
	$init/GeneralSkeleton/RightHandSlot/sword.can_damage = value

func die():
	print_debug("dying")
	$AnimationTree.set("parameters/DeathOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	set_physics_process(false)
	
	
	
		
