//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.

GLOBAL_LIST_EMPTY(conveyors_by_id)

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_map"
	name = "conveyor belt"
	desc = "A conveyor belt."
	layer = BELOW_OPEN_DOOR_LAYER
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/forwards		// this is the default (forward) direction, set by the map dir
	var/backwards		// hopefully self-explanatory
	var/movedir			// the actual direction to move stuff in

	var/list/affecting	// the list of all items that will be moved this ptick
	var/id = ""			// the control ID	- must match controller ID
	var/verted = 1		// Inverts the direction the conveyor belt moves.
	speed_process = TRUE

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"


/obj/machinery/conveyor/inverted //Directions inverted so you can use different corner peices.
	icon_state = "conveyor_map_inverted"
	verted = -1

/obj/machinery/conveyor/inverted/Initialize(mapload)
	. = ..()
	if(mapload && !(dir in GLOB.diagonals))
		log_mapping("[src] at [AREACOORD(src)] spawned without using a diagonal dir. Please replace with a normal version.")

// Auto conveyour is always on unless unpowered

/obj/machinery/conveyor/auto/Initialize(mapload, newdir)
	. = ..()
	operating = TRUE
	update_move_direction()

/obj/machinery/conveyor/auto/update()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = FALSE
		return
	else if(!operable)
		operating = FALSE
	else if(stat & NOPOWER)
		operating = FALSE
	else
		operating = TRUE
	icon_state = "conveyor[operating * verted]"

// create a conveyor
/obj/machinery/conveyor/Initialize(mapload, newdir, newid)
	. = ..()
	if(newdir)
		setDir(newdir)
	if(newid)
		id = newid
	update_move_direction()
	LAZYADD(GLOB.conveyors_by_id[id], src)

/obj/machinery/conveyor/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	. = ..()

/obj/machinery/conveyor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH
	if(verted == -1)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == 1)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/machinery/conveyor/proc/update()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = FALSE
		return
	if(!operable)
		operating = FALSE
	if(stat & NOPOWER)
		operating = FALSE
	icon_state = "conveyor[operating * verted]"

	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(6)
	affecting = loc.contents - src		// moved items will be all in loc
	addtimer(CALLBACK(src,PROC_REF(convey), affecting), 1)

/obj/machinery/conveyor/proc/convey(list/affecting)
	var/turf/T = get_step(src, movedir)
	if(length(T.contents) > 150)
		return
	affecting.len = min(affecting.len, 150 - length(T.contents))
	for(var/atom/movable/A in affecting)
		if((A.loc == loc) && A.has_gravity())
			A.ConveyorMove(movedir)

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/crowbar))
		user.visible_message(span_notice("[user] struggles to pry up \the [src] with \the [I]."), \
		span_notice("I struggle to pry up \the [src] with \the [I]."))
		if(I.use_tool(src, user, 40, volume=40))
			if(!(stat & BROKEN))
				var/obj/item/stack/conveyor/C = new /obj/item/stack/conveyor(loc, 1, TRUE, id)
				transfer_fingerprints_to(C)
			to_chat(user, span_notice("I remove the conveyor belt."))
			qdel(src)

	else if(istype(I, /obj/item/wrench))
		if(!(stat & BROKEN))
			I.play_tool_sound(src)
			setDir(turn(dir,-45))
			update_move_direction()
			to_chat(user, span_notice("I rotate [src]."))

	else if(istype(I, /obj/item/screwdriver))
		if(!(stat & BROKEN))
			verted = verted * -1
			update_move_direction()
			to_chat(user, span_notice("I reverse [src]'s direction."))

	else if(user.a_intent != INTENT_HARM)
		user.transferItemToLoc(I, drop_location())
	else
		return ..()

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	user.Move_Pulled(src)

// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	stat |= BROKEN
	update()

	var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
	if(C)
		C.set_operable(dir, id, 0)

	C = locate() in get_step(src, turn(dir,180))
	if(C)
		C.set_operable(turn(dir,180), id, 0)


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id != match_id)
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id, op)

/obj/machinery/conveyor/power_change()
	..()
	update()

// the conveyor control switch
//
//

/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	speed_process = TRUE

	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/operated = 1			// true if just operated
	var/oneway = FALSE			// if the switch only operates the conveyor belts in a single direction.
	var/invert_icon = FALSE		// If the level points the opposite direction when it's turned on.

	var/id = "" 				// must match conveyor IDs to control them

/obj/machinery/conveyor_switch/Initialize(mapload, newid)
	. = ..()
	if (newid)
		id = newid
	update_icon()
	LAZYADD(GLOB.conveyors_by_id[id], src)

/obj/machinery/conveyor_switch/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	. = ..()

/obj/machinery/conveyor_switch/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

// update the icon depending on the position

/obj/machinery/conveyor_switch/update_icon_state()
	if(position<0)
		if(invert_icon)
			icon_state = "switch-fwd"
		else
			icon_state = "switch-rev"
	else if(position>0)
		if(invert_icon)
			icon_state = "switch-rev"
		else
			icon_state = "switch-fwd"
	else
		icon_state = "switch-off"


// timed process
// if the switch changed, update the linked conveyors

/obj/machinery/conveyor_switch/process()
	if(!operated)
		return
	operated = 0

	for(var/obj/machinery/conveyor/C in GLOB.conveyors_by_id[id])
		C.operating = position
		C.update_move_direction()
		CHECK_TICK

// attack with hand, switch position
/obj/machinery/conveyor_switch/interact(mob/user)
	add_fingerprint(user)
	if(position == 0)
		if(oneway)   //is it a oneway switch
			position = oneway
		else
			if(last_pos < 0)
				position = 1
				last_pos = 0
			else
				position = -1
				last_pos = 0
	else
		last_pos = position
		position = 0

	operated = 1
	update_icon()

	// find any switches with same id as this one, and set their positions to match us
	for(var/obj/machinery/conveyor_switch/S in GLOB.conveyors_by_id[id])
		S.invert_icon = invert_icon
		S.position = position
		S.update_icon()
		CHECK_TICK

/obj/machinery/conveyor_switch/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/crowbar))
		var/obj/item/conveyor_switch_construct/C = new/obj/item/conveyor_switch_construct(src.loc)
		C.id = id
		transfer_fingerprints_to(C)
		to_chat(user, span_notice("I detach the conveyor switch."))
		qdel(src)

/obj/machinery/conveyor_switch/oneway
	icon_state = "conveyor_switch_oneway"
	desc = "A conveyor control switch. It appears to only go in one direction."
	oneway = TRUE

/obj/machinery/conveyor_switch/oneway/Initialize()
	. = ..()
	if((dir == NORTH) || (dir == WEST))
		invert_icon = TRUE

/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	w_class = WEIGHT_CLASS_NORMAL
	var/id = "" //inherited by the switch

/obj/item/conveyor_switch_construct/Initialize()
	. = ..()
	id = "[rand()]" //this couldn't possibly go wrong

/obj/item/conveyor_switch_construct/attack_self(mob/user)
	for(var/obj/item/stack/conveyor/C in view())
		C.id = id
	to_chat(user, span_notice("I have linked all nearby conveyor belt assemblies to this switch."))

/obj/item/conveyor_switch_construct/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/found = 0
	for(var/obj/machinery/conveyor/C in view())
		if(C.id == src.id)
			found = 1
			break
	if(!found)
		to_chat(user, "[icon2html(src, user)]<span class=notice>The conveyor switch did not detect any linked conveyor belts in range.</span>")
		return
	var/obj/machinery/conveyor_switch/NC = new/obj/machinery/conveyor_switch(A, id)
	transfer_fingerprints_to(NC)
	qdel(src)

/obj/item/stack/conveyor
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_construct"
	max_amount = 30
	singular_name = "conveyor belt"
	w_class = WEIGHT_CLASS_BULKY
	///id for linking
	var/id = ""
	merge_type = /obj/item/stack/conveyor

/obj/item/stack/conveyor/Initialize(mapload, new_amount, merge = TRUE, _id)
	. = ..()
	id = _id

/obj/item/stack/conveyor/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/cdir = get_dir(A, user)
	if(A == user.loc)
		to_chat(user, span_warning("I cannot place a conveyor belt under yourself!"))
		return
	var/obj/machinery/conveyor/C = new/obj/machinery/conveyor(A, cdir, id)
	transfer_fingerprints_to(C)
	use(1)

/obj/item/stack/conveyor/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/conveyor_switch_construct))
		to_chat(user, span_notice("I link the switch to the conveyor belt assembly."))
		var/obj/item/conveyor_switch_construct/C = I
		id = C.id

/obj/item/stack/conveyor/update_weight()
	return FALSE

/obj/item/stack/conveyor/thirty
	amount = 30

/obj/item/stack/conveyor/fifteen
	amount = 15

/obj/item/paper/guides/conveyor
	name = "paper- 'Nano-it-up U-build series, #9: Build your very own conveyor belt, in SPACE'"
	info = "<h1>Congratulations!</h1><p>You are now the proud owner of the best conveyor set available for space mail order! We at Nano-it-up know you love to prepare your own structures without wasting time, so we have devised a special streamlined assembly procedure that puts all other mail-order products to shame!</p><p>Firstly, you need to link the conveyor switch assembly to each of the conveyor belt assemblies. After doing so, you simply need to install the belt assemblies onto the floor, et voila, belt built. Our special Nano-it-up smart switch will detected any linked assemblies as far as the eye can see! This convenience, you can only have it when you Nano-it-up. Stay nano!</p>"

/obj/item/paper/exhibit/future1
	name = "Hall of the Future - Our Present"
	info = "<h1>The Present</h1><p>We live in an age of unprecedented global tension. The foul communists, not content in the annexation of peaceful neighbours in their greed for resources and power, have now turned their attention toward the golden land of the United States in their barbaric madness. You will have no doubt heard about socialist incursions into Alaska, and more recently the actions of our brave troops on the mainland itself as they work to keep the crazed communists from destroying all we hold dear.</p><p>We have the utmost confidence in the success of the greatest country on Earth. But the insanity of socialism cannot be understated. What if, in their last wicked gasps of air, our sworn enemy decides to unleash the forbidden fruit of NUCLEAR ARMAGEDDON? To bring hellfire, death, and destruction upon us all? This exhibit demonstrates such an event. As you can imagine, the consequences for your family in such a scenario are all too clear.</p>"

/obj/item/paper/exhibit/future2
	name = "Hall of the Future - The Near Future"
	info = "<h1>The Near Future</h1><p>The lives of your loved ones do not have to be left to chance - Vault-Tec is here to help us all under contract of the US Government themselves. For those who are unfamiliar, we introduce the 'Vault' - a state-of-the-art subterranean shelter designed to withstand the horrors of nuclear warfare. These facilities are being constructed all across the country to help people like you, hundreds of feet beneath the soil by some of the finest engineers of this generation.</p><p>While you may have seen all sorts of shelters advertised on the news lately, the quality of life that a Vault offers is unmatched. Food synthesisers, water purification systems, geothermal power generators, private dormitories, gymnasiums, even a functioning hospital - a Vault offers everything you could possibly need, far more than a hole in a ground could ever hope to offer, and is guaranteed to remain operational for at least 900 years!</p>"

/obj/item/paper/exhibit/future3
	name = "Hall of the Future - The Far Future"
	info = "<h1>The Far Future</h1><p>Noone can say when exactly the nuclear horrors of the surface will subside. But when the day comes, Vault-Tec is ready - and all across the country, proud citizens will emerge from their enduring concrete homes, ready to restore the planet exactly as it once was with their specially provided Garden of Eden Creation Kits. These terraforming devices truly are a marvel, transforming radioactive hellscapes into lush fields and forests. While in the Vault, dwellers will become masters of agriculture, architecture, every skilled trade imaginable - and will be ready to bring America back to former glory in no time at all.</p><p>Interested in learning more about the Vault Program? You're in luck - keep walking to access one of our special DEMONSTRATION VAULTS. This facility, while far smaller than an actual Vault, will give you a taste of your potential future. When you're done, talk to one of our on-site representatives to find out more about booking your place in a real Vault!</p>"
