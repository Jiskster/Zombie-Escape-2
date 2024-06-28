local tutorialMap = 964 --G_FindMapByNameOrCode("MAPY0")
local startDialouge;

-- freeslot("MT_GROUNDRUBY")
-- mobjinfo[MT_GROUNDRUBY] = {
-- 	--$Name Ruby
-- 	--$Sprite RBY1A0
-- 	--$Category Rings and Weapon Panels
-- 	doomednum = 864,
-- 	spawnstate = S_CRRUBY,
-- 	deathstate = S_SPRK1,
-- 	radius = 25*FU,
-- 	height = 45*FU,
-- 	flags = MF_NOGRAVITY | MF_SPECIAL
-- }
-- addHook("TouchSpecial", function(special, toucher)
-- 	if toucher and toucher.valid and toucher.player then
-- 		local team = toucher.player["ze2_info"].team
		
-- 		if team == 2 then
-- 			return true
-- 		end
		
-- 		if toucher.player["ze2_info"].rubies + 1 > toucher.player["ze2_info"].rubycap then
-- 			return true
-- 		elseif toucher.player["ze2_info"].rubypickupdelay then
-- 			return true
-- 		end

-- 		if not toucher.player["ze2_info"].rubyqueue then
-- 			S_StartSound(toucher, sfx_rbyhit)
-- 		end

-- 		ZE2:QueuePlayerRubies(toucher.player, 1)

-- 		special.color = SKINCOLOR_RED
-- 		special.colorized = true
-- 	end
-- end, MT_GROUNDRUBY)

--DEBUG
-- local cool = 0
-- addHook("ThinkFrame", function ()
--     if gamemap ~= tutorialMap then
--         if cool then
--             cool = $ - 1
--         else
--             COM_BufInsertText(server, "map y0 -gametype 8 -f")
--             cool = 5
--         end
--     end
-- end)
--DEBUG END

local TutorialTimerTeleporter = ZE2:AddTimer("Teleporter",{
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x8A".."Teleporter is repaired!")
		for line in lines.tagged(3) do
			for rover in line.frontsector.ffloors() do
				rover.flags = $ | FOF_RENDERSIDES
			end
		end
	end,
	extrainfo = {color = SKINCOLOR_CERULEAN}
})

local TutorialTimerWall = ZE2:AddTimer("Crystal Wall",{
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x89".."The Crystal Wall has broken!")
		for sector in sectors.tagged(13) do
			for rover in sector.ffloors() do
				if rover.sector.tag == 2003 then
					EV_CrumbleChain(rover)
				end
			end
		end
	end,
	extrainfo = {color = SKINCOLOR_VAPOR}
})

local RINGTIME = 30

local TutorialTimerRing = ZE2:AddTimer("Ring",{
	time = RINGTIME*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x8D".."The Ring has arrived!")
	end,
	extrainfo = {color = SKINCOLOR_GOLD}
})

local EFFECTDURATION = 21
local function fancyZap(sector)
	local fac = ease.inoutsine((leveltime % 20) * FU / 20)
	if leveltime % 2 then
		fac = FU - $
	end
	for i=0,3 do
		local line = sector.lines[i]
		local mo = P_SpawnMobj(
			line.v1.x + FixedMul(fac, line.dx),
			line.v1.y + FixedMul(fac, line.dy),
			sector.floorheight - 15*FU,
			MT_THOK
		)
		mo.sprite = SPR_WZAP
		mo.frame = 0
		mo.tics = EFFECTDURATION
		mo.fuse = EFFECTDURATION
		mo.momz = 3*FU
		mo.rollangle = ANG1 * P_RandomRange(-180, 179)
	end
end

addHook("ThinkFrame", function ()
	if gamemap ~= tutorialMap then return end
	if TutorialTimerTeleporter.time > EFFECTDURATION/2 and TutorialTimerTeleporter.active then
		for line in lines.tagged(3) do
			fancyZap(line.frontsector)
		end
	end
end)


addHook("LinedefExecute", function (line, mo)
	if TutorialTimerTeleporter.time > 0 then
		if not TutorialTimerTeleporter.active then
			chatprint("Teleporter will be repaired in\x82 " .. tostring(TutorialTimerTeleporter.time/TICRATE) .. " \x80seconds")
			TutorialTimerTeleporter.active = true
		end
		if mo.player and mo.player.valid then
			local p = mo.player
			if not p.tutDialougeProgress["teleporter"] then
				p.tutDialougeProgress["teleporter"] = true
				if p["ze2_info"].team == 2 then
					local s = TutorialTimerTeleporter.time/TICRATE - 2
					local text
					if s >= 2 then
						text = "This teleporter is broken. It will be\nrepaired in " .. tostring(s) .. " seconds."
					elseif s < 1 then
						text = "This teleporter is broken. It will be\nrepaired roughly right now."
					else
						text = "This teleporter is broken. It will be\nrepaired in 1 second."
					end
					startDialouge(p, {
						icon = "STARORB",
						height = 3,
						name = "Teleporter",
					 -- text cutoff for starorb is riiiiiiiiiiight here v     v
						text = text
					})
				else
					local next = {
						text = "Can you fix it?"
					}
					local text = "This teleporter has been broken\never since Takis came through."
					if mo.skin == "tails" then
						-- text cutoff is riiiiiiiiiiiiiiiiiight here v
						next.text = "You're good at fixing things, right?"
					elseif mo.skin == "fang" then
						-- text cutoff is riiiiiiiiiiiiiiiiiight here v
						next.text = "Do you have any spare parts on you?"
					elseif mo.skin == "metalsonic" then
						-- text cutoff is riiiiiiiiiiiiiiiiiight here v
						next.text = "Did\x85 Eggman\x80 teach you anything about\nfixing machines?"
					elseif mo.skin == "takisthefox" then
						text = "This teleporter has been broken\never since you came through."
						next.icon = "AMYRCONC"
						-- text cutoff is riiiiiiiiiiiiiiiiiight here v
						next.text = "Do you have anything to say\nfor yourself?"
						next.next = {
							icon = "TAKISTALKIS",
							name = "TAKIS",
							text = "Of course!\nIT'S HAPPY HOUR!",
							next = {
								icon = "AMYRCONC",
								text = "..."
							}
						}
					elseif mo.skin == "00" then
						-- text cutoff is riiiiiiiiiiiiiiiiiight here v
						next.text = "Hey, why do you even\nneed a teleporter?"
					end
					startDialouge(p, {
						icon = "AMYRCONC",
					-- text cutoff is riiiiiiiiiiiiiiiiiight here v
						text = text,
						next = next
					})
				end
			end
		end
	else
		P_LinedefExecute(2002, mo)
	end
end, "TUTTEL1")

addHook("LinedefExecute", function (line, mo)
	if TutorialTimerWall.time > 0 and not TutorialTimerWall.active then
		chatprint("The\x89 Crystal Wall\x80 will be broken in\x82 " .. tostring(TutorialTimerWall.time/TICRATE) .. " \x80seconds")
		TutorialTimerWall.active = true
	end
	if mo.player and mo.player.valid then
		local p = mo.player
		if TutorialTimerWall.time > 0 and not p.tutDialougeProgress["wall"] then
			p.tutDialougeProgress["wall"] = true
			if p["ze2_info"].team == 2 then
				startDialouge(p, {
					icon = "STARORB",
					height = 3,
					name = "Crystal Wall",
				 -- text cutoff for starorb is riiiiiiiiiiight here v     v
					text = "This wall was put here to slow down\nthe\x84 Survivors\x80.\nDon't tell them."
				})
			else
				local next = {
				-- text cutoff is riiiiiiiiiiiiiiiiiight here v
					text = "Looks like it's on a timer to break."
				}
				if mo.skin == "sonic" then
					-- text cutoff is riiiiiiiiiiiiiiiiiight here v
					next.text = "Your spindash won't be strong\nenough to break this."
				elseif mo.skin == "knuckles" then
					-- text cutoff is riiiiiiiiiiiiiiiiiight here v
					next.text = "As fancy as those gloves are,\nthey won't help with this wall."
				elseif mo.skin == "amy" then
					-- text cutoff is riiiiiiiiiiiiiiiiiight here v
					next.text = "Your hammer is no match\nfor this wall."
				elseif mo.skin == "takisthefox" then
					next.icon = "AMYRCONC"
					-- text cutoff is riiiiiiiiiiiiiiiiiight here v
					next.text = "Well, now you can make up for\nbreaking the teleporter."
				elseif mo.skin == "zzombie" then
					next = nil
				end
				startDialouge(p, {
					icon = "AMYRCONC",
					text = "Why is there even a wall here?",
					next = next
				})
			end
		end
	end
end, "TUTWALL")

addHook("LinedefExecute", function (line, mo)
	if TutorialTimerRing.time > 0 and not TutorialTimerRing.active then
		chatprint("The\x8D Ring\x80 will arrive in\x82 " .. tostring(TutorialTimerRing.time/TICRATE) .. " \x80seconds")
		TutorialTimerRing.active = true
		for p in players.iterate do
			if p["ze2_info"].team == 2 then
				startDialouge(p, {
					icon = "STARORB",
					height = 3,
					name = "Goal Ring",
				 -- text cutoff for starorb is riiiiiiiiiiight here v     v
					text = "The\x8D Ring\x80 has been called. Touch it\nonce it lands to win."
				})
			else
				if p == mo.player then
					startDialouge(p, {
						icon = "AMYRJOYS",
						text = "Nice!",
						next = {
						 -- text cutoff is riiiiiiiiiiiiiiiiiight here v
							text = "Grab the\x8D Ring\x80 once it lands to win!"
						}
					})
				else
					startDialouge(p, {
					 -- text cutoff is riiiiiiiiiiiiiiiiiight here v
						text = "Grab the\x8D Ring\x80 once it lands to win!"
					})
				end
			end
		end
	end
end, "TUTRING")

addHook("LinedefExecute", function (line, mo)
	if mo.player and mo.player.valid then
		local p = mo.player
		if TutorialTimerRing.time > 0 and not TutorialTimerRing.active and not p.tutDialougeProgress["ringroom"] then
			if p["ze2_info"].team == 2 then
				startDialouge(p, {
					icon = "STARORB",
					height = 3,
					name = "Goal Ring",
				 -- text cutoff for starorb is riiiiiiiiiiight here v     v
					text = "Stand in the beam to call the\x8D Ring\x80."
				})
			else
				startDialouge(p, {
					text = "Stand in the beam to call the\x8D Ring!"
				})
			end
			p.tutDialougeProgress["ringroom"] = true
		end
	end
end, "TUTRNGRM")

addHook("MobjThinker", function (mo)
	if gamemap ~= tutorialMap then return end
	if TutorialTimerRing.active then
		mo.momy = -672*FU/(RINGTIME*TICRATE)
		if TutorialTimerRing.time < 26 then
			mo.flags = $ & ~(MF_NOGRAVITY | MF_NOCLIPHEIGHT)
		end
		if TutorialTimerRing.time == 1 then
			S_StartSound(mo, sfx_tink)
		end
	else
		mo.momy = 0
		mo.momz = 0
		if TutorialTimerRing.time > 0 then
			mo.scale = FU
			mo.color = SKINCOLOR_JET
			mo.flags = $ & ~MF_SPECIAL
		else
			mo.scale = (3*$/4) + FU*1
			mo.color = SKINCOLOR_BLUE
			mo.flags = $ | MF_SPECIAL
		end
	end
end, MT_CRRING)

addHook("MobjLineCollide", function(mo, line)
	if gamemap ~= tutorialMap then return end
	return false
end, MT_CRRING)

--[[@param thing mapthing_t]]
addHook("MapThingSpawn", function (mo, thing)
	if gamemap ~= tutorialMap then return end
	if thing.stringargs[0] == "arrow" then
		local left = P_SpawnMobjFromMobj(mo, 0, 0, FU*64, MT_TUTORIALLEAF)
		left.eflags = $ | MFE_VERTICALFLIP
		local right = P_SpawnMobjFromMobj(mo, 0, 0, FU*64, MT_TUTORIALLEAF)
		right.eflags = $ | MFE_VERTICALFLIP
		right.angle = $ + ANGLE_180
	end
end)

addHook("MobjSpawn", function (mo)
	if gamemap ~= tutorialMap then return end
	mo.colorized = true
	mo.color = SKINCOLOR_BLUE
end, MT_ROCKCRUMBLE9)


-----------------------
-- TUTORIAL DIALOUGE --
-----------------------

-- local currentPrompt = {
--     icon = "AMYRTALK",
--     name = "AYMEE ROSS",
--     text = "hi\nmom\nlol",
--     height = 4
-- }

local function F_TextPromptDrawer(vv, prompt)
	--[[@type videolib]]
	local v = vv
	-- local prompt = currentPrompt

	local boxHeight = (13 * prompt.height)

	-- background
	v.drawStretched(
		160*FU, (200 - boxHeight)*FU,
		FU*v.width(), FU*v.height(),
		v.cachePatch("TUT_BLACKBG"),
		V_30TRANS|V_SNAPTOBOTTOM
	)

	-- icon
	if (prompt.icon) then
		local patch = v.cachePatch(prompt.icon)
		local scale = FixedDiv((boxHeight-8), patch.height);
		local iconx = 4*FU;
		local icony = (200-(boxHeight-4))*FU;

		v.drawScaled(
			iconx, icony,
			scale,
			patch,
			V_SNAPTOBOTTOM
		)
	end

	v.drawString(
		4 + 12*prompt.height, (200-(boxHeight-4)),
		prompt.name,
		V_YELLOWMAP|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE
	)
	v.drawString(
		4 + 12*prompt.height, (200-(boxHeight-4)+12),
		string.sub(prompt.text, 1, prompt.textprogress),
		V_SNAPTOBOTTOM|V_ALLOWLOWERCASE
	)
end

startDialouge = function (p, prompt)
	p.tutCurrentPrompt = {
		icon = prompt.icon or "AMYRTALK",
		name = prompt.name or "AMY ROSE",
		text = prompt.text or "hi\nmom\nlol",
		height = prompt.height or 4,
		next = prompt.next,
		textprogress = 1,
		textprogbeat = 0
	}
end

local function isInvisChar(char)
	local byte = string.byte(char, 1, 1)
	if not byte then
		return false
	end
	if byte >= 0x80 and byte <= 0x8F then
		return true
	end
	return false
end

local angleFailTexts = {     -- w/o codes |     | with codes
	"You need to look at\x89 Brick\x80, NAME.",
	"Keep your focus on\x89 Brick\x80, NAME.",
	"I need you to keep your eyes\non\x89 Brick\x80, NAME.",
	"Please keep your attention\non\x89 Brick\x80, NAME."
}

addHook("PlayerThink", function (p)
	if gamemap ~= tutorialMap then
		if p.tutCurrentPrompt then
			p.tutCurrentPrompt = nil
		end
		return
	end

	if not p.tutDialougeProgress then
		p.tutDialougeProgress = {}
	end

	if p["ze2_info"] and p.mo and p.mo.health > 0 and leveltime > 0 and not p["ze2_info"].pregamemenu_active and not p.spectator then
		if p["ze2_info"].team == 1 and not p.tutDialougeProgress["greeting"] then
			startDialouge(p, {
			 -- text cutoff is riiiiiiiiiiiiiiiiiight here v     v
				text = ("Welcome to the tutorial!\n"
					.. "To continue, make your way up to\n"
					.. "the teleporter.")
			})
			p.tutDialougeProgress["greeting"] = true
		end
		if p["ze2_info"].team == 2 and not p.tutDialougeProgress["Zgreeting"] then
			startDialouge(p, {                    -- cuttof v
				-- icon = "AMYRCONC",
				icon = "STARORB",
				height = 3,
				name = "Infected!",
			 -- text cutoff for starorb is riiiiiiiiiiight here v     v
				text = ("You've been\x83 infected\x80. Infect the other\nsurvivors to win.")
			})
			p.tutDialougeProgress["Zgreeting"] = true
		end
	end

	if p.tutCurrentPrompt and leveltime > 1 then
		local prompt = p.tutCurrentPrompt
		prompt.textprogbeat = $ + 1
		if prompt.textprogress >= #(prompt.text) then
			if prompt.textprogbeat > (prompt.next and TICRATE*2 or TICRATE*3) then
				if prompt.next then
					startDialouge(p, prompt.next)
				else
					p.tutCurrentPrompt = nil
					p["ze2_info"].lower_hud_offset = 0
				end
			end
		else
			while isInvisChar(string.sub(prompt.text, prompt.textprogress+1, prompt.textprogress+1)) do
				prompt.textprogress = $ + 1
			end
			local thisChar = string.sub(prompt.text, prompt.textprogress, prompt.textprogress)
			local nextCharBeat = 1
			if thisChar == "!" or thisChar == "." or thisChar == "?" then
				nextCharBeat = 15
			end
			if thisChar == "," then
				nextCharBeat = 9
			end
			if prompt.textprogbeat >= nextCharBeat then
				prompt.textprogbeat = 0
				prompt.textprogress = $ + 1
			end
		end
	-- elseif p.cmd.buttons & BT_CUSTOM3 then
	--     startDialouge(p, {text = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"})
	end

	if p.tutAngleDelay == nil then
		p.tutAngleDelay = 0
	end

	if leveltime > 5 then
		if p.mo and p.mo.valid then
			if p.mo.subsector.sector.tag == 2502 then
				if not p.tutDialougeProgress["lookatbrick"] then
					if p["ze2_info"].team == 2 then
						startDialouge(p, {
							icon = "STARORB",
							height = 3,
							name = "Camera Control",
						 -- text cutoff for starorb is riiiiiiiiiiight here v     v
							text = "Keep the camera pointed at\x89 Brick\x80\nto continue."
						})
					else
						startDialouge(p, {
							text = ("You should look at\x89 Brick\x80!\nHe's so cute! And completely\noblivious to the zombies.")
						})
					end
					p.tutDialougeProgress["lookatbrick"] = true
				end

				-- hardcoded X/Y cuz im too lazy to make it dynamic
				local correctAngle = R_PointToAngle2(p.mo.x, p.mo.y, -3904*FU, 10176*FU)
				local angDiff = correctAngle-(p.cmd.angleturn << 16)
				--print(p.mo.angle / ANG1)
				if abs(angDiff)/ANG1 <= 67 then
					p.tutAngleDelay = 0
				else
					p.tutAngleDelay = ($ or 0) + 1
					if p.tutAngleDelay > 10 then
						P_LinedefExecute(2002, p.mo)
						p.tutAngleDelay = 0
						if p["ze2_info"].team == 1 then
							startDialouge(p, {
								icon = "AMYRCONC",
								text = angleFailTexts[P_RandomRange(1, #angleFailTexts)]:gsub("NAME", p.name)
							})
						end
					end
				end
			else
				p.tutAngleDelay = 0
			end
		end

		if ZE2.game_ended then
			if (p["ze2_info"].team == 1 or p["ze2_info"].team == 2) and not p.spectator and not p.tutDialougeProgress["end"] then
				p.tutDialougeProgress["end"] = true

				-- don't do some other dialouges
				p.tutDialougeProgress["lookatbrick"] = true
				p.tutDialougeProgress["wall"] = true
				p.tutDialougeProgress["ringroom"] = true
				p.tutDialougeProgress["greeting"] = true
				p.tutDialougeProgress["Zgreeting"] = true

				if ZE2.team_won == 1 then
					if (p.tutLastTeam or p["ze2_info"].team) == 1 then -- survivor won
						startDialouge(p, {
							icon = "AMYRJOYS",
							text = "Yayyyyy!",
							next = {
								text = "Nice job, " .. p.name .. "!"
							}
						})
					else -- zombie lost
						startDialouge(p, {
							icon = "STARORB",
							height = 3,
							name = "Game Over",
						 -- text cutoff for starorb is riiiiiiiiiiight here v     v
							text = "The\x84 Survivors\x80 have won and defeated\nthe\x83 Zombies\x80. Better luck next time."
						})
					end
				else
					if (p.tutLastTeam or p["ze2_info"].team) == 1 then -- survivor lost
						startDialouge(p, {
							icon = "AMYRCONC",
							text = "Aww man! Better luck next time,\n" .. p.name .. "."
						})
					else -- zombie won
						startDialouge(p, {
							icon = "STARORB",
							height = 3,
							name = "Game Over",
						 -- text cutoff for starorb is riiiiiiiiiiight here v     v
							text = "The\x83 Zombies\x80 have won, and the\x84\nSurvivors\x80 have fallen. Good work."
						})
					end
				end
			end
		end
		p.tutLastTeam = p["ze2_info"] and p["ze2_info"].team
	end
	
	if p.tutCurrentPrompt then
		p["ze2_info"].lower_hud_offset = p.tutCurrentPrompt.height * 13
	end
end)

addHook("MapLoad", function ()
	for p in players.iterate do
		if p and p.valid then
			p.tutDialougeProgress = {}
		end
	end
end)


hud.add(function (v, player)
	if player.tutCurrentPrompt then
		F_TextPromptDrawer(v, player.tutCurrentPrompt)
	end
end)
