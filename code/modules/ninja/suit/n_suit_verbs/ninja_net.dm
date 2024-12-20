
//Allows the ninja to kidnap people
/obj/item/clothing/suit/space/space_ninja/proc/ninjanet()
	var/mob/living/carbon/human/H = affecting
	var/mob/living/carbon/C

	//If there's only one valid target, let's actually try to capture it, rather than forcing
	//the user to fiddle with the dialog displaying a list of one
	//Also, let's make this smarter and not list mobs you can't currently net.
	var/list/candidates
	for(var/mob/M in oview(H))
		if(!M.client)//Monkeys without a client can still step_to() and bypass the net. Also, netting inactive people is lame.
			continue
		for(var/obj/structure/energy_net/E in get_turf(M))//Check if they are already being affected by an energy net.
			if(E.affecting == M)
				continue
		LAZYADD(candidates, M)

	if(!LAZYLEN(candidates))
		return FALSE

	if(candidates.len == 1)
		C = candidates[1]
	else
		C = input("Select who to capture:","Capture who?",null) as null|mob in candidates


	if(QDELETED(C)||!(C in oview(H)))
		return FALSE

	if(!ninjacost(200,N_STEALTH_CANCEL))
		H.Beam(C,"n_beam",time=15)
		H.say("Get over here!", forced = "ninja net")
		var/obj/structure/energy_net/E = new /obj/structure/energy_net(C.drop_location())
		E.affecting = C
		E.master = H
		H.visible_message(span_danger("[H] caught [C] with an energy net!"),span_notice("I caught [C] with an energy net!"))

		if(C.buckled)
			C.buckled.unbuckle_mob(affecting,TRUE)
		E.buckle_mob(C, TRUE) //No moving for you!
		//The person can still try and attack the net when inside.

		START_PROCESSING(SSobj, E)
