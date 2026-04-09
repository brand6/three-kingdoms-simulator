extends RefCounted
class_name FactionSystem


func get_player_position_summary(session: GameSession) -> Dictionary:
	if session == null or session.player_career_state == null:
		return {}
	var repository := _repository()
	var protagonist = repository.call("get_character", session.protagonist_id) as CharacterDefinition
	var faction = repository.call("get_faction", protagonist.faction_id if protagonist != null else "") as FactionDefinition
	var office = repository.call("get_office", session.player_career_state.current_office_id)
	return {
		"character_id": session.protagonist_id,
		"faction_id": str(faction.id if faction != null else ""),
		"faction_name": str(faction.name if faction != null else "—"),
		"office_id": str(session.player_career_state.current_office_id),
		"office_name": str(office.name if office != null else session.player_career_state.current_office_id),
		"office_tags": Array(session.player_career_state.office_tags).duplicate(),
		"recommendation_power": int(session.player_career_state.recommendation_power),
		"political_risk_level": str(session.player_career_state.political_risk_level),
		"trust": int(session.player_career_state.current_trust),
		"merit": int(session.player_career_state.total_merit),
	}


func get_bloc_rows(faction_id: String, session: GameSession, snapshot_override: Variant = null) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var repository := _repository()
	var snapshot = snapshot_override if snapshot_override != null else (session.current_month_political_snapshot if session != null else null)
	for bloc in repository.call("get_faction_blocs", faction_id):
		var attitude := str(snapshot.bloc_attitudes.get(bloc.id, bloc.default_attitude) if snapshot != null else bloc.default_attitude)
		rows.append({
			"bloc_id": str(bloc.id),
			"name": str(bloc.name),
			"attitude": _localized_attitude(attitude),
			"core_character_ids": Array(bloc.core_character_ids).duplicate(),
			"influence_weight": int(bloc.influence_weight),
			"agenda_tags": Array(bloc.agenda_tags).duplicate(),
		})
	return rows


func get_faction_overview(faction_id: String, session: GameSession) -> Dictionary:
	var repository := _repository()
	var faction = repository.call("get_faction", faction_id) as FactionDefinition
	if faction == null:
		return {}
	var ruler = repository.call("get_character", faction.ruler_id) as CharacterDefinition
	var capital = repository.call("get_city", faction.capital_city_id) as CityDefinition
	var major_officers: Array[String] = []
	for officer_id in faction.officer_ids:
		if major_officers.size() >= 3:
			break
		major_officers.append(str(officer_id))
	return {
		"faction_id": faction.id,
		"faction_name": faction.name,
		"ruler_id": faction.ruler_id,
		"ruler_name": str(ruler.name if ruler != null else faction.ruler_id),
		"capital_city_id": faction.capital_city_id,
		"capital_city_name": str(capital.name if capital != null else faction.capital_city_id),
		"major_officer_ids": major_officers,
		"city_count": faction.city_ids.size(),
		"resource_summary": get_resource_summary(faction.id),
		"player_position": get_player_position_summary(session),
	}


func get_resource_summary(faction_id: String) -> Dictionary:
	var repository := _repository()
	var faction = repository.call("get_faction", faction_id) as FactionDefinition
	if faction == null:
		return {}
	var summary := Dictionary(faction.political_resource_summary).duplicate(true)
	if summary.is_empty():
		var resources := Dictionary(faction.resources)
		summary = {
			"military_pressure": _bucket_label(int(resources.get("troops", 0)), 10000, 26000),
			"governance_load": _bucket_label(int(resources.get("stability", 0)), 50, 72, true),
			"grain_reserve_level": _bucket_label(int(resources.get("food", 0)), 5000, 20000),
			"staffing_tension": _bucket_label(faction.officer_ids.size(), 2, 4, true),
		}
	return summary


func _repository() -> Node:
	return Engine.get_main_loop().root.get_node("/root/DataRepository")


func _localized_attitude(value: String) -> String:
	match value:
		"support":
			return "支持"
		"oppose":
			return "反对"
		_:
			return "观望"


func _bucket_label(value: int, low: int, high: int, reverse: bool = false) -> String:
	if reverse:
		if value <= low:
			return "低"
		if value >= high:
			return "高"
		return "中"
	if value <= low:
		return "低"
	if value >= high:
		return "高"
	return "中"
