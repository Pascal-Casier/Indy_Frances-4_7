extends Resource
class_name WordPair

@export var portuguese: String
@export var french: String

func set_properties(p_portuguese: String, p_french: String) -> WordPair:
	portuguese = p_portuguese
	french = p_french
	return self
