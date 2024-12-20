/obj/item/disk/surgery/reconstruction
	name = "Reconstruction Surgery Disk"
	desc = "The disk provides instructions on how to repair a body without the use of chemicals."
	surgeries = list(/datum/surgery/advanced/reconstruction)

/datum/surgery/advanced/reconstruction
	name = "Repair body tissue"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/reconstruct,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = 0
	requires_trait = 1

/datum/surgery_step/reconstruct
	name = "repair body"
	implements = list(/obj/item/hemostat = 100, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	repeatable = TRUE
	time = 25

/datum/surgery_step/reconstruct/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts knitting some of [target]'s flesh back together.", span_notice("I start knitting some of [target]'s flesh back together."))

/datum/surgery_step/reconstruct/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] fixes some of [target]'s wounds.", span_notice("I succeed in fixing some of [target]'s wounds."))
	target.heal_bodypart_damage(10,10)
	return TRUE

/datum/surgery_step/reconstruct/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] screws up!", span_warning("I screwed up!"))
	target.take_bodypart_damage(5,0)
	return FALSE
