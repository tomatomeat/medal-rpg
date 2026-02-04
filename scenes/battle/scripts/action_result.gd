class_name ActionResult
extends RefCounted

var success: bool = false
var damage: int = 0
var healed: int = 0
var message: String = ""
var effects: Array[String] = []  # ["burned", "stat_change"]
