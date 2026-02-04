class_name MedalPresenter

static func get_display_name(medal: MedalInstance) -> String:
	var base_name := _get_base_name(medal)

	# title が無ければそのまま
	if medal.title_id == "":
		return base_name

	var title := TitleDataBase.get_title(medal.title_id)
	if title == null:
		return base_name

	var title_name := title.get_tr_name()

	if title.is_prefix:
		# 前置き称号
		return "%s %s" % [title_name, base_name]
	else:
		# 後置き称号（好みで () とかに変えてOK）
		return "%s %s" % [base_name, title_name]

static func _get_base_name(medal: MedalInstance) -> String:
	# nickname があれば最優先
	if medal.nickname != "":
		return medal.nickname

	# 無ければデフォルト名
	return medal.data.get_tr_name()
