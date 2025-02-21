local cash_given = 200

freeslot("MT_MEGAHP", "S_MEGAHP", "SPR_MGAO", "sfx_maxhp")

mobjinfo[MT_MEGAHP] = {
	//$Category Zombie Escape 2
	//$Name Mega HP Orb
	//$Sprite MGAOA0
	
	doomednum = 1472,
	spawnstate = S_MEGAHP,
	spawnhealth = 1,
	deathstate = S_RINGEXPLODE,
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

ZE2.HitMegaHP = function(special, toucher)
	if toucher and toucher.valid and toucher.player and toucher.player["ze2_info"].team and toucher.player["ze2_info"].team == 1 then
		toucher.health = toucher.maxhealth
		ZE2:GiveShieldToMobj(toucher, 1)
		ZE2:GivePlayerRubies(toucher.player, cash_given)
		CONS_Printf(toucher.player,"\x83+ $"..cash_given.." cash bonus!")
	else
		return true
	end
end

addHook("TouchSpecial", ZE2.HitMegaHP, MT_MEGAHP)
