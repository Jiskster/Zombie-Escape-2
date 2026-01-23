freeslot("MT_XS_INTERACTION")

freeslot("MT_XS_SELECTOR")

mobjinfo[MT_XS_INTERACTION] = {
	//$Category xSlinger
	//$Name xSlinger Interaction
	
	//$StringArg0 Interaction Text
	
	//$Arg0 Trigger Tag
	//$Arg0Default 0
	//$Arg0Type 0
	//$Arg0Tooltip This tag will be called when the interaction is called.
	
	//$Arg1 Trigger Tag 2 (Secondary Toggle)
	//$Arg1Default 0
	//$Arg1Type 0
	//$Arg1Tooltip This tag will be called when the interaction is called after the first tag is called.
	
	//$Arg2 Duration
	//$Arg2Default 35
	//$Arg2Type 0
	//$Arg2Tooltip The time it takes to call the interaction (In tics)\nNegative numbers are converted to seconds (-5 = 35*5)
	
	//$Arg3 Cooldown
	//$Arg3Default 0
	//$Arg3Type 0
	//$Arg3Tooltip The time the interaction gets disabled after being interacted with.\nNegative numbers are converted to seconds (-5 = 35*5)
	
	//$Arg4 Team Restrict
	//$Arg4Default 0
	//$Arg4Type 12
	//$Arg4Enum {1="Team 1"; 2="Team 2"; 4="Team 3"; 8="Team 4";}
	//$Arg4Tooltip Which teams can see this interaction?

	doomednum = 50500,
	
	spawnhealth = 1000,
	
	spawnstate = S_UNKNOWN,
	deathstate = S_UNKNOWN,
	radius = 32*FU,
	height = 64*FU,
	flags = MF_NOGRAVITY|MF_SPECIAL,
}

mobjinfo[MT_XS_SELECTOR] = {
	doomednum = -1,
	
	spawnhealth = 1000,
	
	spawnstate = S_INVISIBLE,
	deathstate = S_INVISIBLE,
	radius = 24*FU,
	height = 24*FU,
	flags = MF_NOGRAVITY,
}

local seldist = 80*FU

addHook("PlayerThink", function(player)
	if not (player.mo and player.mo.valid) then
		return end;
		
	local xS = player.xSlinger
	local cmd = player.cmd
	
	local x = player.mo.x + FixedMul(cos(player.mo.angle), seldist)
	local y = player.mo.y + FixedMul(sin(player.mo.angle), seldist)
	local z = player.mo.z + FixedMul(sin(player.aiming), player.mo.height)
		
	if not (player.mo.iselector and player.mo.iselector.valid) then
		player.mo.iselector = P_SpawnMobj(x,y,z,MT_XS_SELECTOR)
		player.mo.iselector.target = player.mo
	else
		P_MoveOrigin(player.mo.iselector, x, y, z)
	end
	
	if not (xS.selected_interaction and xS.selected_interaction.valid) then
		-- Executes when nothing is happening
		
		xS.selected_interaction = nil
		xS.selected_interaction_timer = 0
		xS.interaction_hold = 0
	elseif (xS.selected_interaction_timer) then
		xS.selected_interaction_timer = max(0, $ - 1)
		-- You're not selecting a interaction anymore
		if not (xS.selected_interaction_timer) then
			xS.selected_interaction = nil
			xS.interaction_hold = 0
		end
	end
	
	local i_obj = player.xSlinger.selected_interaction
	
	if i_obj and i_obj.valid and not xS.interaction_delay then
		local interaction = i_obj.interaction
		
		if (cmd.buttons & BT_CUSTOM3) then
			xS.interaction_hold = min($ + 1, interaction.holdtime)
			
			if xS.interaction_hold == interaction.holdtime then
				-- tag execute and custom function execute
				if interaction.triggertag then
					P_LinedefExecute(interaction.triggertag, player.mo)
				end
				
				if interaction.set_cooldown then
					interaction.cooldown = interaction.set_cooldown
				end
				
				xS.interaction_delay = 4 -- keep this low
			end
		else
			if xS.interaction_hold then
				xS.interaction_hold = FixedMul($*FU, (FU*3)/4)/FU
			end
		end
	end
	
	if xS.interaction_delay then
		xS.interaction_hold = FixedMul($*FU, (FU*3)/4)/FU
		xS.interaction_delay = $ - 1
		
		-- To prevent spamming when holding interaction button
		if not (xS.interaction_delay) and (i_obj and i_obj.valid) and (cmd.buttons & BT_CUSTOM3) then
			xS.interaction_delay = 1
		end
	end
	
	if xS.selected_interaction then
		-- set hold to zero when switching interactions
		if xS.selected_interaction_last and xS.selected_interaction_last.valid 
		and xS.selected_interaction_last ~= xS.selected_interaction then
			xS.interaction_hold = 0
		end
		
		xS.selected_interaction_last = xS.selected_interaction
	end
end)

addHook("MapThingSpawn", function(mobj, mapthing)
	if not (mobj and mobj.valid) then
		return end;
		
	-- Lazy to use a metatable at the moment
	mobj.interaction = {
		text = mapthing.stringargs[0] or "???";
		type = "generic";
		triggertag = mapthing.args[0];
		triggertag2 = mapthing.args[1];
		holdtime = mapthing.args[2];
		set_cooldown = mapthing.args[3];
		team_restrict = {enabled = false};
	}

	for i=0,3 do
		if mapthing.args[4] & (1<<i) then
			mobj.interaction.team_restrict[i+1] = true
			
			if not mobj.interaction.team_restrict.enabled then
				mobj.interaction.team_restrict.enabled = true
			end
		end
	end
	
	-- Negative numbers are converted into seconds
	if mobj.interaction.holdtime < 0 then
		mobj.interaction.holdtime = abs($*TICRATE)
	end
	if mobj.interaction.set_cooldown < 0 then
		mobj.interaction.set_cooldown = abs($*TICRATE)
	end
end, MT_XS_INTERACTION)

addHook("MobjThinker", function(mobj)
	if not (mobj.interaction) then
		return end;
	
	local interaction = mobj.interaction
	
	if interaction.cooldown then
		interaction.cooldown = $ - 1
	end
	
	if mobj.target and mobj.target.valid then
		P_MoveOrigin(mobj, mobj.target.x, mobj.target.y, mobj.target.z)
	end
end, MT_XS_INTERACTION)

addHook("TouchSpecial", function(special, toucher)
	return true
end, MT_XS_INTERACTION)

addHook("MobjThinker", function(mobj)
	if not (mobj.target and mobj.target.valid and mobj.target.health) then
		P_RemoveMobj(mobj)
	end
end, MT_XS_SELECTOR)

-- Team checking too.
local function checkInteraction(i_obj, team)
	if i_obj and i_obj.valid then
		local interaction = i_obj.interaction
		
		if interaction.team_restrict and interaction.team_restrict.enabled 
		and not interaction.team_restrict[team] then
			return false
		end

		return true
	else
		return false
	end
end

addHook("MobjMoveCollide", function(tmthing, thing)
	if not (tmthing.target) then
		P_RemoveMobj(tmthing) -- this might be a problem but idk
		return false
	end
	
	local player = tmthing.target.player
	local pmo = tmthing.target
	local xS = player.xSlinger
	
	if thing.type ~= MT_XS_INTERACTION then
		return false
	end
	
	-- Height Check
	if tmthing.z > thing.z+thing.height
	or thing.z > tmthing.z+tmthing.height then
		return false
	end

	local oldiobj = xS.selected_interaction
	local settime = 2
	
	if oldiobj and oldiobj.valid and oldiobj ~= thing then
		local olddist = R_PointToDist2(oldiobj.x, oldiobj.y, tmthing.x, tmthing.y)
		local newdist = R_PointToDist2(thing.x, thing.y, tmthing.x, tmthing.y)
		
		if (olddist < newdist) and not (oldiobj.interaction.cooldown) and checkInteraction(oldiobj, xS.team) then
			xS.selected_interaction = oldiobj
			xS.selected_interaction_timer = settime
		elseif not (thing.interaction.cooldown) and checkInteraction(thing, xS.team) then
			xS.selected_interaction = thing
			xS.selected_interaction_timer = settime
		end
	elseif not (thing.interaction.cooldown) and checkInteraction(thing, xS.team) then
		xS.selected_interaction = thing
		xS.selected_interaction_timer = settime
	end
	
	return false
end, MT_XS_SELECTOR)