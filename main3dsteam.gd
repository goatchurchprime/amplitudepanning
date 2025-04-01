extends Node3D

@onready var capture : AudioEffectCapture = AudioServer.get_bus_effect(0, 0)
@onready var generatorplayback : AudioStreamGeneratorPlayback
@onready var sample_hz = $SoundSource/AudioStreamPlayer3D.get_inner_stream().mix_rate
var pulse_hz = 440.0 # The frequency of the sound wave.
var phase = 0.0

var polyrad = 500
var rotrad = 3.0

func _ready():
	sample_hz = 22050
	$SoundSource/AudioStreamPlayer3D.get_inner_stream().mix_rate = sample_hz
	$SoundSource/AudioStreamPlayer3D.play()
	await get_tree().process_frame
	generatorplayback = $SoundSource/AudioStreamPlayer3D.get_inner_stream_playback()
	$Display2D.position = DisplayServer.window_get_size()/2
	print($Display2D/PolygonLeft.polygon)
	await get_tree().create_timer(1).timeout
	measureincoming(rotrad, 100)

func fill_buffer():
	var increment = pulse_hz / sample_hz
	var to_fill = generatorplayback.get_frames_available()
	while to_fill > 0:
		generatorplayback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1

var capturedbuffer = PackedVector2Array()
func _process(delta):
	fill_buffer()
	while true:
		var lcapturedbuffer = capture.get_buffer(44100/pulse_hz)
		if lcapturedbuffer:
			capturedbuffer = lcapturedbuffer
		else:
			break
	
func getrms():
	var ssum = Vector2()
	for a in capturedbuffer:
		ssum += a*a
	return ssum/len(capturedbuffer)

func measureincoming(r, nsamples):
	var polygonleft = PackedVector2Array()
	var polygonright = PackedVector2Array()
	for i in range(nsamples):
		var vec = Vector3(cos(i*TAU/nsamples), 0.0, sin(i*TAU/nsamples))
		$SoundSource.position = vec*r
		await get_tree().create_timer(0.06).timeout
		var rms = getrms()
		var vec2 = Vector2(vec.x, vec.z)*polyrad
		polygonleft.append(vec2*rms.x)
		polygonright.append(vec2*rms.y)

	$Display2D/PolygonLeft.polygon = polygonleft
	$Display2D/PolygonRight.polygon = polygonright
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		measureincoming(rotrad, 100)
