/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H

/datum/preferences/proc/randomize_appearance_for(var/mob/living/carbon/human/H)
	if(H)
		if(H.gender == MALE)
			gender = MALE
		else
			gender = FEMALE
	s_tone = random_skin_tone(species)
	h_style = random_hair_style(gender, species)
	f_style = random_facial_hair_style(gender, species)
	randomize_hair_color("hair")
	randomize_hair_color("facial")
	randomize_eyes_color()
	underwear = rand(1,underwear_m.len)
	backbag = 2
	age = rand(AGE_MIN,AGE_MAX)
	if(H)
		copy_to(H,1)


/datum/preferences/proc/randomize_hair_color(var/target = "hair")
	if(species == "Vox")
		r_hair = rand(1,7)
	if(prob (75) && target == "facial") // Chance to inherit hair color
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		return

	var/red
	var/green
	var/blue

	var/col = pick("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", 15;"punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand(0, 255)
			green = rand(0, 255)
			blue = rand(0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	switch(target)
		if("hair")
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue

/datum/preferences/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	r_eyes = red
	g_eyes = green
	b_eyes = blue

/datum/preferences/proc/blend_backpack(var/icon/clothes_s,var/backbag,var/satchel,var/backpack="backpack",var/messenger_bag)
	switch(backbag)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', backpack), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', satchel), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
		if(5)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', messenger_bag), ICON_OVERLAY)
	return clothes_s

/proc/valid_sprite_accessories(var/from_list, var/gender_restriction, var/species_restriction, var/flag_restriction)
	. = list()
	for(var/key in from_list)
		var/datum/sprite_accessory/S = from_list[key]
		if(species_restriction && !(species_restriction in S.species_allowed))
			continue
		if(flag_restriction && (S.flags & flag_restriction))
			continue
		if(gender_restriction)
			if(gender_restriction == MALE && S.gender == FEMALE)
				continue
			if(gender_restriction == FEMALE && S.gender == MALE)
				continue

		.[key] = from_list[key]

/datum/preferences/proc/update_preview_icon(var/for_observer=0)		//seriously. This is horrendous.
	preview_icon_front = null
	preview_icon_side = null
	preview_icon = null

	var/g = "m"
	if(gender == FEMALE)
		g = "f"

	var/icon/icobase
	var/datum/species/current_species = all_species[species]

	//icon based species color
	if(current_species)
		if(current_species.name == "Vox")
			switch(s_tone)
				if(VOXEMERALD)
					icobase = 'icons/mob/human_races/vox/r_voxemrl.dmi'
				if(VOXAZURE)
					icobase = 'icons/mob/human_races/vox/r_voxazu.dmi'
				if(VOXLGREEN)
					icobase = 'icons/mob/human_races/vox/r_voxlgrn.dmi'
				if(VOXGRAY)
					icobase = 'icons/mob/human_races/vox/r_voxgry.dmi'
				if(VOXBROWN)
					icobase = 'icons/mob/human_races/vox/r_voxbrn.dmi'
				else
					icobase = 'icons/mob/human_races/vox/r_vox.dmi'
		else if(current_species.name == "Grey")
			switch(s_tone)
				if(GREYBLUE)
					icobase = 'icons/mob/human_races/grey/r_greyblue.dmi'
				if(GREYGREEN)
					icobase = 'icons/mob/human_races/grey/r_greygreen.dmi'
				if(GREYLIGHT)
					icobase = 'icons/mob/human_races/grey/r_greylight.dmi'
				else
					icobase = 'icons/mob/human_races/grey/r_grey.dmi'
		else
			icobase = current_species.icobase
	else
		icobase = 'icons/mob/human_races/r_human.dmi'

	var/fat=""
	if(disabilities&DISABILITY_FLAG_FAT && current_species.anatomy_flags & CAN_BE_FAT)
		fat="_fat"

	preview_icon = new /icon(icobase, "torso_[g][fat]")
	preview_icon.Blend(new /icon(icobase, "groin_[g]"), ICON_OVERLAY)
	preview_icon.Blend(new /icon(icobase, "head_[g]"), ICON_OVERLAY)

	var/list/limbies = list(LIMB_LEFT_ARM,LIMB_RIGHT_ARM,LIMB_LEFT_LEG,LIMB_RIGHT_LEG,LIMB_LEFT_FOOT,LIMB_RIGHT_FOOT,LIMB_LEFT_HAND,LIMB_RIGHT_HAND)
	for(var/name in limbies)
		// make sure the organ is added to the list so it's drawn
		if(organ_data[name] == null)
			organ_data[name] = null

	for(var/name in organ_data)
		if(!(name in limbies)) // will try to overlay internal organs otherwise, leading to fucky behavior.
			continue
		if(organ_data[name] == "amputated")
			continue

		var/o_icobase=icobase
		if(organ_data[name] == "peg")
			o_icobase='icons/mob/human_races/o_peg.dmi'
		else if(organ_data[name] == "cyborg")
			o_icobase='icons/mob/human_races/o_robot.dmi'

		var/icon/temp = new /icon(o_icobase, "[name]")

		preview_icon.Blend(temp, ICON_OVERLAY)
	//Tail
	if(current_species && (current_species.anatomy_flags & HAS_TAIL))
		var/tail_icon_state = current_species.tail
		if(current_species.name == "Vox")
			switch(s_tone)
				if(VOXEMERALD)
					tail_icon_state = "emerald"
				if(VOXAZURE)
					tail_icon_state = "azure"
				if(VOXLGREEN)
					tail_icon_state = "lightgreen"
				if(VOXGRAY)
					tail_icon_state = "grey"
				if(VOXBROWN)
					tail_icon_state = "brown"
				else
					tail_icon_state = "green"
		if(current_species.name == "Tajaran")
			switch(s_tone)
				if(CATBEASTBLACK)
					tail_icon_state = "tajaran_black"
				else
					tail_icon_state = "tajaran_brown"
		var/icon/temp_tail_icon = icon(current_species.tail_icon, "[tail_icon_state]_BEHIND")
		preview_icon.Blend(temp_tail_icon, ICON_UNDERLAY)
	// Skin tone
	if(current_species && (current_species.anatomy_flags & HAS_SKIN_TONE))
		if (s_tone >= 0)
			preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
	if(current_species && (current_species.anatomy_flags & RGBSKINTONE))
		preview_icon.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

	var/icon/eyes_s = new/icon("icon" = 'icons/mob/hair_styles.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
	eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

	var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
	if(species == "Vox")
		if(hair_style)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_[r_hair]_s")
			if(hair_style.additional_accessories)
				hair_s.Blend(icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_[r_hair]_acc"), ICON_OVERLAY)
			eyes_s.Blend(hair_s, ICON_OVERLAY)
	else if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		if(hair_style.do_colouration)
			hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
		if(hair_style.additional_accessories)
			hair_s.Blend(icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_acc"), ICON_OVERLAY)
		eyes_s.Blend(hair_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
	if(facial_hair_style)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/clothes_s = null

	var/uniform_dmi
	var/suit_dmi
	var/feet_dmi
	// UNIFORM DMI
	if(current_species)
		uniform_dmi=current_species.uniform_icons
		if(disabilities&DISABILITY_FLAG_FAT && current_species.fat_uniform_icons)
			uniform_dmi=current_species.fat_uniform_icons

	// SUIT DMI
	if(current_species)
		suit_dmi=current_species.wear_suit_icons
		if(disabilities&DISABILITY_FLAG_FAT && current_species.fat_wear_suit_icons)
			suit_dmi=current_species.fat_wear_suit_icons


	// SHOES DMI
		feet_dmi=current_species.shoes_icons

	if(!for_observer)
		// Commenting this check so that, if all else fails, the preview icon is never naked. - N3X
		//if(job_civilian_low & ASSISTANT) //This gives the preview icon clothes depending on which job(if any) is set to 'high'
		clothes_s = new /icon(uniform_dmi, "grey_s")
		clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
		clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")

		var/highest_pref = 0
		var/highest_job = "Assistant"
		for(var/job in jobs)
			if(jobs[job] > highest_pref)
				highest_pref = jobs[job]
				highest_job = job

		var/datum/job/highest_job_datum = job_master.GetJob(highest_job)
		if(!highest_job_datum) //Fixes a bug where players with a high preference in a job that wasn't in the round couldn't access Setup Character.
		else switch(highest_job_datum.type)
			if(/datum/job/hop)
				clothes_s = new /icon(uniform_dmi, "hop_s")
				clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "HoP_Coat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hopcap"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/bartender)
				clothes_s = new /icon(uniform_dmi, "ba_suit_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "armor"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/hydro)
				clothes_s = new /icon(uniform_dmi, "hydroponics_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "ggloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "apron"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-hyd",null,"courierbaghyd")
			if(/datum/job/chef)
				clothes_s = new /icon(uniform_dmi, "chef_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "chef"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/janitor)
				clothes_s = new /icon(uniform_dmi, "janitor_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/librarian)
				clothes_s = new /icon(uniform_dmi, "red_suit_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/qm)
				clothes_s = new /icon(uniform_dmi, "qm_s")
				clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/right/items_righthand.dmi', "clipboard"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/cargo_tech)
				clothes_s = new /icon(uniform_dmi, "cargotech_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "black"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/mining)
				clothes_s = new /icon(uniform_dmi, "miner_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "black"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-eng",null,"courierbagengi")
			if(/datum/job/lawyer)
				clothes_s = new /icon(uniform_dmi, "internalaffairs_s")
				clothes_s.Blend(new /icon(feet_dmi, "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "ia_jacket_open"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/right/backpacks_n_bags.dmi', "briefcase-centcomm"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/chaplain)
				clothes_s = new /icon(uniform_dmi, "chapblack_s")
				clothes_s.Blend(new /icon(feet_dmi, "laceups"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/clown)
				clothes_s = new /icon(uniform_dmi, "clown_s")
				clothes_s.Blend(new /icon(feet_dmi, "clown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "clown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "clownpack"), ICON_OVERLAY)
			if(/datum/job/mime)
				clothes_s = new /icon(uniform_dmi, "mime_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "mime"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret"), ICON_OVERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "suspenders"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/rd)
				clothes_s = new /icon(uniform_dmi, "director_s")
				clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/right/items_righthand.dmi', "clipboard"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-tox",null,"courierbagtox")
			if(/datum/job/scientist)
				clothes_s = new /icon(uniform_dmi, "toxinswhite_s")
				clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_tox_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-tox",null,"courierbagtox")
			if(/datum/job/xenoarchaeologist)
				clothes_s = new /icon('icons/mob/uniform.dmi', "xenoarch_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-tox",null,"courierbagtox")
			if(/datum/job/xenobiologist)
				clothes_s = new /icon('icons/mob/uniform.dmi', "xenobio_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
			if(/datum/job/chemist)
				clothes_s = new /icon(uniform_dmi, "chemistrywhite_s")
				clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_chem_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-chem",null,"courierbagchem")
			if(/datum/job/cmo)
				clothes_s = new /icon(uniform_dmi, "cmo_s")
				clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/left/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_cmo_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-med",null,"courierbagmed")
			if(/datum/job/doctor)
				clothes_s = new /icon(uniform_dmi, "medical_s")
				clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/left/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-med","medicalpack","courierbagmed")
			if(/datum/job/paramedic)
				clothes_s = new /icon(uniform_dmi, "paramedic_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "paramedicsoft"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/left/firstaid-kits.dmi', "firstaid-internalbleed"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "paramedic-vest"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-med","medicalpack","courierbagmed")
			if(/datum/job/orderly)
				clothes_s = new /icon(uniform_dmi, "orderly_s")
				clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/left/backpacks_n_bags.dmi', "medbriefcase"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-med","medicalpack","courierbagmed")
			if(/datum/job/geneticist)
				clothes_s = new /icon(uniform_dmi, "geneticswhite_s")
				clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_gen_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-gen",null,"courierbagmed")
			if(/datum/job/virologist)
				clothes_s = new /icon(uniform_dmi, "virologywhite_s")
				clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "sterile"), ICON_OVERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_vir_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-vir","medicalpack","courierbagmed")
			if(/datum/job/roboticist)
				clothes_s = new /icon(uniform_dmi, "robotics_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/right/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/captain)
				clothes_s = new /icon(uniform_dmi, "captain_s")
				clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "captain"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "caparmor"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-cap",null,"courierbagcom")
			if(/datum/job/hos)
				clothes_s = new /icon(uniform_dmi, "hosred_s")
				clothes_s.Blend(new /icon(feet_dmi, "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret_badge"), ICON_OVERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "armor"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-sec","securitypack","courierbagsec")
			if(/datum/job/warden)
				clothes_s = new /icon(uniform_dmi, "warden_s")
				clothes_s.Blend(new /icon(feet_dmi, "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "policehelm"), ICON_OVERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "armor"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-sec","securitypack","courierbagsec")
			if(/datum/job/detective)
				clothes_s = new /icon(uniform_dmi, "detective_s")
				clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "detective"), ICON_OVERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "detective"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/officer)
				clothes_s = new /icon(uniform_dmi, "security_s")
				clothes_s.Blend(new /icon(feet_dmi, "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "armor"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-sec","securitypack","courierbagsec")
			if(/datum/job/chief_engineer)
				clothes_s = new /icon(uniform_dmi, "chief_s")
				clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "yellow"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_white"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-eng","engiepack","courierbagengi")
			if(/datum/job/engineer)
				clothes_s = new /icon(uniform_dmi, "engine_s")
				clothes_s.Blend(new /icon(feet_dmi, "orange"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-eng","engiepack","courierbagengi")
			if(/datum/job/atmos)
				clothes_s = new /icon(uniform_dmi, "atmos_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "yellow"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbagengi")
			if(/datum/job/mechanic)
				clothes_s = new /icon(uniform_dmi, "mechanic_s")
				clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "yellow"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-eng","engiepack","courierbagengi")
			if(/datum/job/roboticist)
				clothes_s = new /icon(uniform_dmi, "robotics_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/in-hand/right/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
				clothes_s.Blend(new /icon(suit_dmi, "labcoat_open"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/trader)
				clothes_s = new /icon(uniform_dmi, "trader-outfit_s")
				clothes_s.Blend(new /icon(feet_dmi, "trader-boots"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "walkietalkie"), ICON_OVERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/ai)//Gives AI and borgs assistant-wear, so they can still customize their character
				clothes_s = new /icon(uniform_dmi, "grey_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
			if(/datum/job/cyborg)
				clothes_s = new /icon(uniform_dmi, "grey_s")
				clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
				clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")

		preview_icon.Blend(new /icon('icons/mob/previewbg.dmi',preview_background), ICON_UNDERLAY)

	// Observers get a tourist or vacationer outfit.
	else
		if (prob(100/3))
			clothes_s = new /icon(uniform_dmi, "tourist_s")
			clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing_accessories.dmi', "wristwatch"), ICON_UNDERLAY)
			clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm",null,"courierbag")
		else
			clothes_s = new /icon(uniform_dmi, "vacationer_[rand(1,3)]_s")
			clothes_s.Blend(new /icon(feet_dmi, "vacationer"), ICON_UNDERLAY)
			if (prob(50))
				var/drink_icon = pick('icons/mob/in-hand/right/drinkingglass.dmi', 'icons/mob/in-hand/left/drinkingglass.dmi')
				var/drink_icon_state = pick("coffee", "cafe_latte", "beer", "alebottle", "gargleblasterglass", "energy_drink", "sangria", "gintonicglass")
				clothes_s.Blend(new /icon(drink_icon, drink_icon_state), ICON_OVERLAY)

	if(disabilities & NEARSIGHTED)
		preview_icon.Blend(new /icon('icons/mob/eyes.dmi', "glasses"), ICON_OVERLAY)

	preview_icon.Blend(eyes_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	eyes_s = null
	clothes_s = null
