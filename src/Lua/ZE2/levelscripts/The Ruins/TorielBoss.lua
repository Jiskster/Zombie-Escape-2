local ut_mapnum = G_FindMapByNameOrCode("MAP03")

addHook("MobjSpawn", function(mobj)
	mobj.toriel_boss = {
		state = "ready";
		nextstate = "dash";
		tics = 3*TICRATE;
	}

	mobj.toriel_boss.start_tics = mobj.toriel_boss.tics;
end, MT_TORIEL)

addHook("MobjThinker", function(mobj)
	local boss = mobj.toriel_boss;

	if not boss then
		return
	end

	local switchstate = false;

	if not P_LookForPlayers(mobj, 2048*FU, true) then return end
	if not mobj.health then return end

	if boss.tics then
		boss.tics = max(0, $ - 1);

		if not boss.tics then
			boss.state = boss.nextstate;

			switchstate = true;
		end
	end

	if switchstate == true then
		if P_LookForPlayers(mobj, 2048*FU, true) and mobj.target and mobj.target.valid then
			local ang = R_PointToAngle2(mobj.x, mobj.y, mobj.target.x, mobj.target.y)
			mobj.angle = ang
		end

		if boss.state == "ready" then
			if P_RandomChance(FU/2) then
				boss.nextstate = "attack1"
			else
				boss.nextstate = "dash"
			end

			if mobj.health < mobj.maxhealth/4 then
				boss.tics = 1*TICRATE
			else
				boss.tics = 5*TICRATE
			end
		elseif boss.state == "attack1" then


			boss.tics = 3*TICRATE/2

			boss.nextstate = "ready"
		elseif boss.state == "attack2" then
			boss.tics = 3*TICRATE/2
			for i=-4,4 do
				local uhh = P_SPMAngle(mobj, MT_CYBRAKDEMON_NAPALM_BOMB_SMALL, mobj.angle+(ANG15*i))

				uhh.momx = $ * 3
				uhh.momy = $ * 3
			end

			boss.nextstate = "ready"
		elseif boss.state == "dash" then
			P_InstaThrust(mobj, mobj.angle, 65*FU)

			if P_RandomChance(FU/2) then
				boss.nextstate = "attack1"
			else
				boss.nextstate = "attack2"
			end

			if mobj.health < mobj.maxhealth/4 then
				if P_RandomChance(FU/6) then
					boss.nextstate = "dash"
				end
			else
				if P_RandomChance(FU/16) then
					boss.nextstate = "dash"
				end
			end

			P_SpawnGhostMobj(mobj)

			boss.tics = 15
		end

		boss.start_tics = boss.tics
		switchstate = false;
	end

	if boss.state == "attack1" then
		local diff = boss.start_tics - boss.tics
		local anim = ease.linear(FixedDiv(diff, boss.start_tics), mobj.angle-(4*ANG15), mobj.angle+(4*ANG15))
		local tx = P_ReturnThrustX(mobj, anim, mobj.radius)
		local ty = P_ReturnThrustY(mobj, anim, mobj.radius)
		local thok = P_SpawnMobjFromMobj(mobj, tx, ty, mobj.height/16, MT_UNKNOWN)
		thok.fuse = 2
		thok.state = S_TORI_PAW
		thok.dispoffset = 2

		if ((leveltime) % 5) == 0 then
			local bullet = P_SPMAngle(mobj, MT_FIREBALL, anim)
			P_SetOrigin(bullet, thok.x, thok.y, thok.z)
			bullet.colorized = true
			bullet.color = SKINCOLOR_WHITE
			bullet.momx = $ * 2
			bullet.momy = $ * 2
		end
	end
end, MT_TORIEL)

addHook("MobjDeath", function(mobj)
	if gamemap ~= ut_mapnum then return end

	P_LinedefExecute(32)
end, MT_TORIEL)