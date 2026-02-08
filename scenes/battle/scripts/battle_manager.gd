class_name BattleManager
extends RefCounted

signal action_resolved(result: ActionResult)
signal turn_ended(turn_number: int)
signal battle_ended(winner:Dictionary)

var context: BattleContext
var state: BattleState

var hooks: Array[BattleHook] = []
var order: Array[ActionContext] = []

var p1_active_medal_id: String = ""
var p2_active_medal_id: String = ""

var p1_ready := false
var p2_ready := false

# ========================
# Initialize
# ========================

func bind(_context: BattleContext) -> void:
	context = _context
	initialize()

func initialize() -> void:
	state = BattleState.new()
	state.current_turn = 0
	state.p1_party = context.p1_party
	state.p2_party = context.p2_party

	p1_active_medal_id = state.p1_party[0].source.instance_id
	p2_active_medal_id = state.p2_party[0].source.instance_id

	state.medal_map.clear()
	for m:MedalState in state.p1_party+state.p2_party:
		state.medal_map[m.source.instance_id] = m

	_register_ability_hooks()

# ========================
# Action Request
# ========================

func request_action(action: BattleAction) -> bool:
	if not state.medal_map.has(action.user_id):
		return false

	if action.user_id == p1_active_medal_id:
		if p1_ready: return false
	elif action.user_id == p2_active_medal_id:
		if p2_ready: return false
	else:
		return false

	var ctx := _build_action_context(action)
	if ctx == null:
		return false

	order.append(ctx)

	if action.user_id == p1_active_medal_id:
		p1_ready = true
	else:
		p2_ready = true

	if p1_ready and p2_ready:
		_execute_turn()

	return true

# ========================
# Context Build
# ========================

func _build_action_context(action: BattleAction) -> ActionContext:
	var ctx := ActionContext.new()
	ctx.action = action

	var user: MedalState = state.medal_map.get(action.user_id)
	if user == null:
		return null

	ctx.user = user
	ctx.speed = user.current_stat[StatType.Type.SPD]

	match action.type:
		BattleAction.ActionType.SKILL:
			var skill := _resolve_skill(action)
			if skill == null:
				return null
			ctx.skill = skill
			ctx.priority = skill.priority

		BattleAction.ActionType.ROTATION:
			ctx.priority = 6

	trigger_event(EventTrigger.Type.ON_CALC_PRIORITY, {
		"context": ctx
	})

	return ctx

func _resolve_skill(action: BattleAction) -> SkillData:
	var medal: MedalState = state.medal_map.get(action.user_id)
	if medal == null:
		return null
	if not medal.equipped_skill_ids.has(action.action_id):
		return null
	return SkillDataBase.get_skill(action.action_id)

# ========================
# Turn Execute
# ========================

func _execute_turn() -> void:
	_sort_order()

	for ctx: ActionContext in order:
		if ctx.cancelled:
			continue
		execute_action(ctx)

	order.clear()
	end_turn()

func _sort_order() -> void:
	order.sort_custom(func(a: ActionContext, b: ActionContext):
		if a.priority != b.priority:
			return a.priority > b.priority
		if a.speed != b.speed:
			return a.speed > b.speed
		return randf() > 0.5
	)

# ========================
# Execute Action
# ========================

func execute_action(ctx: ActionContext) -> ActionResult:
	var result := ActionResult.new()

	trigger_event(EventTrigger.Type.ON_BEFORE_ACTION, {
		"context": ctx
	})

	if ctx.cancelled:
		return result

	match ctx.action.type:
		BattleAction.ActionType.SKILL:
			result = _execute_skill(ctx)
		BattleAction.ActionType.ROTATION:
			result = _execute_rotation(ctx.user.instance_id)

	emit_signal("action_resolved", result)
	return result

func _execute_skill(ctx: ActionContext) -> ActionResult:
	var result := ActionResult.new()
	result.success = true

	for target: MedalState in _resolve_targets(ctx):
		if target.is_dead():
			continue

		var dmg := DamageContext.new()
		dmg.user = ctx.user
		dmg.target = target
		dmg.skill = ctx.skill

		# --- 基本レート ---
		dmg.affinity_rate = _affinity_rate(target, ctx.skill)
		dmg.element_rate = _elements_rate(ctx.user, target)

		# --- ステージ補正（倍率にして渡す） ---
		var atk_stage = ctx.user.stat_stage[ctx.skill.attack_reference_stat]
		var def_stage = target.stat_stage[ctx.skill.defense_reference_stat]

		dmg.atk_stage_rate = pow(1.1, atk_stage)
		dmg.def_stage_rate = pow(1.1, def_stage)

		# --- Ability / Skill Hook ---
		trigger_event(EventTrigger.Type.ON_BEFORE_CALC_DAMAGE, {
			"context": dmg
		})

		if dmg.cancelled:
			continue

		# --- ダメージ計算 ---
		var calculator := DamageCalculator.new()
		dmg.total_damage = calculator.calculate(dmg)
		
		trigger_event(EventTrigger.Type.ON_AFTER_CALC_DAMAGE, {
			"context": dmg
		})
		
		# --- ダメージ適用 ---
		apply_damage(dmg)
		
	# --- 被弾トリガ ---
	trigger_event(EventTrigger.Type.ON_AFTER_ACTION)

	return result

func _resolve_targets(ctx: ActionContext) -> Array[MedalState]:
	var result: Array[MedalState] = []
	for id in ctx.action.target_ids:
		if state.medal_map.has(id):
			result.append(state.medal_map[id])
	return result

func _execute_rotation(user_id: String) -> ActionResult:
	var result := ActionResult.new()
	result.success = true
	return result

# ========================
# Hooks
# ========================

func _register_ability_hooks() -> void:
	for medal: MedalState in state.medal_map.values():
		if medal.ability_id:
			var hook = AbilityRegistry.create_hook(
				medal.ability_id,
				medal.source.instance_id
			)
			if hook:
				hooks.append(hook)

func trigger_event(event_type: EventTrigger.Type, event_data: Dictionary = {}) -> void:
	var snapshot := event_data.duplicate()
	for hook in hooks:
		if hook.trigger == event_type and hook.should_execute(state, snapshot):
			hook.execute(state, snapshot)
	hooks = hooks.filter(func(h): return h.is_active)

# ========================
# Turn End
# ========================

func end_turn() -> void:
	trigger_event(EventTrigger.Type.ON_TURN_END)
	p1_ready = false
	p2_ready = false
	emit_signal("turn_ended", state.current_turn)

func _is_party_dead(side: MedalState.Side) -> bool:
	for m in state.medal_map.values():
		if m.side == side and not m.is_dead():
			return false
	return true

# ========================
# Utility
# ========================

func apply_damage(dmg: DamageContext):
	var damage = dmg.total_damage
	var target = dmg.defender
	
	if target.hp - damage <= 0:
		to_died(target)
	
	target.hp -= damage

func to_died(target: MedalState):
	trigger_event(EventTrigger.Type.ON_SELF_BEFORE_DEATH,{"target"=target})
	trigger_event(EventTrigger.Type.ON_ALLY_BEFORE_DEATH,{"target"=target})
	trigger_event(EventTrigger.Type.ON_OPP_BEFORE_DEATH,{"target"=target})
	target.hp = 0
	trigger_event(EventTrigger.Type.ON_SELF_AFTER_DEATH,{"target"=target})
	trigger_event(EventTrigger.Type.ON_ALLY_AFTER_DEATH,{"target"=target})
	trigger_event(EventTrigger.Type.ON_OPP_AFTER_DEATH,{"target"=target})
	if _is_party_dead(target.side):
		pass

func _affinity_rate(
	defender: MedalState,
	skill: SkillData
) -> float:
	var affinity_multiplier = 0.2
	var add_rate := 0.0
	if defender.weakness_affinity.has(skill.affinity):
		add_rate += affinity_multiplier
	return add_rate

func _elements_rate(
	attacker: MedalState,
	defender: MedalState
) -> float:
	var elements_multiplier = 0.2
	var add_rate := 0.0
	for e in attacker.effectiveness_elements:
		if defender.elements.has(e):
			add_rate += elements_multiplier
	
	return add_rate
