--Because Play Sound linedef action sucks for global playing

addHook("LinedefExecute", function()
	S_StartSound(nil, sfx_dcrp01, nil)
end, "DOOMRADIO")

addHook("LinedefExecute", function()
	S_StartSound(nil, sfx_hell, nil)
end, "HELLAWAITS")

addHook("LinedefExecute", function()
	S_StartSound(nil, sfx_hell2, nil)
end, "HELL2")