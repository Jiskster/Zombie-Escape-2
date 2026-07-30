-- Overlay / Aura for Alpha Zombie
-- Imported some code from Switch Skin Sprites V2 except it's code is reduced to only cover Alpha Zombie needs.

local overlay_spritescale = FU * 9 / 8

local function FalseSkinThinker(ov, p)
	if not (p and p.mo and p.mo.valid) then return end
	local pmo = p.mo

	-- Sync up the main things of a skin. SPR_PLAY, Sprite2 and States
	ov.skin = p.mo.skin
	ov.state = pmo.state

	-- And now eeeverything visual related.
    ov.frame = pmo.frame
	ov.tics = pmo.tics
	ov.spritexscale = FixedMul(pmo.spritexscale, overlay_spritescale)
	ov.spriteyscale = FixedMul(pmo.spriteyscale, overlay_spritescale)
	ov.spriteroll = pmo.spriteroll
	ov.dontdrawforviewmobj = pmo -- Don't draw on first person
	ov.colorized = pmo.colorized
	ov.color = SKINCOLOR_RED -- TODO: Translations makes the alpha skin color not animate! Hopefully for v2.2.16 we have that fixed...? we're using a fixed skincolor for now.
	ov.angle = p.drawangle
    ov.alpha = pmo.alpha / 2
	ov.flags2 = pmo.flags2
    ov.eflags = pmo.eflags
end

local function PostThink() -- PostThinkFrame for consistency
    for p in players.iterate do
        if not (p.mo and p.mo.valid) then continue end
        local pmo = p.mo

        if pmo.color == SKINCOLOR_ALPHAZOMBIE then -- Let's better make it skin color exclusive
            if not (pmo.alphaoverlay and pmo.alphaoverlay.valid) then
                pmo.alphaoverlay = P_SpawnMobjFromMobj(pmo, 0, 0, 0, MT_OVERLAY)
                pmo.alphaoverlay.target = pmo
                pmo.alphaoverlay.spriteyoffset = $ - (5 * FU)
                pmo.alphaoverlay.renderflags = RF_FULLBRIGHT
                pmo.alphaoverlay.blendmode = AST_ADD
                pmo.alphaoverlay.dispoffset = pmo.dispoffset + 1
                pmo.alphaoverlay.translation = "alpha_ov"
                FalseSkinThinker(pmo.alphaoverlay, p)
            else
                local ov = pmo.alphaoverlay
                FalseSkinThinker(ov, p)
            end
        elseif (pmo.alphaoverlay and pmo.alphaoverlay.valid) then
            P_RemoveMobj(pmo.alphaoverlay)
        end

    end
end

addHook("PostThinkFrame", PostThink)