freeslot(
"sfx_dropen", "sfx_prtal", "sfx_ston", "sfx_trvel", "sfx_mclava", "sfx_mcwatr", "SPR_MCSN", "S_MINECRAFTSUN",
"MT_MINECRAFTSUN"
)

states[S_MINECRAFTSUN] = {SPR_MCSN, A, -1, nil, 0, 0, S_MINECRAFTSUN}

mobjinfo[MT_MINECRAFTSUN] = {
		--$Title Minecraft Sun
		--$Sprite MCSNA0
		--$Category Minecraft
        doomednum = 1737,
        spawnstate = S_MINECRAFTSUN,
        speed = 0,
        radius = 5*FRACUNIT,
        height = 5*FRACUNIT,
        mass = 1,
		flags = MF_NOTHINK|MF_NOGRAVITY|MF_NOCLIP
}