extends Node3D

@onready var capture : AudioEffectCapture = AudioServer.get_bus_effect(0, 0)
@onready var generatorplayback : AudioStreamGeneratorPlayback
@onready var sample_hz = $SoundSource/AudioStreamPlayer3D.stream.mix_rate
var pulse_hz = 440.0 # The frequency of the sound wave.
var panningstrength = 1.0
var phase = 0.0
var predictedrms = 0.0

func _ready():
	sample_hz = AudioServer.get_mix_rate()/2.0
	$SoundSource/AudioStreamPlayer3D.stream.mix_rate = sample_hz

func setsoundfreqon(lpulse_hz, lpanningstrength):
	pulse_hz = float(lpulse_hz)
	panningstrength = lpanningstrength
	$SoundSource/AudioStreamPlayer3D.play()
	generatorplayback = $SoundSource/AudioStreamPlayer3D.get_stream_playback()
	$SoundSource/AudioStreamPlayer3D.panning_strength = panningstrength
	
func fill_buffer():
	var increment = pulse_hz / sample_hz
	var to_fill = generatorplayback.get_frames_available()
	while to_fill > 0:
		generatorplayback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1

var capturedbuffer = PackedVector2Array()
func _process(delta):
	if generatorplayback:
		fill_buffer()
	while true:
		var lcapturedbuffer = capture.get_buffer(sample_hz/pulse_hz)
		if lcapturedbuffer:
			capturedbuffer = lcapturedbuffer
		else:
			break
	
func getrms():
	var ssum = Vector2()
	for a in capturedbuffer:
		ssum += a*a
	return Vector2(sqrt(ssum.x/len(capturedbuffer)), sqrt(ssum.y/len(capturedbuffer)))

func getmax():
	var l = 0
	var r = 0
	for a in capturedbuffer:
		l = max(l, abs(a.x))
		r = max(r, abs(a.y))
	return Vector2(l, r)

func setsoundsourcepos(d, r, y):
	$SoundSource.position = Vector3(cos(deg_to_rad(d))*r, y, -sin(deg_to_rad(d))*r)

func getpredictedrms():
	var vec2 = Vector2($SoundSource.position.x, $SoundSource.position.z)
	var flatrad = vec2.length()
	var cosx = clamp(vec2.x/flatrad, -1.0, 1.0)
	var ps = clamp(panningstrength*0.5, 0.0, 1.0)
	var g = (1.0 - ps)*(1.0 - ps)
	var f = (1.0 - g)/(1.0 + g)
	var fcosx = cosx*f;
	return Vector2(sqrt((-fcosx + 1.0)/2.0), sqrt((fcosx + 1.0)/2.0))
