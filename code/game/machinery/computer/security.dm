//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/secure_data//TODO:SANITY
	name = "Security Records"
	desc = "Used to view and edit personnel's security records."
	icon_state = "security"
	req_one_access = list(access_security, access_forensics_lockers)
	circuit = "/obj/item/weapon/circuitboard/secure_data"
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/secure_data/attackby(obj/item/O as obj, var/mob/living/user)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		if(usr.drop_item(O, src))
			scan = O
			to_chat(user, "You insert \the [O].")
	if (istype(user) && authenticated && (screen == 3.0) && active1)
		if(istype(O, /obj/item/weapon/photo/id))
			var/obj/item/weapon/photo/id/photo_id = O
			if (photo_id.four_sides)
				if (alert("Do you want to update the records with this ID photo?",,"Yes","No") == "Yes")
					if (user && !user.incapacitated() && Adjacent(user) && photo_id && (photo_id == user.get_active_hand()) && authenticated && (screen == 3.0) && active1)
						active1.fields["photo"] = photo_id.four_sides
						visible_message("<span class='notice'>[bicon(src)] Database updated.</span>")
						playsound(src, 'sound/machines/twobeep.ogg', 50, 0)
						updateUsrDialog()
		if(istype(O,/obj/item/device/detective_scanner/forger))
			var/obj/item/device/detective_scanner/forger/F = O
			if(active1.fields["fingerprint"])
				var/list/customprints = list()
				var/print = active1.fields["fingerprint"]
				to_chat(user,"<span class='notice'>You scan the fingerprints from the active record and add them to the custom fingerprints. It will be tied to the next applicable scanned item.</span>")
				customprints[print] = print
				F.custom_forgery[1] = customprints ? customprints.Copy() : null
	..()

/obj/machinery/computer/secure_data/attack_paw(mob/user as mob)
	return attack_hand(user)

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/secure_data/attack_hand(mob/user as mob)
	if(..())
		return
	if (src.z > 6)
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
		return
	var/dat

	if (temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];choice=Clear Screen'>Clear Screen</A>", temp, src)
	else
		dat = text("Confirm Identity: <A href='?src=\ref[];choice=Confirm Identity'>[]</A><HR>", src, (scan ? text("[]", scan.name) : "----------"))
		if (authenticated)
			switch(screen)
				if(1.0)
					dat += {"<meta charset="UTF-8">"}
					dat += {"
<p style='text-align:center;'>"}
					dat += text("<A href='?src=\ref[];choice=Search Records'>Search Records</A><BR>", src)
					dat += text("<A href='?src=\ref[];choice=New Record (General)'>New Record</A><BR>", src)
					dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
<th>Criminal Status</th>
</tr>"}
					if(!isnull(data_core.general))
						for(var/datum/data/record/R in sortRecord(data_core.general, sortBy, order))
							var/crimstat = ""
							for(var/datum/data/record/E in data_core.security)
								if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
									crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*High Threat*")
									background = "'background-color:#696969;'"
								if("*Arrest*")
									background = "'background-color:#DC143C;'"
								if("Incarcerated")
									background = "'background-color:#CD853F;'"
								if("Parolled")
									background = "'background-color:#CD853F;'"
								if("Released")
									background = "'background-color:#3BB9FF;'"
								if("None")
									background = "'background-color:#00FF7F;'"
								if("")
									background = "'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
							dat += text("<td>[]</td></tr>", crimstat)
						dat += "</table><hr width='75%' />"
					dat += text("<A href='?src=\ref[];choice=Record Maintenance'>Record Maintenance</A><br><br>", src)
					dat += text("<A href='?src=\ref[];choice=Log Out'>{Log Out}</A>",src)
				if(2.0)

					dat += {"<B>Records Maintenance</B><HR>
						<BR><A href='?src=\ref[src];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='?src=\ref[src];choice=Return'>Back</A>"}
				if(3.0)
					dat += "<CENTER><B>Security Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						var/icon/front = new(active1.fields["photo"], dir = SOUTH)
						var/icon/side = new(active1.fields["photo"], dir = WEST)
						user << browse_rsc(front, "front.png")
						user << browse_rsc(side, "side.png")
						dat += text("<table><tr><td>	\
						Name: <A href='?src=\ref[src];choice=Edit Field;field=name'>[active1.fields["name"]]</A><BR> \
						ID: <A href='?src=\ref[src];choice=Edit Field;field=id'>[active1.fields["id"]]</A><BR>\n	\
						Sex: <A href='?src=\ref[src];choice=Edit Field;field=sex'>[active1.fields["sex"]]</A><BR>\n	\
						Age: <A href='?src=\ref[src];choice=Edit Field;field=age'>[active1.fields["age"]]</A><BR>\n	\
						Rank: <A href='?src=\ref[src];choice=Edit Field;field=rank'>[active1.fields["rank"]]</A><BR>\n	\
						Fingerprint: <A href='?src=\ref[src];choice=Edit Field;field=fingerprint'>[active1.fields["fingerprint"]]</A><BR>\n	\
						Physical Status: [active1.fields["p_stat"]]<BR>\n	\
						Mental Status: [active1.fields["m_stat"]]<BR></td>	\
						<td align = center valign = top>Photo:<br><img src=front.png height=80 width=80 border=4>	\
						<img src=side.png height=80 width=80 border=4></td></tr></table>")
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						dat += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: <A href='?src=\ref[];choice=Edit Field;field=criminal'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];choice=Edit Field;field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, active2.fields["criminal"], src, active2.fields["notes"])
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							dat += text("[]<BR><A href='?src=\ref[];choice=Delete Entry;del_c=[]'>Delete Entry</A><BR><BR>", active2.fields[text("com_[]", counter)], src, counter)
							counter++
						dat += text("<A href='?src=\ref[];choice=Add Entry'>Add Entry</A><BR><BR>", src)
						dat += text("<A href='?src=\ref[];choice=Delete Record (Security)'>Delete Record (Security Only)</A><BR><BR>", src)
					else
						dat += "<B>Security Record Lost!</B><BR>"
						dat += text("<A href='?src=\ref[];choice=New Record (Security)'>New Security Record</A><BR><BR>", src)
					dat += text("\n<A href='?src=\ref[];choice=Delete Record (ALL)'>Delete Record (ALL)</A><BR><BR>\n<A href='?src=\ref[];choice=Print Record'>Print Record</A><BR>\n<A href='?src=\ref[];choice=Return'>Back</A><BR>", src, src, src)
				if(4.0)
					if(!Perp.len)
						dat += text("ERROR.  String could not be located.<br><br><A href='?src=\ref[];choice=Return'>Back</A>", src)
					else
						dat += {"
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>					"}
						dat += text("<th>Search Results for '[]':</th>", tempname)
						dat += {"
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Name</th>
<th>ID</th>
<th>Rank</th>
<th>Fingerprints</th>
<th>Criminal Status</th>
</tr>					"}
						for(var/i=1, i<=Perp.len, i += 2)
							var/crimstat = ""
							var/datum/data/record/R = Perp[i]
							if(istype(Perp[i+1],/datum/data/record/))
								var/datum/data/record/E = Perp[i+1]
								crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*High Threat*")
									background = "'background-color:#696969;'"
								if("*Arrest*")
									background = "'background-color:#DC143C;'"
								if("Incarcerated")
									background = "'background-color:#CD853F;'"
								if("Parolled")
									background = "'background-color:#CD853F;'"
								if("Released")
									background = "'background-color:#3BB9FF;'"
								if("None")
									background = "'background-color:#00FF7F;'"
								if("")
									background = "'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
							dat += text("<td>[]</td></tr>", crimstat)
						dat += "</table><hr width='75%' />"
						dat += text("<br><A href='?src=\ref[];choice=Return'>Return to index.</A>", src)
				else
		else
			dat += text("<A href='?src=\ref[];choice=Log In'>{Log In}</A>", src)
	user << browse(text("<HEAD><TITLE>Security Records</TITLE></HEAD><TT>[]</TT>", dat), "window=secure_rec;size=600x400")
	onclose(user, "secure_rec")
	return

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
		return
	if (!( data_core.general.Find(active1) ))
		active1 = null
	if (!( data_core.security.Find(active2) ))
		active2 = null
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || isAdminGhost(usr) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		switch(href_list["choice"])
// SORTING!
			if("Sorting")
				// Reverse the order if clicked twice
				if(sortBy == href_list["sort"])
					if(order == 1)
						order = -1
					else
						order = 1
				else
				// New sorting order!
					sortBy = href_list["sort"]
					order = initial(order)
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if ("Return")
				screen = 1
				active1 = null
				active2 = null

			if("Confirm Identity")
				if (scan)
					if(istype(usr,/mob/living/carbon/human) && !usr.get_active_hand())
						usr.put_in_hands(scan)
					else
						scan.forceMove(get_turf(src))
					scan = null
				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/weapon/card/id))
						if(usr.drop_item(I, src))
							scan = I

			if("Log Out")
				authenticated = null
				screen = null
				active1 = null
				active2 = null

			if("Log In")
				if(isAdminGhost(usr))
					active1 = null
					active2 = null
					authenticated = "Commander Green"
					rank = "Central Commander"
					screen = 1
				if (istype(usr, /mob/living/silicon))
					active1 = null
					active2 = null
					authenticated = 1
					rank = "AI"
					screen = 1
				else if (istype(scan, /obj/item/weapon/card/id))
					active1 = null
					active2 = null
					if(check_access(scan))
						authenticated = scan.registered_name
						rank = scan.assignment
						screen = 1
//RECORD FUNCTIONS
			if("Search Records")
				var/t1 = copytext(sanitize(input("Search String: (Partial Name or ID or Fingerprints or Rank)", "Secure. records", null, null)  as text),1,MAX_NAME_LEN)
				if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || !in_range(src, usr)))
					return
				Perp = new/list()
				t1 = lowertext(t1)
				var/list/components = splittext(t1, " ")
				if(components.len > 5)
					return //Lets not let them search too greedily.
				for(var/datum/data/record/R in data_core.general)
					var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["fingerprint"] + " " + R.fields["rank"]
					for(var/i = 1, i<=components.len, i++)
						if(findtext(temptext,components[i]))
							var/prelist = new/list(2)
							prelist[1] = R
							Perp += prelist
				for(var/i = 1, i<=Perp.len, i+=2)
					for(var/datum/data/record/E in data_core.security)
						var/datum/data/record/R = Perp[i]
						if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
							Perp[i+1] = E
				tempname = t1
				screen = 4

			if("Record Maintenance")
				screen = 2
				active1 = null
				active2 = null

			if ("Browse Record")
				var/datum/data/record/R = locate(href_list["d_rec"])
				var/S = locate(href_list["d_rec"])
				if (!( data_core.general.Find(R) ))
					temp = "Record Not Found!"
				else
					for(var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
							S = E
					active1 = R
					active2 = S
					screen = 3

/*			if ("Search Fingerprints")
				var/t1 = copytext(sanitize(input("Search String: (Fingerprint)", "Secure. records", null, null)  as text),1,MAX_NAME_LEN)
				if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || (!in_range(src, usr)) && (!istype(usr, /mob/living/silicon))))
					return
				active1 = null
				active2 = null
				t1 = lowertext(t1)
				for(var/datum/data/record/R in data_core.general)
					if (lowertext(R.fields["fingerprint"]) == t1)
						active1 = R
				if (!( active1 ))
					temp = text("Could not locate record [].", t1)
				else
					for(var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == active1.fields["name"] || E.fields["id"] == active1.fields["id"]))
							active2 = E
					screen = 3	*/

			if ("Print Record")
				if (!( printing ))
					printing = 1
					sleep(50)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( loc )
					P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", active1.fields["name"], active1.fields["id"], active1.fields["sex"], active1.fields["age"], active1.fields["fingerprint"], active1.fields["p_stat"], active1.fields["m_stat"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
					if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						P.info += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", active2.fields["criminal"], active2.fields["notes"])
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", active2.fields[text("com_[]", counter)])
							counter++
					else
						P.info += "<B>Security Record Lost!</B><BR>"
					P.info += "</TT>"
					P.name = "paper - 'Security Record'"
					printing = null
//RECORD DELETE
			if ("Delete All Records")

				temp = {"
					Are you sure you wish to delete all Security records?<br>
					<a href='?src=\ref[src];choice=Purge All Records'>Yes</a><br>
					<a href='?src=\ref[src];choice=Clear Screen'>No</a>"}
			if ("Purge All Records")
				for(var/datum/data/record/R in data_core.security)
					QDEL_NULL(R)
				temp = "All Security records deleted."

			if ("Add Entry")
				if (!( istype(active2, /datum/data/record) ))
					return
				var/a2 = active2
				var/t1 = copytext(sanitize(input("Add Comment:", "Secure. records", null, null)  as message),1,MAX_MESSAGE_LEN)
				if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
					return
				var/counter = 1
				while(active2.fields[text("com_[]", counter)])
					counter++
				active2.fields[text("com_[]", counter)] = text("Made by [] ([]) on [], []<BR>[]", authenticated, rank, "[time2text(world.realtime, "DDD MMM DD")] [worldtime2text(give_seconds = TRUE)]", game_year, t1)

			if ("Delete Record (ALL)")
				if (active1)

					temp = {"<h5>Are you sure you wish to delete the record (ALL)?</h5>
						<a href='?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>
						<a href='?src=\ref[src];choice=Clear Screen'>No</a>"}
			if ("Delete Record (Security)")
				if (active2)

					temp = {"<h5>Are you sure you wish to delete the record (Security Portion Only)?</h5>
						<a href='?src=\ref[src];choice=Delete Record (Security) Execute'>Yes</a><br>
						<a href='?src=\ref[src];choice=Clear Screen'>No</a>"}
			if ("Delete Entry")
				if ((istype(active2, /datum/data/record) && active2.fields[text("com_[]", href_list["del_c"])]))
					active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"
//RECORD CREATE
			if ("New Record (Security)")
				if ((istype(active1, /datum/data/record) && !( istype(active2, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record()
					R.fields["name"] = active1.fields["name"]
					R.fields["id"] = active1.fields["id"]
					R.name = text("Security Record #[]", R.fields["id"])
					R.fields["criminal"] = "None"
					R.fields["notes"] = "No notes."
					data_core.security += R
					active2 = R
					screen = 3

			if ("New Record (General)")
				var/datum/data/record/G = new /datum/data/record()
				G.fields["name"] = "New Record"
				G.fields["id"] = num2hex(rand(1, 1.6777215E7), 6)
				G.fields["rank"] = "Unassigned"
				G.fields["real_rank"] = "Unassigned"
				G.fields["sex"] = "Male"
				G.fields["age"] = "Unknown"
				G.fields["fingerprint"] = "Unknown"
				G.fields["p_stat"] = "Active"
				G.fields["m_stat"] = "Stable"
				G.fields["species"] = "Human"
				data_core.general += G
				active1 = G
				active2 = null

//FIELD FUNCTIONS
			if ("Edit Field")
				var/a1 = active1
				var/a2 = active2
				switch(href_list["field"])
					if("name")
						if (istype(active1, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input name:", "Secure Records", active1.fields["name"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !length(trim(t1)) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon)))) || active1 != a1)
								return
							active1.fields["name"] = t1
					if("id")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input id:", "Secure. records", active1.fields["id"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["id"] = t1
					if("fingerprint")
						if (istype(active1, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["fingerprint"] = t1
					if("sex")
						if (istype(active1, /datum/data/record))
							if (active1.fields["sex"] == "Male")
								active1.fields["sex"] = "Female"
							else
								active1.fields["sex"] = "Male"
					if("age")
						if (istype(active1, /datum/data/record))
							var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["age"] = t1
					if("notes")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please summarize notes:", "Secure Records", active2.fields["notes"], null)  as message),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["notes"] = t1
					if("criminal")
						if (istype(active2, /datum/data/record))

							temp = {"<h5>Criminal Status:</h5>
								<ul>
								<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=highthreat'>*High Threat*</a></li>
								<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=none'>None</a></li>
								<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=arrest'>*Arrest*</a></li>
								<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=incarcerated'>Incarcerated</a></li>
								<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=parolled'>Parolled</a></li>
								<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=released'>Released</a></li>
								</ul>"}
					if("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI" )
						//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
						if ((istype(active1, /datum/data/record) && L.Find(rank)))

							temp = {"<h5>Rank:</h5>
								<ul>"}
							for(var/rank in get_all_jobs())
								temp += "<li><a href='?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
							temp += "</ul>"
						else
							alert(usr, "You do not have the required rank to do this!")
					if("species")
						if (istype(active1, /datum/data/record))
							var/norange = (usr.mutations && usr.mutations.len && (M_TK in usr.mutations))
							var/t1 = copytext(sanitize(input("Please enter race:", "General records", active1.fields["species"], null)  as message),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon)) && !norange) || active1 != a1))
								return
							active1.fields["species"] = t1

//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
				switch(href_list["choice"])
					if ("Change Rank")
						if (active1)
							active1.fields["rank"] = href_list["rank"]
							if(href_list["rank"] in get_all_jobs())
								active1.fields["real_rank"] = href_list["real_rank"]

					if ("Change Criminal Status")
						if (active2)
							switch(href_list["criminal2"])
								if("none")
									active2.fields["criminal"] = "None"
								if("highthreat")
									active2.fields["criminal"] = "*High Threat*"
								if("arrest")
									active2.fields["criminal"] = "*Arrest*"
								if("incarcerated")
									active2.fields["criminal"] = "Incarcerated"
								if("parolled")
									active2.fields["criminal"] = "Parolled"
								if("released")
									active2.fields["criminal"] = "Released"

					if ("Delete Record (Security) Execute")
						if (active2)
							QDEL_NULL(active2)

					if ("Delete Record (ALL) Execute")
						if (active1)
							for(var/datum/data/record/R in data_core.medical)
								if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
									QDEL_NULL(R)
								else
							QDEL_NULL(active1)
						if (active2)
							QDEL_NULL(active2)
					else
						temp = "This function does not appear to be working at the moment. Our apologies."

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/secure_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		..(severity)
		return

	for(var/datum/data/record/R in data_core.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = "[pick(pick(first_names_male), pick(first_names_female))] [pick(last_names)]"
				if(2)
					R.fields["sex"]	= pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*High Threat*", "*Arrest*", "Incarcerated", "Parolled", "Released")
				if(5)
					R.fields["p_stat"] = pick("*Unconcious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			QDEL_NULL(R)
			continue

	..(severity)

/obj/machinery/computer/secure_data/detective_computer
	icon = 'icons/obj/computer.dmi'
	icon_state = "messyfiles"
	moody_state = "overlay_messyfiles"

	light_range_on = 1
	light_color = null
	computer_flags = NO_ONOFF_ANIMS
