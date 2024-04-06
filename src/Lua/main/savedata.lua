-- dont overlook this script. you will get ignored

--[[
    Todo:

    Write rubies when making an account
    Auto Log in when walking
]]--
local _rchars_ = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
local commandtoken = P_RandomKey(FRACUNIT)
local serverid

SRBZ.autologin = CV_RegisterVar({
	name = "z_autologin",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

addHook("NetVars", function(net)
    commandtoken = net($)
	serverid = net($)
end)

local function genRNGUsername(pname)
    if type(pname) == "string" then
        local extra = ""
        local extranum = 8

        for i=1,extranum do
            local nc = P_RandomKey(#_rchars_)+1
            local chartoget = _rchars_:sub(nc,nc)
            extra = $ + chartoget
        end

        return pname.."_"..extra
    end

    return
end

local function stringfile(str)
	return string.gsub(str, "%W", function(d)
		return tonumber(d) and d or "" 
	end)
end

local function GenerateRandomChars(input_extranum)
    local extra = ""
    local extranum = input_extranum == nil and 25 or input_extranum

    for i=1,extranum do
        local nc = P_RandomKey(#_rchars_)+1
        local chartoget = _rchars_:sub(nc,nc)
        extra = $ + chartoget
    end
    return extra
end

local function usernameLoggedIn(username)
	for player in players.iterate do
		if player.registered_user == username then
			print(player.name)
			return true
		end
	end
	
	return false
end

local function isRegisteredUser(player)
	return player.registered_user and player.registered
end

local function saveData(player)
	if isRegisteredUser(player) and player.rubies ~= nil then
		local gspath = "SRBZDATA/"..player.registered_user.."/gamesave.sav2"
		local gsfile = io.openlocal(gspath, "w+")
		if gsfile then
			gsfile:write(json.encode({
				rubies = player.rubies or 0,
				prevname = player.name
			}))
			gsfile:close()
		end
	end
end

local function GetServerIDFromFile()
	if isserver then
		local server_id_path = "SRBZDATA/serverid.sav2"
		
		local serveridfile = io.openlocal(server_id_path, "r")
		
		if serveridfile then
			local content = tostring(serveridfile:read("*a"))
			
			serveridfile:close()
			
			return content
		end
	end
	
	return false
end

local function SetFileServerID(input_serverid)
	if isserver then
		local server_id_path = "SRBZDATA/serverid.sav2"
		
		local serveridfile = io.openlocal(server_id_path, "w")
		
		if serveridfile then
			local content = tostring(serveridfile:read("*a"))
			
			serveridfile:write(input_serverid)
			
			serveridfile:close()
			
			return content
		end
	end
	
	return false
end

COM_AddCommand("z_registeraccount", function(player, tplayer)
	if player ~= server and tplayer then
		if player == consoleplayer then
			print("illegal parameter")
		end
		return 
	end	
	
	local target_player = player
	
	if tplayer and players[tonumber(tplayer)] and players[tonumber(tplayer)].valid then
		target_player = players[tonumber(tplayer)] 
	end
	
    if (target_player.valid) and ((gamestate == GS_LEVEL) or (gamestate == GS_INTERMISSION)) then
        if not (target_player.registered) then
		
			
            local gen_username = stringfile(genRNGUsername(target_player.name))
            local gen_password = GenerateRandomChars()
			
			
            if (isserver) or (isdedicatedserver) then -- Server
                local server_passpath = "SRBZDATA/"..gen_username.."/password.sav2"
                local server_gspath = "SRBZDATA/"..gen_username.."/gamesave.sav2"
				
                local passfile = io.openlocal(server_passpath, "w+")
                local gsfile = io.openlocal(server_gspath, "w+")
				
				if passfile then
					passfile:write(gen_password)
					passfile:close()
				end
				
				
				if gsfile then
					gsfile:write(json.encode({
						rubies = player.rubies or 0,
						prevname = player.name
					}))
					gsfile:close()
				end
            end

            if (target_player == consoleplayer) then -- Client
                local clientpath = "client/SRBZ/"..serverid.."/account.sav2"
                local file = io.openlocal(clientpath, "w+")

                local clientpath_content = ('z_loginaccount '.. '"'.. gen_username ..'" '.. '"'.. gen_password ..'"')
				if file then
					file:write(clientpath_content)
					file:close()
				end
            end

            target_player.registered_user = gen_username
            target_player.registered = true
			print(target_player.name.." created an account ("..gen_username..")")
        end
    end
end)

COM_AddCommand("z_loginaccount", function(player, username, password)
    if (player.valid) and ((gamestate == GS_LEVEL) or (gamestate == GS_INTERMISSION)) then
        if (not (player.registered) or not (player.registered_user)) and (username and password) then
			if usernameLoggedIn(username) then
				if player == consoleplayer then
					print("Someone is already logged in this account. Try again. ".."("..username..")")
				end
				return
			end
			
            if (isserver) or (isdedicatedserver) then
				local passpath = "SRBZDATA/"..username.."/password.sav2"
				local passfile = io.openlocal(passpath)
				
				if passfile then
					local passcontent = passfile:read("*a")
					if passcontent and (passcontent == password) then
						COM_BufInsertText(server, "z_importdata "..#player.." "..username.." "..commandtoken)
					end
					passfile:close()
				else
					print(player.name.." tried to login as an invalid account. Registering the user.")
					COM_BufInsertText(server, "z_registeraccount "..#player)
				end
			end
        end
    end
end)

COM_AddCommand("z_importdata", function(player, playernum, username, token) -- make data server side
    if playernum ~= nil and username ~= nil and token ~= nil and ((gamestate == GS_LEVEL) or (gamestate == GS_INTERMISSION)) then
        if (tonumber(token) == commandtoken) and players[tonumber(playernum)] and players[tonumber(playernum)].valid then
			local target_player = players[tonumber(playernum)]
			
            if ((isserver) or (isdedicatedserver)) then
                local gspath = "SRBZDATA/"..username.."/gamesave.sav2"
                local gsfile = io.openlocal(gspath, "r")

                if gsfile then
                    local gsread = gsfile:read("*a")
                    if gsread then
						local command_format = string.format("z_jsonimport %s %s %s", playernum, gsread:gsub('"',"'"), commandtoken)
						COM_BufInsertText(player, command_format)
                    end
					
					gsfile:close()
                end
			end
        end
    end
	
	if playernum and username and player == server then
		local target_player = players[tonumber(playernum)]
		
		target_player.registered_user = username
		target_player.registered = true
		print(target_player.name.." logged in as "..username)
	end
end, 1)

addHook("PlayerQuit", function(player)
	if (isserver) then
		saveData(player)
	end
end)

addHook("GameQuit", function(quitting)
    if (isserver) then
        for player in players.iterate do 
            saveData(player)
        end
    end
end)

COM_AddCommand("z_jsonimport", function(player, playernum, jsondata, token)
	if player == server and jsondata ~= nil and token ~= nil and 
	playernum ~= nil and (tonumber(token) == commandtoken) then
		if players[tonumber(playernum)] then
			local target_player = players[tonumber(playernum)]
			local decoded_data = json.decode(jsondata:gsub("'",'"'))
			
			if decoded_data.rubies ~= nil then
				player.rubies = decoded_data.rubies
			end
		end
	end
end, 1)

COM_AddCommand("z_setserverid", function(player, input_serverid, token)
	print("command sent")
	if (player ~= server) then return end
	if (tonumber(token) ~= commandtoken) then return end
	
	serverid = input_serverid
	print("new serverid: "..serverid)
end, 1)

addHook("PlayerCmd", function(player,cmd) -- auto login / register
	if (cmd.buttons or cmd.forwardmove) and (not (player.registered) 
	and not (player.registered_user)) and SRBZ.autologin.value and serverid then
		local clientpath = "client/SRBZ/"..serverid.."/account.sav2"
        local file = io.openlocal(clientpath, "r")
		if file then
			COM_BufInsertText(player, file:read("*a"))
			file:close()
		elseif (leveltime % 3) == 0 then
			COM_BufInsertText(player, "z_registeraccount")
		end
	end
end)

addHook("MapLoad", function()
	if not serverid then
		local new_serverid = GetServerIDFromFile() or GenerateRandomChars(32)
		SetFileServerID(new_serverid)
		COM_BufInsertText(server, "z_setserverid ".. new_serverid.. " ".. commandtoken)
	end
end)
