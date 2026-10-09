-- Overlay / Aura for Alpha Zombie
-- Imported some code from Switch Skin Sprites V2 except it's code is reduced to only cover Alpha Zombie needs.

local overlay_spritescale = FU * 8 / 7

local function AlphaOVThinker(ov, mo)
	-- Sync up the main things of a skin. SPR_PLAY, Sprite2 and States
	ov.skin = mo.skin
	ov.state = mo.state

	-- And now eeeverything visual related.
    ov.frame = mo.frame
	ov.tics = mo.tics
	ov.spriteroll = mo.spriteroll
	ov.dontdrawforviewmobj = mo -- Don't draw on first person
	ov.colorized = mo.colorized
	ov.color = SKINCOLOR_RED -- TODO: Translations makes the alpha skin color not animate! Hopefully for v2.2.16 we have that fixed...? we're using a fixed skincolor for now.
	ov.angle = mo.player.drawangle
    ov.alpha = mo.alpha / 2
	ov.flags2 = mo.flags2
end

local function DoAlphaOverlay(mo) -- Give the overlay for the Alpha Zombie
    if not (mo and mo.valid) then return end

    if mo.color ~= SKINCOLOR_ALPHAZOMBIE then
        if (mo.alphaoverlay and mo.alphaoverlay.valid) then
            P_RemoveMobj(mo.alphaoverlay)
            mo.alphaoverlay = nil
        end
        return
    end

    if not (mo.alphaoverlay and mo.alphaoverlay.valid) then
        mo.alphaoverlay = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_OVERLAY) -- MT_OVERLAY automatically removes itself if their target is not valid.
        mo.alphaoverlay.target = mo
        mo.alphaoverlay.spriteyoffset = $ - (6 * FU)
        mo.alphaoverlay.spritexscale = overlay_spritescale
	    mo.alphaoverlay.spriteyscale = overlay_spritescale
        mo.alphaoverlay.renderflags = RF_FULLBRIGHT
        mo.alphaoverlay.blendmode = AST_ADD
        mo.alphaoverlay.dispoffset = mo.dispoffset + 1
        mo.alphaoverlay.translation = "alpha_ov"
        AlphaOVThinker(mo.alphaoverlay, mo)
    else
        local ov = mo.alphaoverlay
        AlphaOVThinker(ov, mo)
    end
end

addHook("MobjThinker", DoAlphaOverlay, MT_PLAYER)
