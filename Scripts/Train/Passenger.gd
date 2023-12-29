# A type of TrainCarriage which carries passengers
class_name TrainPassenger
extends TrainCarriage

func initialise(new_name:String):
	super(new_name)
	cargo_family = CargoFamilies.PASSENGERS
	cargo_capacity = 60
	cargo_mass = 0.08
	current_cargo_qty = cargo_capacity / 2 # TODO: start empty and use stations to load
