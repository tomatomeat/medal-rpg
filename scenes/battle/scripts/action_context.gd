class_name ActionContext
extends RefCounted

#BattleManager内で生成するアクション情報

var action: BattleAction
var user: MedalState
var targets: Array[MedalState] = []

var priority: int
var speed: int
var skill: SkillData

var cancelled := false
