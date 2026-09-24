freeslot("MT_CRRING", "S_CRRING", "SPR_GOALRING")

mobjinfo[MT_CRRING] = {
	//$Category Zombie Escape 2
	//$Name Exit Ring
	//$Sprite SIGNF0

	doomednum = 860,
	spawnstate = S_CRRING,
	painchance = 192*FRACUNIT,
	spawnhealth = 1,
	radius = 32*FU,
	height = 48*FU,
	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}

states[S_CRRING] = {
	sprite = SPR_GOALRING,
	frame = FF_FULLBRIGHT|FF_ANIMATE|FF_ADD|A,
	tics = -1,
	var1 = 23,
	var2 = 1,
	nextstate = S_CRRING,
}

addHook("MobjSpawn", function(mobj)
	mobj.scale = $ * 4
	mobj.colorized = true
	mobj.color = SKINCOLOR_CHROMA

	mobj.corona = P_SpawnMobjFromMobj(mobj, 0, 0, 16*FU, MT_CORONA)
	
	mobj.lensflare = P_SpawnMobjFromMobj(mobj, 0,0, 16*FU, MT_PARTICLE)
	mobj.lensflare.sprite = SPR_ZE2_DROPITEMVFX
	mobj.lensflare.frame = 1|FF_FULLBRIGHT|FF_ADD
	mobj.lensflare.dispoffset = -400
	mobj.lensflare.spritexscale = FU
	mobj.lensflare.spriteyscale = mobj.lensflare.spritexscale
	mobj.lensflare.fuse = -1
	mobj.lensflare.tics = -1
	mobj.lensflare.flags = $|MF_NOTHINK|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPTHING
end, MT_CRRING)

local CORONA_DIST = 1024*FU * 2
local CORONA_BASEALPHA = FU / 2
local CORONA_MIDALPHA = (FU - CORONA_BASEALPHA) / 2
addHook("MobjThinker", function(mobj)
	if mobj.corona and mobj.corona.valid then
		local corona = mobj.corona
		corona.color = mobj.color
		corona.alpha = (FU/4) + abs(cos(leveltime*ANG1*5))/2
		corona.scale = FRACUNIT
		corona.colorized = true
		corona.dispoffset = 3
	end
	
	if (mobj.lensflare and mobj.lensflare.valid) then
		local f = mobj.lensflare
		local fudge_dist = R_PointToDist(mobj.x, mobj.y)
		local alpha = FU
		if (fudge_dist < CORONA_DIST) then
			alpha = FixedDiv(fudge_dist, CORONA_DIST)
		end
		f.scale = FU + max(FixedDiv(fudge_dist, CORONA_DIST) / 2, 0)
		
		-- Lol
		alpha = FixedMul($, CORONA_BASEALPHA + (CORONA_MIDALPHA + FixedMul(CORONA_MIDALPHA, cos(leveltime*ANG1*5))))
		f.alpha = alpha
	end
end, MT_CRRING)

addHook("MobjRemoved", function(mobj)
	if mobj and mobj.valid then
		if mobj.corona and mobj.corona.valid then
			P_RemoveMobj(mobj.corona)
		end
	end
end, MT_CRRING)

addHook("TouchSpecial", function(special,toucher)
	local game = ZE2.Game
	if toucher and toucher.valid and toucher.player and toucher.player.valid then
		special.team = toucher.team
		local player = toucher.player
		if not player then return end
		if (not player.ze2.ghostmode) and (not game.ended) and (game.active) then
			player.ze2.ghostmode = true
			
			special.flags = $ | MF_NOCLIP
			special.z = $ - (special.height/2)*P_MobjFlip(special)
			special.state = S_RINGEXPLODE
			S_StopSound(special)
		
			S_StartSound(nil,sfx_s3kb3)

			ZE2:StartWin(toucher.team, true)
		end
		return true
	end
end, MT_CRRING)