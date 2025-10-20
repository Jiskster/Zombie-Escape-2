freeslot("SKINCOLOR_ALPHAZOMBIE")
skincolors[SKINCOLOR_ALPHAZOMBIE] = {
    name = "Alpha Zombie",
    ramp = {89,85,223,55,56,37,38,39,41,42,43,45,46,47,30,31},
    invcolor = SKINCOLOR_GREEN,
    invshade = 9,
    chatcolor = V_GREENMAP,
    accessible = false
}
//these are the only two lines you need to edit!
local flashColor = skincolors[SKINCOLOR_ALPHAZOMBIE] //change this to your desired skincolor!
local flashDelay = 2 //change this to how many tics it takes to animate

local rampPos = 1
local rampDir = true
local ramps = {}

//convert the ramp to a table
ramps[1] = {}
for i = 0, 15, 1
	ramps[1][i+1] = flashColor.ramp[i]
end

//create the offset versions of the ramp
for i = 2, 16,1
	ramps[i] = {}

	for pos,val in ipairs(ramps[i-1]) do
		if not (pos == 16) then
			ramps[i][pos+1] = val
		else
			ramps[i][1] = val
		end
	end
end

local function RampWave()
	if not (leveltime % flashDelay) then

		rampPos = $1+1
		
		//too high, time to go back
		if not (ramps[rampPos])
			rampPos = 1
		end

		flashColor.ramp = ramps[rampPos]
	end
end

addHook("ThinkFrame", RampWave)




