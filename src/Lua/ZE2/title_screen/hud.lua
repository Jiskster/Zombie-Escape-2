// Title Screen by GLide KS

--Logo information
local ZE2_LOGO = "ZE2_TTL"
local x = 25*FU
local y = 15*FU

--For title screen functionality
local appear_time = 3*TICRATE
local titletics = 0
local alpha = 0

--localize v. functions
local getColormap
local cachePatch
local drawScaled

--Function to make a white fade. Instead of using separated patches.
local function DoWhiteFade(v, patch, time)
	if alpha == 9 then return end --V_TRANS90 maximum, at this point don't draw the white mask
	if (titletics % time) == 0 then	alpha = min($+1, 9)	end
	drawScaled(x, y, FU/4, patch, alpha<<V_ALPHASHIFT, getColormap(TC_ALLWHITE))
end

--Main title screen thinker
local MainTitle = function(v)
	titletics = min($+1, 10*TICRATE) --start title screen timer. shouldn't keep counting after at least 10 seconds...
	if getColormap == nil then getColormap = v.getColormap end
	if cachePatch == nil then cachePatch = v.cachePatch end
	if drawScaled == nil then drawScaled = v.drawScaled end

	local logo = cachePatch(ZE2_LOGO)

	--Make the logo appear
	if titletics >= appear_time then
		drawScaled(x, y, FU/4, logo)
		DoWhiteFade(v, logo, 1) --White mask fade
	end
end

--Reset title screen functionality when not on title screen
local Reset = function(v)
	if not titletics then return end
	titletics = 0
	alpha = 0
end

addHook("HUD", MainTitle, "title")
addHook("HUD", Reset)