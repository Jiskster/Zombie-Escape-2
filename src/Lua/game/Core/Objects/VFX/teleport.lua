freeslot("MT_ZE2_TELEGFX", "SPR_TGFX")

for i=1,8 do
	freeslot("S_ZE2_TELEGFX"..i)
end

freeslot("sfx_telepo")
sfxinfo[sfx_telepo].flags = SF_X2AWAYSOUND --ohg my ears burn
sfxinfo[sfx_telepo].caption = "Teleportation"

mobjinfo[MT_ZE2_TELEGFX] = {
	doomednum = -1,
	spawnhealth = 1,
	spawnstate = S_ZE2_TELEGFX1,
	radius = 64*FRACUNIT,
	height = 64*FRACUNIT,
	dispoffset = 3,
	flags = MF_NOGRAVITY|MF_NOBLOCKMAP|MF_NOCLIP
}

states[S_ZE2_TELEGFX1] = {SPR_TGFX, FF_FULLBRIGHT|A, 1, nil, 0, 0, S_ZE2_TELEGFX2}
states[S_ZE2_TELEGFX2] = {SPR_TGFX, FF_FULLBRIGHT|B, 1, nil, 0, 0, S_ZE2_TELEGFX3}
states[S_ZE2_TELEGFX3] = {SPR_TGFX, FF_FULLBRIGHT|C, 1, nil, 0, 0, S_ZE2_TELEGFX4}
states[S_ZE2_TELEGFX4] = {SPR_TGFX, FF_FULLBRIGHT|D, 1, nil, 0, 0, S_ZE2_TELEGFX5}
states[S_ZE2_TELEGFX5] = {SPR_TGFX, FF_FULLBRIGHT|E, 1, nil, 0, 0, S_ZE2_TELEGFX6}
states[S_ZE2_TELEGFX6] = {SPR_TGFX, FF_FULLBRIGHT|F, 1, nil, 0, 0, S_ZE2_TELEGFX7}
states[S_ZE2_TELEGFX7] = {SPR_TGFX, FF_FULLBRIGHT|G, 1, nil, 0, 0, S_ZE2_TELEGFX8}
states[S_ZE2_TELEGFX8] = {SPR_NULL, FF_FULLBRIGHT|A, 35,nil, 0, 0, S_NULL}

addHook("MobjSpawn", function(mobj)
	S_StartSound(mobj, sfx_s1c3)
end, MT_ZE2_TELEGFX)