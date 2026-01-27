freeslot("MT_ZE2_TELEGFX", "SPR_TGFX")

for i=1,10 do
	freeslot("S_ZE2_TELEGFX"..i)
end

freeslot("sfx_telepo")
--ohg my ears burn
sfxinfo[sfx_telepo].flags = SF_X2AWAYSOUND

mobjinfo[MT_ZE2_TELEGFX] = {
	doomednum = -1,
	spawnhealth = 1,
	spawnstate = S_ZE2_TELEGFX1,
	radius = 64*FRACUNIT,
	height = 64*FRACUNIT,
	flags = MF_NOGRAVITY|MF_NOBLOCKMAP|MF_NOCLIP
}

states[S_ZE2_TELEGFX1] = {SPR_TGFX, FF_FULLBRIGHT|A, 6, nil, 0, 0, S_ZE2_TELEGFX2}
states[S_ZE2_TELEGFX2] = {SPR_TGFX, FF_FULLBRIGHT|B, 6, nil, 0, 0, S_ZE2_TELEGFX3}
states[S_ZE2_TELEGFX3] = {SPR_TGFX, FF_FULLBRIGHT|C, 6, nil, 0, 0, S_ZE2_TELEGFX4}
states[S_ZE2_TELEGFX4] = {SPR_TGFX, FF_FULLBRIGHT|D, 6, nil, 0, 0, S_ZE2_TELEGFX5}
states[S_ZE2_TELEGFX5] = {SPR_TGFX, FF_FULLBRIGHT|E, 6, nil, 0, 0, S_ZE2_TELEGFX6}
states[S_ZE2_TELEGFX6] = {SPR_TGFX, FF_FULLBRIGHT|F, 6, nil, 0, 0, S_ZE2_TELEGFX7}
states[S_ZE2_TELEGFX7] = {SPR_TGFX, FF_FULLBRIGHT|G, 6, nil, 0, 0, S_ZE2_TELEGFX8}
states[S_ZE2_TELEGFX8] = {SPR_TGFX, FF_FULLBRIGHT|H, 6, nil, 0, 0, S_ZE2_TELEGFX9}
states[S_ZE2_TELEGFX9] = {SPR_TGFX, FF_FULLBRIGHT|I, 6, nil, 0, 0, S_ZE2_TELEGFX10}
states[S_ZE2_TELEGFX10]= {SPR_TGFX, FF_FULLBRIGHT|J, 0, nil, 0, 0, S_NULL}

addHook("MobjSpawn", function(mobj)
	S_StartSound(mobj, sfx_telepo)
end, MT_ZE2_TELEGFX)