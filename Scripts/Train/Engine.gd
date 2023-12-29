# A type of TrainCarriage which applies power
class_name TrainEngine
extends TrainCarriage

func initialise(new_name:String):
	super(new_name)
	max_force = 1000
