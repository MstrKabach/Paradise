/datum/antagonist/wandering_contractor
	name = "Wandering Contractor"
	job_rank = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	antag_hud_type = ANTAG_HUD_TRAITOR
	show_in_orbit = FALSE

/datum/antagonist/wandering_contractor/Destroy(force)
	contractor_uplink.hub?.owner = null
	contractor_uplink.hub?.contractor_uplink = null

	return ..()


/datum/antagonist/wandering_contractor/add_antag_hud(mob/living/antag_mob)
	antag_hud_name = "hudcontractor"
	return ..()

/datum/antagonist/wandering_contractor/finalize_antag()

	// Setup the vars and contractor stuff in the uplink
	var/datum/antagonist/traitor/traitor_datum = owner?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor_datum)
		return

	var/obj/item/uplink/hidden/hidden_uplink = traitor_datum.hidden_uplink
	if(!hidden_uplink)
		stack_trace("Potential contractor [owner] spawned without a hidden uplink!")
		return

	hidden_uplink.contractor = src
	offer_deadline = world.time + offer_duration


/datum/antagonist/wandering_contractor/greet()
	var/list/messages = list()
	var/greet_text = "Contractors forfeit [tc_cost] telecrystals for the privilege of taking on kidnapping contracts for credit and TC payouts that can add up to more than the normal starting amount of TC.<br>"\
	 + "If you are interested, simply access your hidden uplink and select the \"Contracting Opportunity\" tab for more information.<br>"
	messages.Add("<b><font size=4 color=red>You have been offered a chance to become a Contractor.</font></b><br>")
	messages.Add("<font color=red>[greet_text]</font>")
	if(!is_admin_forced)
		messages.Add("<b><i><font color=red>Hurry up. You are not the only one who received this offer. Their number is limited. \
        			If other traitors accept all offers before you, you will not be able to accept one of them.</font></i></b>")
	messages.Add("<b><i><font color=red>This offer will expire in 10 minutes starting now (expiry time: <u>[station_time_timestamp(time = offer_deadline)]</u>).</font></i></b>")
	return messages

/datum/antagonist/wandering_contractor/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Увы, но вы стали Роботом. Теперь вы не расскажите никому о ваших похождениях!"))
	else
		to_chat(owner.current, span_userdanger("Вам промыло мозги. Контрактник из вас теперь никакой!"))


/datum/antagonist/wandering_contractor/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction = list(ROLE_TRAITOR)

/datum/antagonist/wandering_contractor/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction = list("Station")
	if(user.hud_used)
		user.hud_used.remove_ninja_hud()


/datum/antagonist/wandering_contractor/finalize_antag()
	INVOKE_ASYNC(src, PROC_REF(name_ninja))
	if(give_equip)
		equip_contractor()

/**
 * All the equipment for wandering contractor.
 */
/datum/antagonist/wandering_contractor/proc/equip_contractor()
	if(!istype(human_ninja))
		stack_trace("Trying to equip non-human mob with ninja antag datum")

	for(var/obj/item/item in (human_ninja.contents - (human_ninja.bodyparts|human_ninja.internal_organs)))
		human_ninja.drop_item_ground(item, force = TRUE, silent = TRUE)

	human_wandering_contractor.equip_to_slot(new /obj/item/clothing/under/ninja, ITEM_SLOT_CLOTH_INNER, initial = TRUE)
	human_wandering_contractor.equip_to_slot(new /obj/item/clothing/glasses/ninja, ITEM_SLOT_EYES, initial = TRUE)
	human_wandering_contractor.equip_to_slot(new /obj/item/clothing/mask/gas/space_ninja, ITEM_SLOT_MASK, initial = TRUE)
	human_wandering_contractor.equip_to_slot(new /obj/item/clothing/shoes/space_ninja, ITEM_SLOT_FEET, initial = TRUE)
	human_wandering_contractor.equip_to_slot(new /obj/item/clothing/gloves/space_ninja, ITEM_SLOT_GLOVES, initial = TRUE)
	human_wandering_contractor.equip_to_slot(new /obj/item/clothing/head/helmet/space/space_ninja, ITEM_SLOT_HEAD, initial = TRUE)
	human_wandering_contractor.equip_to_slot(new /obj/item/tank/internals/emergency_oxygen/ninja, ITEM_SLOT_POCKET_RIGHT, initial = TRUE)

	var/obj/item/storage/backpack/ninja/my_backpack = new
	human_ninja.equip_to_slot(my_backpack, ITEM_SLOT_BACK, initial = TRUE)

	var/obj/item/radio/headset/ninja/my_headset = new
	human_ninja.equip_to_slot(my_headset, ITEM_SLOT_EAR_RIGHT, initial = TRUE)

	my_katana = new
	human_ninja.equip_to_slot(my_katana, ITEM_SLOT_BELT, initial = TRUE)

	my_suit = new
	human_ninja.equip_to_slot(my_suit, ITEM_SLOT_CLOTH_OUTER, initial = TRUE)
	my_suit.preferred_clothes_gender = human_ninja.gender
	my_suit.n_headset = my_headset
	my_suit.n_backpack = my_backpack
	my_suit.energyKatana = my_katana
	cell = my_suit.cell
