-- RS NEO port.

freeslot(
	"MT_RS_THROWNFLAME",
	"S_RS_THROWNFLAME1",
	"S_RS_THROWNFLAME2",
	"S_RS_THROWNFLAME3",
	"SPR_RNGF",
	"sfx_rs_fla"
)

mobjinfo[MT_RS_THROWNFLAME] = {
	spawnstate = S_RS_THROWNFLAME1,
	deathstate = S_SPRK1,
	deathsound = sfx_s3k7e,
	speed = 100*FRACUNIT,
	radius = 24*FRACUNIT,
	height = 48*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY|MF_SLIDEME
}

states[S_RS_THROWNFLAME1] = {
	nextstate = S_RS_THROWNFLAME2,
	sprite = SPR_RNGF,
	frame = FF_FULLBRIGHT|FF_TRANS50|1,
	tics = 10
}
states[S_RS_THROWNFLAME2] = {
	nextstate = S_RS_THROWNFLAME3,
	sprite = SPR_RNGF,
	frame = FF_FULLBRIGHT|FF_TRANS40|2,
	tics = 10
}
states[S_RS_THROWNFLAME3] = {
	frame = FF_FULLBRIGHT|FF_TRANS30|3,
	tics = 20
}

sfxinfo[sfx_rs_fla] = {
	flags = SF_NOMULTIPLESOUND
}

xSlinger.registerItem("flame_ring", {
	displayname = "Flame Ring";
	
	icon = "FLAMIND";
	
	firerate = 2;
	
	color = SKINCOLOR_ORANGE;
	
	autouse = true;
	
	damage = 3;
	
	knockback = 1*FRACUNIT;
	
	flags2 = MF2_AUTOMATIC;
	
	ammo = 50;
	
	reload_time = TICRATE*4;

	usefunc = function(self, mo)
		local player = mo.player
		local pmo = player.mo
		
		local mt = MT_RS_THROWNFLAME
		local wave = sin(leveltime*ANG10) * 600
		local shot = xSlinger.SpawnMissile({
			source = mo, 
			type = mt,
			angle = mo.angle + wave,
			allow_aim = true,
			iteminfo = self,
		})
		
		S_StartSound(shot, sfx_rs_fla)
		
		if not P_IsObjectOnGround(mo) then
			local aim = max(-FRACUNIT, min(FRACUNIT, -player.aiming/13000))
			if P_MobjFlip(mo) * aim > 0
				aim = $ * 2/8
			end
			mo.momz = $ + FixedMul(mo.scale, aim)
			P_Thrust(mo, mo.angle, -FRACUNIT*2/3)
		end
	end;
	hitfunc = function(self, src, mo, inf)
		mo:give_effect("burning", {
			normalspeed_multiplier = FU/2,
			actionspd_multiplier = 3*FU/2,
			damage_multiplier = FU/2,
		}, 9, true)
		
		mo.flameringtarget = src
	end;
})

addHook("MobjThinker", function(mo)
	if not (mo and mo.valid) return end
	mo.momx = $ * 85/100
	mo.momy = $ * 85/100
	mo.momz = $ * 85/100
	P_SetObjectMomZ(mo, FRACUNIT/5, true)
end, MT_RS_THROWNFLAME)