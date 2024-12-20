/obj/structure/punching_bag
	name = "punching bag"
	desc = "A punching bag. Can you get to speed level 4???"
	icon = 'icons/fallout/objects/furniture/stationary.dmi'
	icon_state = "punchingbag"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	var/list/hit_sounds = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg',\
	'sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')

/obj/structure/punching_bag/on_attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	flick("[icon_state]2", src)
	playsound(loc, pick(hit_sounds), 25, 1, -1)
	if(isliving(user))
		var/mob/living/L = user
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "exercise", /datum/mood_event/exercise)
		L.apply_status_effect(STATUS_EFFECT_EXERCISED)

/obj/structure/weightmachine
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	density = TRUE
	anchored = TRUE
	var/icon_state_inuse

/obj/structure/weightmachine/proc/AnimateMachine(mob/living/user)
	return

/obj/structure/weightmachine/on_attack_hand(mob/living/user, act_intent = user.a_intent, unarmed_attack_flags)
	. = ..()
	if(.)
		return
	if(obj_flags & IN_USE)
		to_chat(user, "It's already in use - wait a bit.")
		return
	else
		obj_flags |= IN_USE
		icon_state = icon_state_inuse
		user.setDir(SOUTH)
		user.Stun(80)
		user.forceMove(src.loc)
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		AnimateMachine(user)

		playsound(user, 'sound/machines/click.ogg', 60, 1)
		obj_flags &= ~IN_USE
		user.pixel_y = 0
		var/finishmessage = pick("I feel stronger!","I feel like you can take on the world!","I feel robust!","I feel indestructible!")
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "exercise", /datum/mood_event/exercise)
		icon_state = initial(icon_state)
		to_chat(user, finishmessage)
		user.apply_status_effect(STATUS_EFFECT_EXERCISED)

/obj/structure/weightmachine/stacklifter
	icon = 'icons/fallout/objects/furniture/stationary.dmi'
	icon_state = "fitnesslifter"
	icon_state_inuse = "fitnesslifter2"

/obj/structure/weightmachine/stacklifter/AnimateMachine(mob/living/user)
	var/lifts = 0
	while (lifts++ < 6)
		if (user.loc != src.loc)
			break
		sleep(3)
		animate(user, pixel_y = -2, time = 3)
		sleep(3)
		animate(user, pixel_y = -4, time = 3)
		sleep(3)
		playsound(user, 'goon/sound/effects/spring.ogg', 60, 1)

/obj/structure/weightmachine/weightlifter
	icon = 'icons/fallout/objects/furniture/stationary.dmi'
	icon_state = "fitnessweight"
	icon_state_inuse = "fitnessweight-c"

/obj/structure/weightmachine/weightlifter/AnimateMachine(mob/living/user)
	var/mutable_appearance/swole_overlay = mutable_appearance(icon, "fitnessweight-w", WALL_OBJ_LAYER)
	add_overlay(swole_overlay)
	var/reps = 0
	user.pixel_y = 5
	while (reps++ < 6)
		if (user.loc != src.loc)
			break
		for (var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
			sleep(3)
			animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)
		playsound(user, 'goon/sound/effects/spring.ogg', 60, 1)
	sleep(3)
	animate(user, pixel_y = 2, time = 3)
	sleep(3)
	cut_overlay(swole_overlay)

/obj/structure/punching_bag/dummy
	name = "straw target"
	desc = "A training dummy made of straw, for training."
	icon = 'modular_roguetown/misc/structure.dmi'
	icon_state = "p_dummy"


/obj/structure/stacklifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/fallout/objects/furniture/stationary.dmi'
	icon_state = "fitnesslifter"
	density = TRUE
	anchored = TRUE

/obj/structure/stacklifter/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(obj_flags & IN_USE)
		to_chat(user, "It's already in use - wait a bit.")
		return
	else
		obj_flags |= IN_USE
		icon_state = "fitnesslifter2"
		user.setDir(SOUTH)
		user.Stun(80)
		user.forceMove(src.loc)
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		var/lifts = 0
		while (lifts++ < 6)
			if (user.loc != src.loc)
				break
			sleep(3)
			animate(user, pixel_y = -2, time = 3)
			sleep(3)
			animate(user, pixel_y = -4, time = 3)
			sleep(3)
			playsound(user, 'goon/sound/effects/spring.ogg', 60, 1)

		playsound(user, 'sound/machines/click.ogg', 60, 1)
		obj_flags &= ~IN_USE
		user.pixel_y = 0
		var/finishmessage = pick("I feel stronger!","I feel like you can take on the world!","I feel robust!","I feel indestructible!")
		icon_state = "fitnesslifter"
		to_chat(user, finishmessage)
		user.apply_status_effect(STATUS_EFFECT_EXERCISED)

/obj/structure/weightlifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/fallout/objects/furniture/stationary.dmi'
	icon_state = "fitnessweight"
	density = TRUE
	anchored = TRUE

/obj/structure/weightlifter/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(obj_flags & IN_USE)
		to_chat(user, "It's already in use - wait a bit.")
		return
	else
		obj_flags |= IN_USE
		icon_state = "fitnessweight-c"
		user.setDir(SOUTH)
		user.Stun(80)
		user.forceMove(src.loc)
		var/mutable_appearance/swole_overlay = mutable_appearance(icon, "fitnessweight-w", WALL_OBJ_LAYER)
		add_overlay(swole_overlay)
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		var/reps = 0
		user.pixel_y = 5
		while (reps++ < 6)
			if (user.loc != src.loc)
				break

			for (var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
				sleep(3)
				animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)

			playsound(user, 'goon/sound/effects/spring.ogg', 60, 1)

		sleep(3)
		animate(user, pixel_y = 2, time = 3)
		sleep(3)
		playsound(user, 'sound/machines/click.ogg', 60, 1)
		obj_flags &= ~IN_USE
		animate(user, pixel_y = 0, time = 3)
		var/finishmessage = pick("I feel stronger!","I feel like you can take on the world!","I feel robust!","I feel indestructible!")
		icon_state = "fitnessweight"
		cut_overlay(swole_overlay)
		to_chat(user, "[finishmessage]")
		user.apply_status_effect(STATUS_EFFECT_EXERCISED)
