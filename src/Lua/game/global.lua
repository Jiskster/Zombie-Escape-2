rawset(_G, "ZE2", {})

ZE2.version = {0, 5, 0}
ZE2.version.indev = true
ZE2.version.commit = "local"

ZE2.WAIT_TIME = 15*TICRATE
ZE2.DEFAULT_ROUNDS = 2
ZE2.DEFAULT_ROUND_TIME = 5*60*TICRATE

ZE2.JumpSprintFatigue = 17*FRACUNIT

ZE2.MaxKarma = 500

ZE2.GS_PREGAME = 1
ZE2.GS_GAME = 2
ZE2.GS_FINISH = 3

ZE2.Vote = {}
ZE2.Game = {}

function ZE2.GameReset(map)
	local game = ZE2.Game
	game.state_list = {"pregame", "game", "finish"}
	game.state = 1
	game.state_tics = 0
	if not game.queueround then 
		game.round = 1
	end
	game.maxrounds = tonumber(mapheaderinfo[map or gamemap].ze2_rounds) or ZE2.DEFAULT_ROUNDS
	game.ended = false
	game.active = false
	if game.queueround == nil then
		game.queueround = false
	end
	game.win_tics = 0
	game.team_won = 0
	game.releasetime = 0
end

function ZE2.VoteReset()
	local vote = ZE2.Vote
	vote.time_left = -1
	vote.warp_time = -1
	vote.maps = {
		{num = -1, health = 9999, onscreen = true, fuse = 0},
		{num = -1, health = 9999, onscreen = true, fuse = 0},
		{num = -1, health = 9999, onscreen = true, fuse = 0},
	}
	vote.active = true
	vote.nextmapvoted = nil
end

ZE2.GameReset()
ZE2.VoteReset()

-- so it looks better by adding idk
local newroundframe = 15*TICRATE
local newmapframe = newroundframe + 8*TICRATE

ZE2.IntermissionVars = {
	newroundframe = newroundframe;
	newmapframe = newmapframe;
	slideout_anim = 3*TICRATE/2;
}

function ZE2:GivePlayerCash(player, amount)
	if ((player.ze2.cash + amount) > player.ze2.cash_limit) then
		player.ze2.cash = player.ze2.cash_limit
		return false
	else
		player.ze2.cash = player.ze2.cash + amount
	end
	return true
end

function ZE2:TryBooleanAction(player, _table, strict)
	if not _table then
		if strict == true then
			error("Table expected")
		end
		return false
	end

	if _table.var == nil then
		if strict == true then
			error("Var expected")
		end

		return false
	end

	if (_table.condition) then
		if not player.ze2[_table.var] then
			if _table.action then
				_table.action()
			end
		end

		player.ze2[_table.var] = true
	else
		player.ze2[_table.var] = false
	end

	return true
end

addHook("NetVars", function(net)
	ZE2.Game = net($)
	ZE2.Vote = net($)
end)