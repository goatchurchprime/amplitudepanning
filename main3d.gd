extends Control

func getfloat(option):
	return float(option.get_item_text(max(0, option.get_selected_id())))

func _on_start_sampling_pressed():
	$SoundScene/SoundSource/AudioStreamPlayer3D.stream_paused = false
	$SoundScene.setsoundfreqon(getfloat($HBoxContainer/SourceSoundFreq), 
							   getfloat($HBoxContainer/PanningStrength))
	var yalt = getfloat($HBoxContainer/Yaltitude)
	var bsecondplot = $HBoxContainer/SecondPlot.button_pressed
	var bpredicted = $HBoxContainer/Predicted.button_pressed
	var bcombined = $HBoxContainer/Combined.button_pressed
	$PolarPlot2.visible = bsecondplot
	var r = getfloat($HBoxContainer/SourceDistance)
	var nsamples = 100
	var polarplot = ($PolarPlot2 if bsecondplot else $PolarPlot)
	polarplot._on_item_rect_changed()
	polarplot.pclearsamples(bcombined)
	for i in range(nsamples):
		var d = i*360.0/nsamples
		$SoundScene.setsoundsourcepos(d, r, yalt)
		await get_tree().create_timer(0.06).timeout
		var rms = $SoundScene.getrms()
		if bpredicted:
			rms = $SoundScene.getpredictedrms()
		polarplot.paddsample(d, rms)
	polarplot.pdonesamples()
	$SoundScene/SoundSource/AudioStreamPlayer3D.stream_paused = true

func _on_second_plot_toggled(toggled_on):
	$PolarPlot2.visible = toggled_on
