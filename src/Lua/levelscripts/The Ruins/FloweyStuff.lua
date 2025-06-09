local function theruins_floweytalk()
	chatprint("\x82\<Flowey>\x80 Hey, why are you in a hurry- Wait!")
	S_StartSound(nil, sfx_fwtlk)
end

local function theruins_floweytalk2()
	local flowey_exists = false
	
	for thing in mapthings.iterate do 
		if thing.mobj and thing.mobj.valid and not thing.mobj.stomped and thing.mobj.type == MT_FLOWEY1 then
			flowey_exists = true
			break
		end
	end
	
	if flowey_exists then
		chatprint("\x82\<Flowey>\x80 SHE COULDN'T EVEN SAVE HERSELF! WHAT AN IDIOT!")
		S_StartSound(nil, sfx_fwtlk)
	end
end

local function theruins_floweytalk3()
	chatprint("\x82\<Flowey>\x80 AHHH!")
	S_StartSound(nil, sfx_utack)
end

addHook("TouchSpecial", function(special, toucher)
	if not special.stomped then
		theruins_floweytalk3()
		special.renderflags = $ | RF_FLOORSPRITE | RF_NOSPLATBILLBOARD
		special.stomped = true
	end
	
	for thing in mapthings.iterate do 
		if thing.mobj and thing.mobj.valid and not thing.mobj.stomped and thing.mobj.type == MT_FLOWEY1 then
			P_RemoveMobj(thing.mobj)
		end
	end
	
	return true
end, MT_FLOWEY1)

addHook("LinedefExecute", theruins_floweytalk, "FWTLK1")
addHook("LinedefExecute", theruins_floweytalk2, "FWTLK2")