freeslot("MT_SCENERYPLAYER", "MT_SCENERYZOMBIE", "S_SCENERYPLAY_STND", "S_SCENERYPLAY_WALK")

states[S_SCENERYPLAY_STND] = {SPR_PLAY, A, 1, nil, 0, 0, S_SCENERYPLAY_WALK}
states[S_SCENERYPLAY_WALK] = {states[S_PLAY_WALK].sprite, states[S_PLAY_WALK].frame, 2*TICRATE, nil, 0, 0, S_SCENERYPLAY_WALK}

mobjinfo[MT_SCENERYPLAYER] = {
		--$Title Scenery Player
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1735,
        spawnstate = S_SCENERYPLAY_STND,
        speed = 0,
        radius = 16*FRACUNIT,
        height = 56*FRACUNIT,
        mass = 1
}

mobjinfo[MT_SCENERYZOMBIE] = {
		--$Title Scenery Zombie
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1736,
        spawnstate = S_SCENERYPLAY_STND,
        speed = 0,
        radius = 16*FRACUNIT,
        height = 56*FRACUNIT,
        mass = 1
}

local function RandomSkin(num)
	if num == 0
		return "sonic"
	elseif num == 1
		return "tails"
	elseif num == 2
		return "knuckles"
	elseif num == 3
		return "amy"
	elseif num == 4
		return "fang"
	elseif num == 5
		return "metalsonic"
	end
end

addHook("MobjThinker", function(mo)
	if mo and mo.valid
		if not mo.stuffdone
			mo.skin = RandomSkin(P_RandomRange(0,5))
			mo.color = P_RandomRange(1,158)
			mo.stuffdone = 1
		end
	else
		mo.stuffdone = 0
	end
end, MT_SCENERYPLAYER)

addHook("MobjThinker", function(mo)
	if mo and mo.valid
		if not mo.stuffdone
			mo.skin = "zzombie"
			local alphachance = P_RandomChance(FU/8)
			if alphachance == true
				mo.color = SKINCOLOR_ALPHAZOMBIE
				mo.scale = mo.scale*3/2
			else
				mo.color = SKINCOLOR_MOSS
			end
			mo.stuffdone = 1
		end
	else
		mo.stuffdone = 0
	end
end, MT_SCENERYZOMBIE)