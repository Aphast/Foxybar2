//Repeater: Activates every second.
/obj/structure/destructible/clockwork/trap/trigger/repeater
	name = "repeater"
	desc = "A small black prism with a gem in the center."
	clockwork_desc = "A repeater that will send an activation signal every second."
	max_integrity = 15 //Fragile!
	icon_state = "repeater"

/obj/structure/destructible/clockwork/trap/trigger/repeater/on_attack_hand(mob/living/user, act_intent = user.a_intent, unarmed_attack_flags)
	. = ..()
	if(.)
		return
	if(!is_servant_of_ratvar(user))
		return
	if(!IS_PROCESSING(SSprocessing, src))
		START_PROCESSING(SSprocessing, src)
		to_chat(user, span_notice("I activate [src]."))
		icon_state = "[icon_state]_on"
	else
		STOP_PROCESSING(SSprocessing, src)
		to_chat(user, span_notice("I halt [src]'s ticking."))
		icon_state = initial(icon_state)

/obj/structure/destructible/clockwork/trap/trigger/repeater/process()
	activate()
	playsound(src, 'sound/items/screwdriver2.ogg', 25, FALSE)

/obj/structure/destructible/clockwork/trap/trigger/repeater/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()
