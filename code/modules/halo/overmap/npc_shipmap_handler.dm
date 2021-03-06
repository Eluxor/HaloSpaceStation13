var/global/datum/npc_ship_map_handler/shipmap_handler = new

/datum/npc_ship_map_handler

	var/list/ship_map_zs = list()

	var/list/free_ship_map_zs = list()

	var/list/area_instances = list () //FORMAT: Instance = z-level

	var/max_z_cached = 0

/datum/npc_ship_map_handler/New()
	. = ..()

/datum/npc_ship_map_handler/proc/free_map(var/z_to_free)
	if(z_to_free in free_ship_map_zs)
		return
	ship_map_zs -= z_to_free
	free_ship_map_zs += z_to_free
	clear_z(z_to_free)

/datum/npc_ship_map_handler/proc/clear_z(var/z_level)
	set background = 1
	if(isnull(z_level))
		return
	message_admins("Clearing unused ship-z level:[z_level]. This may lag.")
	sleep(10)//Ensure above message is shown.
	var/list/z_level_toclear = block(locate(1,1,z_level),locate(255,255,z_level))
	for(var/turf/to_clear in z_level_toclear)
		for(var/atom/movable/obj_to_clear in to_clear.contents)
			obj_to_clear.loc = null
			GLOB.processing_objects -= obj_to_clear
			qdel(obj_to_clear)
		new /turf/space (to_clear)

/datum/npc_ship_map_handler/proc/un_free_map(var/z_to_un_free)
	if(z_to_un_free in free_ship_map_zs)
		free_ship_map_zs -= z_to_un_free
	ship_map_zs += z_to_un_free

/datum/npc_ship_map_handler/proc/get_next_usable_z()
	if(free_ship_map_zs.len > 0)
		return pick(free_ship_map_zs)
	else
		max_z_cached += 1
		world.maxz = max_z_cached
		return max_z_cached

/datum/npc_ship_map_handler/proc/spawn_ship(var/datum/faction/F, var/amount = 1, var/turf/spawn_loc)
	//pick a random location
	if(!spawn_loc)
		spawn_loc = pick(GLOB.overmap_tiles_uncontrolled)

	//just in case
	if(!F.ship_types.len)
		log_and_message_admins("SHIPS ERROR: Attempted to spawn [F.name] ships but there were none to choose from!")
		return

	var/ship_type = pick(F.ship_types)
	var/ships_spawned = list()
	if(ship_type)
		for(var/i = 0, i < amount, i++)
			var/obj/effect/overmap/ship/npc_ship/ship = new ship_type(null)
			ship.slipspace_to_location(pick(trange(7, spawn_loc)))
			ship.my_faction = F
			F.npc_ships.Add(ship)
			ships_spawned += ship
	else
		log_and_message_admins("WARNING: Attempted to spawn a \"[F.name]\" NPC ship but there were none to choose from.")
	return ships_spawned