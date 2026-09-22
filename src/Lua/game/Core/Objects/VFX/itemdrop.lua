freeslot("S_ZE2_DROPITEMVFX")
freeslot("SPR_ZE2_DROPITEMVFX")

-- 7 frame advances with each frame lasting 4 tics
states[S_ZE2_DROPITEMVFX] = {
	sprite = SPR_ZE2_DROPITEMVFX,
	frame = 2|FF_SEMIBRIGHT,
	tics = 1,
	action = function(v)
		v.alpha = FU - FixedDiv(v.extravalue1*FU, (7*4)*FU)

		v.extravalue1 = $ + 1
		v.frame = ($ &~FF_FRAMEMASK)|(2 + (v.extravalue1/4))
	end,
	nextstate = S_ZE2_DROPITEMVFX
}

-- Not sure if a MobjThinker is the best way for this
local CORONA_DIST = 1024*FU
addHook("MobjThinker", function(drop)
	if not (drop and drop.valid) then return end

	local zoff = (FixedDiv(drop.height, drop.scale) / 2) + 8*FU

	local fudge = -2 * FU
	local fudge_ang = R_PointToAngle(drop.x, drop.y)
	local fudge_dist = R_PointToDist(drop.x, drop.y)
	local fx = P_ReturnThrustX(nil, fudge_ang, fudge)
	local fy = P_ReturnThrustY(nil, fudge_ang, fudge)

	local f -- flair mobj pointer
	local flair_roll = FixedAngle(leveltime * FU * 3/2)
	local flair_color = drop.color or drop.dropbgcolor or SKINCOLOR_WHITE

	---- LINE VFX
		if (leveltime % 4 == 0) then
			local rad = FixedDiv(drop.radius, drop.scale) / FU / 2
			local hei = FixedDiv(drop.height, drop.scale) / FU / 2
			local v = P_SpawnMobjFromMobj(drop,
				P_RandomRange(-rad, rad)*FU,
				P_RandomRange(-rad, rad)*FU,
				zoff + P_RandomRange(-hei, hei)*FU,
				MT_PARTICLE
			)
			v.state = S_ZE2_DROPITEMVFX
			v.fuse = (7*4)
			v.color = flair_color
			P_SetObjectMomZ(v, FU)
		end
	----

	---- INNER FLAIR
		f = P_SpawnMobjFromMobj(drop, fx,fy,zoff, MT_PARTICLE)
		f.tics = 2
		f.fuse = 2

		f.sprite = SPR_ZE2_DROPITEMVFX
		f.frame = 0|FF_FULLBRIGHT|FF_ADD

		f.scale = $ * 3/4
		f.dispoffset = -600

		f.rollangle = flair_roll
		f.color = flair_color
		f.alpha = FU/3
		
	----

	---- OUTER FLAIR
		f = P_SpawnMobjFromMobj(drop, fx,fy,zoff, MT_PARTICLE)
		f.tics = 2
		f.fuse = 2

		f.sprite = SPR_ZE2_DROPITEMVFX
		f.frame = 0|FF_FULLBRIGHT|FF_ADD

		f.scale = $ * 3/2
		f.dispoffset = -650

		f.rollangle = -flair_roll
		f.color = flair_color
		f.alpha = FU/5
	----

	-- LENS FLAIR
		f = P_SpawnMobjFromMobj(drop, fx,fy,zoff, MT_PARTICLE)
		f.tics = 2
		f.fuse = 2

		f.sprite = SPR_ZE2_DROPITEMVFX
		f.frame = 1|FF_FULLBRIGHT|FF_ADD

		f.dispoffset = -700
		local alpha = FU
		if (fudge_dist < CORONA_DIST) then
			alpha = FixedDiv(fudge_dist, CORONA_DIST)
		end
		f.scale = $ + FixedDiv(fudge_dist - CORONA_DIST/2, CORONA_DIST) / 2
		f.spritexscale = FU/2
		f.spriteyscale = FU/2
		f.alpha = alpha / 3
	--
end, MT_XS_DROPPEDITEM)