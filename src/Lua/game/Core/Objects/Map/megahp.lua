local cash_given = 200

freeslot("MT_MEGAHP", "S_MEGAHP", "SPR_MGAO", "sfx_maxhp")
sfxinfo[sfx_maxhp].caption = "Health picked up"

mobjinfo[MT_MEGAHP] = {
	//$Category Zombie Escape 2
	//$Name Mega HP Orb
	//$Sprite MGAOA0

	doomednum = 1472,
	spawnstate = S_MEGAHP,
	spawnhealth = 1,
	deathstate = S_RINGEXPLODE,
	painchance = 192*FRACUNIT,
	deathsound = sfx_maxhp,
	xdeathstate = S_NULL,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}

states[S_MEGAHP] = {
    sprite = SPR_MGAO,
    frame = FF_ANIMATE|A,
    tics = -1,
    var1 = 3, -- frame count
    var2 = 5, -- duration
}

sfxinfo[sfx_maxhp].caption="Max HP increased"

function ZE2.HitMegaHP(special, toucher)
	if toucher and toucher.valid and toucher.player and toucher.team then
		special.team = toucher.team

		local player = toucher.player
		toucher.health = toucher.maxhealth
		if (toucher.team == 1) then
			xSlinger.GiveShieldToMobj(toucher, 1)
		elseif (toucher.team == 2) then
			local xS = player.xSlinger
			player.ze2.zombie_type = "alpha"
			ZE2.ResetPlayer(player, 2, true)
		end
		player.ze2.karma = max(1, player.ze2.karma / 2)
		ZE2:GivePlayerCash(toucher.player, cash_given)
		CONS_Printf(toucher.player, "\x83" .. "+ $" .. cash_given .. " cash bonus!")
	else
		return true
	end
end

addHook("TouchSpecial", ZE2.HitMegaHP, MT_MEGAHP)
