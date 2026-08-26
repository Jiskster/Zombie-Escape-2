xSlinger.registerEffect("alphazombie.rage", {
	tick = function(effect, mobj, time_left)
		local g = P_SpawnGhostMobj(mobj)
		g.destscale = 0
		g.fuse = TICRATE
		g.scalespeed = FixedDiv(g.scale, g.fuse*FU)
		g.blendmode = AST_SUBTRACT
		g.renderflags = RF_FULLBRIGHT
	end;
	endfunc = function(effect, mobj)
		S_StartSound(mobj, sfx_bstdn)
	end
})