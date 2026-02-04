extends Resource
class_name Elements

enum Type {
	SCALE,    # 鱗
	FUR,      # 毛
	CARAPACE,    # 甲
	SHELL, # 殻
	FEATHER,  # 羽
	SKIN,     # 皮
	LIQUID,   # 液
	SPIRIT,   # 霊
	MATTER    # 物
}

@export_enum("鱗", "毛", "甲", "殻", "羽", "皮", "液", "霊", "物") 
var element: int = Type.SCALE

func _to_string() -> String:
	var names = ["鱗", "毛", "甲", "殻", "羽", "皮", "液", "霊", "物"]
	return names[element]
