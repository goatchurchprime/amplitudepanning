extends Node2D

var polyvals = [ ]
var polys = [ ]
var containersize = Vector2(300,300)

func _ready():
	pass
	
func setpossize(lcontainersize, maxv):
	containersize = lcontainersize
	position = containersize*0.5
	var sca = 0.5*min(containersize.x, containersize.y)/maxv
	scale = Vector2(sca, sca)
	$Line2Dxaxis.width = 2/sca
	$Line2Dyaxis.width = 2/sca

const colours = [ Color.AQUA, Color.BURLYWOOD, Color.DARK_GRAY, 
				  Color.CORAL, Color.CRIMSON, Color.GREEN_YELLOW ]
func atleastpolys(i):
	while $Polygons.get_child_count() <= i:
		polyvals.append(PackedVector2Array())
		polys.append(PackedVector2Array([Vector2.ZERO]))
		var newpolygon = Polygon2D.new()
		newpolygon.polygon = polys[-1]
		var bsecondplot = (int(get_parent().get_name()) == 2)
		newpolygon.color = colours[(i + (3 if bsecondplot else 0))%len(colours)]*Color(1,1,1,0.3)
		$Polygons.add_child(newpolygon)

func clearsamples(i):
	atleastpolys(i)
	polyvals[i] = PackedVector2Array()
	polys[i] = PackedVector2Array([Vector2.ZERO])
	$Polygons.get_child(i).polygon = polys[i]

func addsample(i, d, v):
	atleastpolys(i)
	polyvals[i].append(Vector2(d, v))
	polys[i].append(Vector2(cos(deg_to_rad(d))*v, -sin(deg_to_rad(d))*v))
	$Polygons.get_child(i).polygon = polys[i]

func donesamples(i):
	polys[i].remove_at(0)
	$Polygons.get_child(i).polygon = polys[i]
