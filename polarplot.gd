extends Control

var maxv = 1.0
var bcombined = false
var vvlenglo = -1.0
var vvlenghi = -1.0

func _ready():
	$MultiPlot.setpossize(size, maxv)
	
func pclearsamples(lbcombined):
	bcombined = lbcombined
	$MultiPlot.clearsamples(0)
	$MultiPlot.clearsamples(1)
	$MultiPlot.clearsamples(2)
	vvlenglo = -1.0
	vvlenghi = -1.0

func paddsample(d, vv):
	$MultiPlot.addsample(0, d, vv.x)
	$MultiPlot.addsample(1, d, vv.y)
	if bcombined:
		var vvleng = vv.length()
		if vvlenglo == -1.0 or vvleng < vvlenglo:
			vvlenglo = vvleng
		if vvlenghi == -1.0 or vvleng > vvlenghi:
			vvlenghi = vvleng
		$MultiPlot.addsample(2, d, vvleng)
	
func pdonesamples():
	$MultiPlot.donesamples(0)
	$MultiPlot.donesamples(1)
	if bcombined:
		$MultiPlot.donesamples(2)
		prints("Amplitude range:", vvlenglo, vvlenghi)

func _on_item_rect_changed():
	$MultiPlot.setpossize(size, maxv)
