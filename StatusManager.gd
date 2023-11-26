extends Node

func apply(status: Status, to: Entity):
	match status.id:
		"POISON":
			_trigger_on_interval(1, status, to)
		"SHIELD":
			_trigger_before_damage(status, to)

func trigger(status: Status, to: Entity, params: Dictionary = {}):
	match status.id:
		"POISON":
			var new_hp: int = to.take_damage(1)
			if to.has_stacks(status) and new_hp > 0:
				var t := get_tree().create_timer(1)
				t.timeout.connect(func(): trigger(status, to))
		"SHIELD":
			if not to.has_stacks(status):
				return
			var damage := params["damage"] as int
			print("%s blocked %d damage" % [to._name, 1])
			to.damage_mitigation = 1.0/damage
			to.remove_stacks(status, 1)

'''
DIFFERENT TRIGGER TYPES
'''
func _trigger_on_interval(interval: float, status: Status, to: Entity):
	var t := get_tree().create_timer(interval)
	t.timeout.connect(func(): trigger(status, to))

func _trigger_before_damage(status: Status, to: Entity):
	to.before_damage_taken.connect(func(dmg): trigger(status, to, {"damage": dmg}))
