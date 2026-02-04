extends Resource
class_name Affinity

enum Type {
	FIRE,
	WATER,
	WIND,
	VOLT,
	LIGHT,
	GROUND,
	GRASS,
	GHOST,
	NORMAL,
	HOLLOW,
	MELT,
	FROZEN
}


@export_enum("火", "水", "風", "雷", "光", "地", "草", "妖", "無", "虚", "溶", "凍") 
var affinity: int = Type.FIRE

func _to_string() -> String:
	var names = ["火", "水", "風", "雷", "光", "地", "草", "妖", "無", "虚", "溶", "凍"]
	return names[affinity]
