extends Node

var _sons_carregados: Dictionary = {
	"pulo": preload("res://sounds/jump.wav"),
	"interagir": preload("res://sounds/interagir.wav"),
	"andarGrama": preload("res://sounds/Grama.wav"),
	"atacar": preload("res://sounds/ataque.wav"),
	"dano": preload("res://sounds/hit.wav")
}

func tocar_som(nome_do_som: String, variar_pitch: bool = false) -> void:
	if not _sons_carregados.has(nome_do_som):
		push_error("O som '%s' não foi encontrado no AudioManager." % nome_do_som)
		return
		
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = _sons_carregados[nome_do_som]
	
	if variar_pitch:
		audio_player.pitch_scale = randf_range(0.85, 1.15)
	
	add_child(audio_player)
	audio_player.play()
	
	audio_player.finished.connect(audio_player.queue_free)
