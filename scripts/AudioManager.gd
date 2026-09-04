extends Node

var sonsCarregados: Dictionary = {
	"pulo": preload("res://sounds/jump.wav"),
	"interagir": preload("res://sounds/interagir.wav"),
	"andarGrama": preload("res://sounds/Grama.wav"),
	"atacar": preload("res://sounds/ataque.wav"),
	"dano": preload("res://sounds/hit.wav")
}

func tocarSom(nomeDoSom: String, variarPitch: bool = false) -> void:
	if not sonsCarregados.has(nomeDoSom):
		push_error("O som '%s' não foi encontrado no AudioManager." % nomeDoSom)
		return
		
	var reprodutorAudio = AudioStreamPlayer.new()
	reprodutorAudio.stream = sonsCarregados[nomeDoSom]
	
	# Normaliza o volume para não ficar muito alto
	if nomeDoSom == "atacar":
		reprodutorAudio.volume_db = -30.0 # O som de ataque é naturalmente muito mais estourado
	else:
		reprodutorAudio.volume_db = -15.0
	
	if variarPitch:
		reprodutorAudio.pitch_scale = randf_range(0.85, 1.15)
	
	add_child(reprodutorAudio)
	reprodutorAudio.play()
	
	reprodutorAudio.finished.connect(reprodutorAudio.queue_free)
