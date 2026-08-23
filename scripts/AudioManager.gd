extends Node

var sonsPorNome = {
	"pulo": preload("res://sounds/jump.wav"),
	"interagir": preload("res://sounds/interagir.wav"),
	"andarGrama": preload("res://sounds/Grama.wav")
}

func tocarSom(nomeSom: String, variarTom: bool = false) -> void:
	if not sonsPorNome.has(nomeSom):
		push_error("O som '%s' não foi encontrado no AudioManager." % nomeSom)
		return

	var reprodutor = AudioStreamPlayer.new()
	reprodutor.stream = sonsPorNome[nomeSom]
	
	if variarTom:
		reprodutor.pitch_scale = randf_range(0.85, 1.15)
	
	add_child(reprodutor)
	reprodutor.play()
	reprodutor.finished.connect(reprodutor.queue_free)
