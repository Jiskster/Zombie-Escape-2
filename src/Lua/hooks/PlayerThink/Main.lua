local pv = player.ze2
local pmo = player.mo

player.charflags = SF_NOJUMPSPIN|SF_NOJUMPDAMAGE|SF_NOSKID -- Remove Vanilla Flags
player.pflags = $ & ~PF_DIRECTIONCHAR

if (player.pflags & PF_ANALOGMODE) then
	player.pflags = $ | PF_FORCESTRAFE
	player.pflags = $ & ~PF_ANALOGMODE
else
	player.pflags = $ & ~PF_FORCESTRAFE
end

-- Hide player when in pregame menu
if not ZE2.round_active and pv.pregamemenu_active then
	if player.mo and player.mo.valid then
		player.mo.flags2 = $|MF2_DONTDRAW
	end
end

if pv.sprintmeter < 0 then
	pv.sprintmeter = 0
end

if pv.team == 1 then
	ZE2.SetCCtoplayer(player)
elseif pv.team == 2 then
	ZE2.SetZCtoplayer(player)
end

if pmo and pmo.valid then
	if pv.landfatigue and (pmo.eflags & MFE_JUSTHITFLOOR) then
		pv.landfatigue = false
		pv.landfatigue_timer = $ + 20
	end
	
	ZE2.LimitMobjHealth(pmo)
	
	if (player.pflags & PF_JUMPED) then
		pv.isJumping = true
	end

	if (pmo.eflags & MFE_SPRUNG) then
		pv.isSprung = true
	end

	if P_IsObjectOnGround(pmo) or (pmo.eflags & MFE_JUSTHITFLOOR) then
		if pv.isJumping then
			pv.isJumping = false
		end
		
		pv.isSprung = false
	end
	
	if not pmo.health then
		if ZE2.round_active and not ZE2_game_ended and 
		((ZE2.PlayerCount() > 1) or (mapheaderinfo[gamemap].ze2_solofail)) then
			player.ze2.team = 2
		end
	end
end

if mapheaderinfo[gamemap].ze2_noabilities then
	player.pflags = $ & ~PF_GLIDING
	player.pflags = $ & ~PF_BOUNCING
	player.powers[pw_tailsfly] = 0
end


	
