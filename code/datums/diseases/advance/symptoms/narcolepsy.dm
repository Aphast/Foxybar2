
/*
//////////////////////////////////////
Narcolepsy
	Noticeable.
	Lowers resistance
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.

Bonus
	Causes drowsiness and sleep.

//////////////////////////////////////
*/
/datum/symptom/narcolepsy
	name = "Narcolepsy"
	desc = "The virus causes a hormone imbalance, making the host sleepy and narcoleptic."
	stealth = -1
	resistance = -2
	stage_speed = -3
	transmittable = 0
	level = 6
	symptom_delay_min = 15
	symptom_delay_max = 80
	severity = 4
	var/sleep_level = 0
	var/sleepy_ticks = 0
	var/stamina = FALSE
	threshold_desc = list(
		"Transmission 4" = "Causes the host to periodically emit a yawn that spreads the virus in a manner similar to that of a sneeze.",
		"Stage Speed 10" = "Causes narcolepsy more often, increasing the chance of the host falling asleep.",
	)

/datum/symptom/narcolepsy/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 7) //stamina damage
		stamina = TRUE
	if(A.properties["resistance"] >= 10) //act more often
		symptom_delay_min = 10
		symptom_delay_max = 60

/datum/symptom/narcolepsy/Activate(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	//this ticks even when on cooldown
	switch(sleep_level) //Works sorta like morphine
		if(10 to 19)
			M.drowsyness += 1
		if(20 to INFINITY)
			M.Sleeping(30, 0)
			sleep_level = 0
			sleepy_ticks = 0

	if(sleepy_ticks && A.stage>=5)
		sleep_level++
		sleepy_ticks--
	else
		sleep_level = 0

	if(!..())
		return

	switch(A.stage)
		if(1)
			if(prob(10))
				to_chat(M, span_warning("I feel tired."))
		if(2)
			if(prob(10))
				to_chat(M, span_warning("I feel very tired."))
				sleepy_ticks += rand(10,14)
				if(stamina)
					M.adjustStaminaLoss(10)
		if(3)
			if(prob(15))
				to_chat(M, span_warning("I try to focus on staying awake."))
				sleepy_ticks += rand(10,14)
				if(stamina)
					M.adjustStaminaLoss(15)
		if(4)
			if(prob(20))
				to_chat(M, span_warning("I nod off for a moment."))
				sleepy_ticks += rand(10,14)
				if(stamina)
					M.adjustStaminaLoss(20)
		if(5)
			if(prob(25))
				to_chat(M, span_warning("[pick("So tired...","I feel very sleepy.","I have a hard time keeping your eyes open.","I try to stay awake.")]"))
				M.drowsyness = max(M.drowsyness, 2)
				sleepy_ticks += rand(10,14)
				if(stamina)
					M.adjustStaminaLoss(30)




