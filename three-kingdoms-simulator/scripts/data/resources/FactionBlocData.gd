extends Resource
class_name FactionBlocData

# 派系块静态定义：势力内部政治集团

@export var id: String = ""
## 所属势力 ID
@export var faction_id: String = ""
## 派系块名称
@export var name: String = ""
## 派系类型：宗族、旧部、士族、外来等
@export var bloc_type: String = ""
## 核心成员角色 ID 列表
@export var core_character_ids: Array[String] = []
## 影响力权重
@export var influence_weight: int = 0
## 议程标签：主战、主和、改革、保守等
@export var agenda_tags: Array[String] = []
## 默认态度：support / neutral / oppose
@export var default_attitude: String = "neutral"
