freeslot("S_SANS",
		 "MT_SANS",
		 "S_WF_FLOWER",
		 "S_WF_TREE",
		 "S_WF_VINE",
		 "MT_WF_FLOWER",
		 "MT_WF_TREE",
		 "MT_WF_VINE",
		 "spr_WFFL",
		 "spr_WFTR",
		 "spr_WFVN",
		 "spr_SANS"
		)
		
states[S_WF_FLOWER] = {SPR_WFFL, FF_FULLBRIGHT|A, -1, nil, 0, 0, S_WF_FLOWER}
states[S_WF_TREE] = {SPR_WFTR, FF_FULLBRIGHT|A, -1, nil, 0, 0, S_WF_TREE}
states[S_WF_VINE] = {SPR_WFVN, FF_FULLBRIGHT|A, -1, nil, 0, 0, S_WF_VINE}
states[S_SANS] = {SPR_SANS, A, -1, nil, 0, 0, S_SANS}

mobjinfo[MT_WF_FLOWER] = {
		--$Title WaterFall Flower
		--$Sprite WFFLA0
		--$Category Undertale
        doomednum = 1731,
        spawnstate = S_WF_FLOWER,
        speed = 0,
        radius = 20*FRACUNIT,
        height = 20*FRACUNIT,
        mass = 1,
		flags = MF_SCENERY
}

mobjinfo[MT_WF_TREE] = {
		--$Title WaterFall Tree
		--$Sprite WFTRA0
		--$Category Undertale
        doomednum = 1732,
        spawnstate = S_WF_TREE,
        speed = 0,
        radius = 20*FRACUNIT,
        height = 140*FRACUNIT,
        mass = 1,
		flags = MF_SCENERY
}

mobjinfo[MT_WF_VINE] = {
		--$Title WaterFall Vine
		--$Sprite WFVNA0
		--$Category Undertale
        doomednum = 1733,
        spawnstate = S_WF_VINE,
        speed = 0,
        radius = 20*FRACUNIT,
        height = 20*FRACUNIT,
        mass = 1,
		flags = MF_SCENERY|MF_NOGRAVITY|MF_NOCLIP
}

mobjinfo[MT_SANS] = {
		--$Title Sans (NPC)
		--$Sprite SANSA1
		--$Category Undertale
        doomednum = 1734,
        spawnstate = S_SANS,
        speed = 0,
        radius = 20*FRACUNIT,
        height = 65*FRACUNIT,
        mass = 1000,
		flags = MF_SOLID
}