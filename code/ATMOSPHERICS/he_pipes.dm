#define NO_GAS 0.01
#define SOME_GAS 1
#define ENERGY_MULT 6.4   // Not sure what this is, keeping it the same as plates.

/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/obj/pipes/heat.dmi'
	icon_state = "intact"
	level = 2

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	var/radiation_capacity = 30000  // Radiation isn't particularly effective (TODO BALANCE)
									//  Plate value is 30000, increased it a bit because of additional surface area. - N3X
									// Screw you N3X15, 30000 is a perfectly fine number. - bur

	burst_type = /obj/machinery/atmospherics/unary/vent/burstpipe/heat_exchanging

	can_be_coloured = 0
	var/icon_temperature = T20C //stop small changes in temperature causing an icon refresh

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/getNodeType(var/node_id)
	return PIPE_TYPE_HE

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/update_icon(var/adjacent_procd)
	var/node_list = list(node1,node2)
	if(!node1 && !node2)
		qdel(src)
	if(!adjacent_procd)
		for(var/obj/machinery/atmospherics/node in node_list)
			if(node.update_icon_ready && !(istype(node,/obj/machinery/atmospherics/pipe/simple)))
				node.update_icon(1)

	// BubbleWrap
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/update_dir()
	..()
	initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	// BubbleWrap END

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = 0
	initialize_directions_he = pipe.get_pipe_dir()
	//var/turf/T = loc
	//level = T.intact ? 2 : 1
	if(!initialize(1))
		to_chat(usr, "Unable to build pipe here;  It must be connected to a machine, or another pipe that has a connection.")
		return 0
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/initialize(var/suppress_icon_check=0)
	normalize_dir()

	findAllConnections(initialize_directions_he)

	if(!suppress_icon_check)
		update_icon()
	return node1 || node2

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process()
	if(!parent)
		. = ..()

	//Get processable air sample and thermal info from environment
	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_moles = environment.molar_density() * CELL_VOLUME //Moles per turf
	//Get gas from pipenet
	var/datum/gas_mixture/internal = return_air()

	//fancy radiation glowing
	if(internal && internal.temperature)
		if(icon_temperature > 500 || internal.temperature > 500) //start glowing at 500K
			if(abs(internal.temperature - icon_temperature) > 10)
				icon_temperature = internal.temperature

				var/h_r = heat2color_r(icon_temperature)
				var/h_g = heat2color_g(icon_temperature)
				var/h_b = heat2color_b(icon_temperature)

				if(icon_temperature < 2000) //scale up overlay until 2000K
					var/scale = (icon_temperature - 500) / 1500
					h_r = 64 + (h_r - 64)*scale
					h_g = 64 + (h_g - 64)*scale
					h_b = 64 + (h_b - 64)*scale

				var/heat_color = rgb(h_r, h_g, h_b)

				animate(src, color = heat_color, time = 2 SECONDS, easing = SINE_EASING)
				light_color = heat_color
		set_light(internal.temperature >= 673.15 ? 1 : 0) //Red heat, visible in the dark

	//Not enough gas in the air around us to care about. Radiate. Less gas than airless tiles start with.
	if(environment_moles < NO_GAS)
		return radiate()
	//A tiny bit of air so this isn't really space, but it's not worth activating exchange procs
	else if(environment_moles < SOME_GAS)
		return 0

	if(!internal.total_moles)
		return

	var/datum/gas_mixture/external_removed = environment.remove(0.25 * environment_moles)
	var/datum/gas_mixture/internal_removed = internal.remove_volume(volume)


	//Get same info from connected gas
	var/combined_heat_capacity = internal_removed.heat_capacity() + external_removed.heat_capacity()
	var/combined_energy = internal_removed.thermal_energy() + external_removed.thermal_energy()

	if(!combined_heat_capacity)
		combined_heat_capacity = 1
	var/final_temperature = combined_energy / combined_heat_capacity

	external_removed.temperature = final_temperature
	environment.merge(external_removed)

	internal_removed.temperature = final_temperature
	internal.merge(internal_removed)


	if(parent && parent.network)
		parent.network.update = 1

	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/proc/radiate()
	var/datum/gas_mixture/internal = return_air()
	var/datum/gas_mixture/internal_removed = internal.remove_volume(volume)

	if (!internal_removed)
		return

	var/combined_heat_capacity = internal_removed.heat_capacity() + radiation_capacity
	var/combined_energy = internal_removed.thermal_energy() + (radiation_capacity * ENERGY_MULT)

	var/final_temperature = combined_energy / combined_heat_capacity

	internal_removed.temperature = final_temperature
	internal.merge(internal_removed)

	if(parent && parent.network)
		parent.network.update = 1

	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/hidden
	level=1
	icon_state="intact-f"

/////////////////////////////////
// JUNCTION
/////////////////////////////////
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/obj/pipes/junction.dmi'
	icon_state = "intact"
	level = 2
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/update_dir()
	..()
	switch (dir)
		if (SOUTH)
			initialize_directions = NORTH
			initialize_directions_he = SOUTH
		if (NORTH)
			initialize_directions = SOUTH
			initialize_directions_he = NORTH
		if (EAST)
			initialize_directions = WEST
			initialize_directions_he = EAST
		if (WEST)
			initialize_directions = EAST
			initialize_directions_he = WEST
	// BubbleWrap END

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pdir()
	initialize_directions_he = pipe.get_hdir()
	if (!initialize(1))
		to_chat(usr, "There's nothing to connect this junction to!")
		return 0
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/update_icon()
	if(node1&&node2)
		icon_state = "intact[invisibility ? "-f" : "" ]"
	else
		var/have_node1 = node1?1:0
		var/have_node2 = node2?1:0
		icon_state = "exposed[have_node1][have_node2]"

	if(!node1&&!node2)
		qdel(src)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/initialize(var/suppress_icon_check=0)
	node1 = findConnecting(initialize_directions)
	node2 = findConnectingHE(initialize_directions_he)

	if(!suppress_icon_check)
		update_icon()

	return node1 || node2

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/hidden
	level=1
	icon_state="intact-f"

/////////////////////////////////
// Manifold
/////////////////////////////////
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold
	icon = 'icons/obj/pipes/heat.dmi'
	icon_state = "he_manifold"
	var/obj/machinery/atmospherics/node3
	radiation_capacity = 24000

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold/update_dir()
	..()
	switch(dir)
		if(NORTH)
			initialize_directions_he = EAST|SOUTH|WEST
		if(SOUTH)
			initialize_directions_he = NORTH|EAST|WEST
		if(EAST)
			initialize_directions_he = NORTH|SOUTH|WEST
		if(WEST)
			initialize_directions_he = NORTH|EAST|SOUTH

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions_he = pipe.get_hdir()
	initialize(1)
	if (!node1 && !node2 && !node3)
		to_chat(usr, "There's nothing to connect this manifold to!")
		return 0
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	if (node3)
		node3.initialize()
		node3.build_network()
	return 1


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold/get_node(node_id)
	switch(node_id)
		if(1)
			return node1
		if(2)
			return node2
		if(3)
			return node3
		else
			CRASH("Invalid node_id!")

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold/set_node(node_id, value)
	switch(node_id)
		if(1)
			node1 = value
		if(2)
			node2 = value
		if(3)
			node3 = value
		else
			CRASH("Invalid node_id!")


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold/update_icon()
	if(!node1&&!node2&&!node3)
		qdel(src)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold/pipeline_expansion()
	return list(node1, node2, node3)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold/initialize(var/suppress_icon_check=0)
	findAllConnections(initialize_directions_he)

	if(!suppress_icon_check)
		update_icon()

/////////////////////////////////
// 4-Way Manifold
/////////////////////////////////
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold4w
	icon = 'icons/obj/pipes/heat.dmi'
	icon_state = "he_manifold4w"
	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4
	radiation_capacity = 24000

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold4w/update_dir()
	..()
	initialize_directions_he = NORTH|SOUTH|EAST|WEST

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold4w/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions_he = pipe.get_hdir()
	initialize(1)
	if (!node1 && !node2 && !node3 && !node4)
		to_chat(usr, "There's nothing to connect this manifold to!")
		return 0
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	if (node3)
		node3.initialize()
		node3.build_network()
	if (node4)
		node4.initialize()
		node4.build_network()
	return 1


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold4w/get_node(node_id)
	switch(node_id)
		if(1)
			return node1
		if(2)
			return node2
		if(3)
			return node3
		if(4)
			return node4
		else
			CRASH("Invalid node_id!")

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold4w/set_node(node_id, value)
	switch(node_id)
		if(1)
			node1 = value
		if(2)
			node2 = value
		if(3)
			node3 = value
		if(4)
			node4 = value
		else
			CRASH("Invalid node_id!")


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold4w/update_icon()
	if(!node1&&!node2&&!node3&&!node4)
		qdel(src)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/he_manifold4w/initialize(var/suppress_icon_check=0)
	findAllConnections(initialize_directions_he)

	if(!suppress_icon_check)
		update_icon()

#undef NO_GAS
#undef SOME_GAS
#undef ENERGY_MULT
