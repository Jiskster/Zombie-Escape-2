--[[

	Custom HUD Library by TehRealSalt Continued by Community

	-- Global script that contains extra functions for any HUD-related scripts.

	Contributors>
	* SkyDusk


	-- USAGE: Main part of customhud is the ability to creating and overwriting existing HUD items, and adding support for other HUD modifications.
	-- This helps sort out HUD conflicts that are otherwise impossible to detect without the use of this library.

--]]

local VERSIONNUM = {4, 6};
local updating = nil;

--#region library

local function warn(str)
	print("\131WARNING: \128"..str);
end

local function notice(str)
	print("\x83NOTICE: \x80"..str);
end

-- Should match hud_disable_options in lua_hudlib.c
local defaultitems = {
	{"stagetitle", "titlecard", 1},
	{"textspectator", "game", 1},
	{"crosshair", "game", 1},
	{"powerups", "game", 1},

	{"score", "game", 1},
	{"time", "game", 1},
	{"rings", "game", 1},
	{"lives", "game", 1},
	{"input", "game", 1},

	{"gameover", "game", 16},
	{"pause", "game", 16},
	{"cecho", "game", 16},
	{"chat", "game", 16},
	{"itemhunt", "game", 16},

	{"weaponrings", "game", 1},
	{"powerstones", "game", 1},
	{"teamscores", "gameandscores", 1},

	{"nightslink", "game", 1},
	{"nightsdrill", "game", 1},
	{"nightsrings", "game", 1},
	{"nightsscore", "game", 1},
	{"nightstime", "game", 1},
	{"nightsrecords", "game", 1},

	{"rankings", "scores", 1},
	{"coopemeralds", "scores", 1},
	{"tokens", "scores", 1},
	{"tabemblems", "scores", 1},

	{"intermissiontally", "intermission", 1},
	{"intermissiontitletext", "intermission", 1},
	{"intermissionmessages", "intermission", 1},
	{"intermissionemeralds", "intermission", 1},
};

--#region Version Detection

if (rawget(_G, "customhud")) then
	local oldnum = customhud.GetVersionNum();
	local numlength = max(#VERSIONNUM, #oldnum);

	local loadednum = "";
	local newnum = "";

	for i = 1,numlength do
		local num1 = oldnum[i];
		local num2 = VERSIONNUM[i];

		if (num1 == nil) then
			num1 = 0;
		end
		if (num2 == nil) then
			num2 = 0;
		end

		if (loadednum == "") then
			loadednum = "v"..num1;
		else
			loadednum = $1.."."..num1;
		end

		if (newnum == "") then
			newnum = "v"..num2;
		else
			newnum = $1.."."..num2;
		end

		if (num1 < num2) then
			updating = true;
		elseif (num1 > num2) then
			break;
		end
	end

	if (updating == nil) then
		-- Existing version is OK
		return;
	end

	if customhud.Overwritten then
		for k, overwrite in pairs(customhud.Overwritten) do
			rawset(hud, k, overwrite)
		end
	end

	notice("An old version of customhud was detected ("..loadednum.."). Switching to newer ("..newnum.."), errors may occur.");
else
	rawset(_G, "customhud", {});
end

customhud.Overwritten = {}
customhud.Overwritten["add"] = hud.add
customhud.Overwritten["addHook"] = addHook

customhud.Overwritten["enable"] = hud.enable
customhud.Overwritten["enabled"] = hud.enabled
customhud.Overwritten["disable"] = hud.disable

local hudadd =  	customhud.Overwritten["add"] ---@type function
local hudenable =  	customhud.Overwritten["enable"] ---@type function
local hudenabled = 	customhud.Overwritten["enabled"] ---@type function
local huddisable = 	customhud.Overwritten["disable"] ---@type function

local hookadd = 	customhud.Overwritten["addHook"] ---@type function

--#endregion

---@return table<number>
function customhud.GetVersionNum()
	-- Make sure you cannot overwrite the version number by copying it into another table
	-- That'd be really silly :V
	local tempNum = {};

	for k,v in ipairs(VERSIONNUM) do
		tempNum[k] = v;
	end

	return tempNum;
end

if (updating == nil) then
	customhud.hudItems = {};
end

local huditems = customhud.hudItems

if not (customhud.modPriority) then
	customhud.modPriority = {
		-- 0 = vanilla, don't use it
		-- 1 = additional hud elements in vanilla style / Legacy items
		-- 2 = simple replacements (Rings -> Coins etc.)
		-- 3 = overhauling HUD mods/total conversions

		-- DON'T USE "MOD PRIORITY" FOR CHARACTERS HUD OVERHAULS, USE CHARACTER ASSIGN SYSTEM INSTEAD!

		["vanilla"] = 0,
	}
end

customhud.hookTypes = {
	"menu",
	"gamemenu",
	"ingameintermission",
	"overlay",
	"gameandscores",
	"system",
};

customhud.vanillaHooks = {
	"game",
	"scores",
	"title",
	"titlecard",
	"intermission",
	"continue",
	"playersetup"
};

if SUBVERSION > 15 then
	table.insert(customhud.vanillaHooks, "escpanel")
end

for _, v in ipairs(customhud.vanillaHooks) do
	table.insert(customhud.hookTypes, v)
end

if not (customhud.rawAdditions) then
	customhud.rawAdditions = {}

	for _,v in ipairs(customhud.vanillaHooks) do
		customhud.rawAdditions[v] = {valid = true}
	end
end

local hooktypes = customhud.hookTypes

---@param itemName string
---@return huditem__customhud?
local function FindItem(itemName)
	for _,hook in pairs(hooktypes) do
		for _,item in pairs(huditems[hook]) do
			if (item.name == itemName) then
				return item;
			end
		end
	end

	return nil;
end

function customhud.FindItem(itemName)
	return FindItem(itemName);
end

---@class huditem__customhud
---@field name  			string
---@field funcs 			table<function>
---@field type				string|nil
---@field enabled			boolean
---@field layer				table<number>
---@field isDefaultItem 	boolean
---@field metadata			table?

---@param itemName string
---@return huditem__customhud
local function CreateNewItem(itemName)
	local newItem = {
		-- The name ID we use for this item.
		name = itemName,
		-- All of the rendering functions given to this item.
		funcs = {},
		-- The current rendering function index for this item.
		-- ("vanilla" is a reserved mod name for reverting a modded hud item
		-- back to its original state, cannot be set for custom hud items)
		type = nil,
		-- Is this hud item supposed to be visible?
		enabled = true,
		-- Determine render order of this item.
		-- Higher values are rendered on top, lower values are rendered below.
		-- (Base game items are always on the lowest layer due to limitations.)
		layer = {},
		-- Determines if this is a default HUD item defined by the game.
		-- Should never be true for custom HUD elements.
		isDefaultItem = false,
	};

	return newItem;
end

function customhud.CreateNewItem(itemName)
	return CreateNewItem(itemName);
end

for _,v in pairs(hooktypes) do
	if (huditems[v] == nil) then
		huditems[v] = {};
	end
end

if updating then
	for _,hook in pairs(hooktypes) do
		for _,item in pairs(huditems[hook]) do
			if (item.layer and type(item.layer) == "number") then
				local saved_num = item.layer;
				item.layer = {};

				if (item.funcs) then
					for k,_ in pairs(item.funcs) do
						item.layer[k] = saved_num;
					end
				end
			end

			if (not customhud.modPriority[item.type]) then
				customhud.modPriority[item.type] = 1;
			end
		end
	end
end

function customhud.UpdateHudItemStatus(item)
	-- Update status of default hud items
	if (item.isDefaultItem ~= true) then
		return;
	end

	if (item.enabled == true and item.type == "vanilla") then
		hudenable(item.name);
	else
		huddisable(item.name);
	end
end

for _,v in pairs(defaultitems) do
	if v[3] > SUBVERSION then continue end

	local itemName = v[1];
	local hookType = v[2];

	local item = customhud.FindItem(itemName);
	local updatingItem = true;

	if (item == nil) then
		item = customhud.CreateNewItem(itemName);
		updatingItem = false;
	end

	item.funcs["vanilla"] = nil;
	item.layer["vanilla"] = 0;

	if (updatingItem == false) then
		item.type = "vanilla";
		item.enabled = hudenabled(itemName);
	else
		customhud.UpdateHudItemStatus(item)
	end

	item.isDefaultItem = true;

	table.insert(huditems[hookType], item);
end


---Returns true if the HUD item has been defined already, otherwise false. customhud.SetupItem already handles HUD item collisions, so you shouldn't need to use this in most cases.
---@param itemName string Item here means "rings" "time" "score" etc.
---@return boolean
function customhud.ItemExists(itemName)
	return (FindItem(itemName) ~= nil);
end

local _hudchains = {}

---Enables a HUD item. Should completely replace instances of the base game's hud.enable, as it has support for custom HUD items.
---@param itemName string Item here means "rings" "time" "score" etc.
---@return boolean
function customhud.enable(itemName)
	local item = FindItem(itemName);
	if (item == nil) then
		return false;
	end

	if _hudchains[itemName] then
		for _,v in ipairs(_hudchains[itemName]) do
			local chain = FindItem(v);
			if (chain == nil) then
				continue;
			end

			chain.enabled = true;
		end
	end

	item.enabled = true;
	customhud.UpdateHudItemStatus(item);
	return true;
end

---Disables a HUD item. Should completely replace instances of the base game's hud.disable, as it has support for custom HUD items.
---@param itemName string Item here means "rings" "time" "score" etc.
---@return boolean
function customhud.disable(itemName)
	local item = FindItem(itemName);
	if (item == nil) then
		return false;
	end

	if _hudchains[itemName] then
		for _,v in ipairs(_hudchains[itemName]) do
			local chain = FindItem(v);
			if (chain == nil) then
				continue;
			end

			chain.enabled = false;
		end
	end

	item.enabled = false;
	customhud.UpdateHudItemStatus(item);
	return true;
end

---	Return true if a HUD item has been enabled or false if it hasn't. Should completely replace instances of the base game's hud.enabled, as it has support for custom HUD items.
---@param itemName string Item here means "rings" "time" "score" etc.
---@return boolean
function customhud.enabled(itemName)
	local item = FindItem(itemName);
	if (item == nil) then
		return false;
	end

	if (item.isDefaultItem == true)
	and (item.type == "vanilla") then
		return hudenabled(itemName);
	end

	return item.enabled;
end

---	Returns the current mod identifier that a HUD item is using. If the HUD item doesn't exist, then this returns nil.
---@param itemName string Item here means "rings" "time" "score" etc.
---@return string|nil
function customhud.CheckType(itemName)
	local item = FindItem(itemName);
	if (item == nil) then
		return nil;
	end

	return item.type;
end

---Chains custom hud type to vanilla or another custom hud type's boolean status
---* Chaining hud items won't result in chain reaction or logical loop.
---@param itemName 	string
---@param target 	string
function customhud.ChainType(itemName, target)
	-- 2 levels of checking

	if type(itemName) ~= "string" then
		warn("Invalid item string \""..itemName.."\" in customhud.ChainType");
		return;
	end

	if type(target) ~= "string" then
		warn("Invalid target item string \""..itemName.."\" in customhud.ChainType");
		return;
	end

	local item = FindItem(itemName);

	if item == nil then
		warn("Item \""..itemName.."\" was not found in customhud.ChainType");
		return;
	end

	if item.isDefaultItem then
		warn("Vanilla item \""..itemName.."\" cannot be chained in customhud.ChainType");
		return;
	end

	local targetItem = FindItem(target);

	if targetItem ~= nil then
		if _hudchains[targetItem] == nil then
			_hudchains[targetItem] = {};
		end

		table.insert(_hudchains[targetItem], itemName);
	else
		warn("Item \""..targetItem.."\" was not found in customhud.ChainType");
	end
end

---@param a any
---@param b any
---@return boolean
local function HudPriority(a, b)
	return tonumber(a.layer[a.type]) < tonumber(b.layer[b.type]);
end

local CUSHUD_NOSWITCH = 1

local function SetupItem(itemName, modName, itemFunc, hook, drawlayer, modPriority, flags)
	if (type(itemName) ~= "string") then
		warn("Invalid item string \""..itemName.."\" in customhud.SetupItem");
		return;
	end

	if (type(modName) ~= "string") then
		warn("Invalid type string \""..modName.."\" in customhud.SetupItem");
		return;
	end

	local layernum = max(type(drawlayer) == "number" and drawlayer or 0, 0) + 100

	if (type(modPriority) ~= "number") then
		modPriority = 1
	else
		modPriority = min(max(1, modPriority), 3)
	end

	if not customhud.modPriority[modName] then
		customhud.modPriority[modName] = modPriority
	end

	local item = FindItem(itemName);
	if (item == nil) then
		-- Create new item
		if (type(hook) ~= "string") then
			hook = "game";
		end

		if (huditems[hook] == nil) then
			warn("Invalid hook string \""..hook.."\" in customhud.SetupItem")
			return false;
		end

		local newItem = CreateNewItem(itemName);

		newItem.type = modName;

		newItem.funcs[modName] = itemFunc;
		newItem.layer[modName] = tonumber(layernum);

		-- Insert the new item, and then re-sort the layers
		table.insert(huditems[hook], newItem);

		return true;
	end

	-- Updating existing item
	if (item.type == modName) then
		-- Already set to this type.
		return false;
	end

	if (modName == "vanilla") and (item.isDefaultItem ~= true) then
		-- Trying to set a custom HUD item to "vanilla".
		warn("Type string \"vanilla\" is only reserved for base game HUD items in customhud.SetupItem")
		return false;
	end

	if (itemFunc ~= nil) then
		-- Change the function it uses
		item.funcs[modName] = itemFunc;
	end

	if drawlayer ~= nil then
		item.layer[modName] = layernum
	elseif item.layer[modName] == nil then
		item.layer[modName] = 100
	end

	flags = flags or 0

	if not (flags & CUSHUD_NOSWITCH) then
		if customhud.modPriority[item.type] <= customhud.modPriority[modName] then
			item.type = modName;
		end

		-- Update status
		customhud.UpdateHudItemStatus(item);
	end

	return true;
end

---Creates/Switches Item
-- * Mostly from what mod Item comes from
-- * Create Format: 	**customhud.SetupItem(itemName, modName, itemFunc, [hook : "game", layer : 0])**
-- * Switch Format: 	**customhud.SetupItem(itemName, modName)**
-- *
-- * (https://wiki.srb2.org/wiki/User:TehRealSalt/Custom_HUD_Library) **WIKI:**
-- *
-- * This function can change the display of a HUD item to another already defined type, replace an existing HUD item's drawing function, or create new custom HUD items entirely.
-- *
-- * Returns true if no errors occurred, otherwise it will return false.
---@param itemName 		string 		itemName is the name of the HUD item. This can be anything from this list of base game HUD items (https://wiki.srb2.org/wiki/Lua/Functions#Togglable_HUD_items), or a new string to define a custom HUD item.
---@param modName 		string  	modName is a string to use to identify the mod. The string "vanilla" is reserved for base game HUD items, and thus cannot be used for custom HUD items.
---@param itemFunc 		function? 	itemFunc is the function used to draw this HUD item. This can replace the need for using the base game's hud.add at all in your mod. The function format should match the HUD hook this HUD item belongs to.
---@param hook 			hudtype? 	hook is a string for the HUD hook (https://wiki.srb2.org/wiki/Lua/Functions#HUD_hooks) to use for newly created custom HUD items. There is also a special hook called "gameandscores", which has the function format of "scores", and will run regardless of the scoreboard being shown or not. The hook can be left out when not using custom HUD items, as all vanilla HUD items have a hook already defined. If not defined for custom HUD items, then this will get set to "game".
---@param drawlayer 	number?     layer is a number that determines sorting of custom HUD items. Higher numbers will be drawn on top of lower numbers. This can be left out when not using custom HUD items, as all vanilla HUD items will be put on the lowest possible layer (INT32_MIN) since there is no way to draw anything under them currently. If not defined for custom HUD items, then this will get set to 0.
---@param modPriority	number?     When setting up HUDs, this will give priority to the mod.
---@return boolean|nil
function customhud.SetupItem(itemName, modName, itemFunc, hook, drawlayer, modPriority)
	if SetupItem(itemName, modName, itemFunc, hook, drawlayer, modPriority) then
		for _,hook in pairs(hooktypes) do
			table.sort(huditems[hook], HudPriority);
		end

		return true;
	end
	return false;
end

---Only creates Item but won't switch (It is macro function, so warnings will refer to it as SetupItem)
-- * Mostly from what mod Item comes from
-- * Create Format: 	**customhud.AddItem(itemName, modName, itemFunc, [hook : "game", layer : 0])**
-- *
-- * (https://wiki.srb2.org/wiki/User:TehRealSalt/Custom_HUD_Library) **WIKI:**
-- *
-- * This function can change the display of a HUD item to another already defined type, replace an existing HUD item's drawing function, or create new custom HUD items entirely.
-- *
-- * Returns true if no errors occurred, otherwise it will return false.
---@param itemName 		string 		itemName is the name of the HUD item. This can be anything from this list of base game HUD items (https://wiki.srb2.org/wiki/Lua/Functions#Togglable_HUD_items), or a new string to define a custom HUD item.
---@param modName 		string  	modName is a string to use to identify the mod. The string "vanilla" is reserved for base game HUD items, and thus cannot be used for custom HUD items.
---@param itemFunc 		function? 	itemFunc is the function used to draw this HUD item. This can replace the need for using the base game's hud.add at all in your mod. The function format should match the HUD hook this HUD item belongs to.
---@param hook 			hudtype? 	hook is a string for the HUD hook (https://wiki.srb2.org/wiki/Lua/Functions#HUD_hooks) to use for newly created custom HUD items. There is also a special hook called "gameandscores", which has the function format of "scores", and will run regardless of the scoreboard being shown or not. The hook can be left out when not using custom HUD items, as all vanilla HUD items have a hook already defined. If not defined for custom HUD items, then this will get set to "game".
---@param drawlayer 	number?     layer is a number that determines sorting of custom HUD items. Higher numbers will be drawn on top of lower numbers. This can be left out when not using custom HUD items, as all vanilla HUD items will be put on the lowest possible layer (INT32_MIN) since there is no way to draw anything under them currently. If not defined for custom HUD items, then this will get set to 0.
---@param modPriority	number?     When setting up HUDs, this will give priority to the mod.
---@return boolean|nil
function customhud.AddItem(itemName, modName, itemFunc, hook, drawlayer, modPriority)
	if SetupItem(itemName, modName, itemFunc, hook, drawlayer, modPriority, CUSHUD_NOSWITCH) then
		for _,hook in pairs(hooktypes) do
			table.sort(huditems[hook], HudPriority);
		end

		return true;
	end
	return false;
end

---Swaps/Switches Item to Mod's counterpart if it exists, regardless of Mod Priority
--- - DO NOT USE THIS IN ANY FORCEFUL WAY.
--- - Used internally
---@param itemName 		string 		itemName is the name of the HUD item. This can be anything from this list of base game HUD items (https://wiki.srb2.org/wiki/Lua/Functions#Togglable_HUD_items), or a new string to define a custom HUD item.
---@param modName 		string  	modName is a string to use to identify the mod. The string "vanilla" is reserved for base game HUD items, and thus cannot be used for custom HUD items.
function customhud.SwapItem(itemName, modName)
	if (type(itemName) ~= "string") then
		warn("Invalid item string \""..itemName.."\" in customhud.SwapItem");
		return;
	end

	if (type(modName) ~= "string") then
		warn("Invalid type string \""..modName.."\" in customhud.SwapItem");
		return;
	end

	local item = customhud.FindItem(itemName);
	if (item) then

		if (item.funcs[modName]) then
			item.type = modName;

			for _,hook in pairs(hooktypes) do
				table.sort(huditems[hook], HudPriority);
			end
		end

		return true;
	end

	return false;
end

COM_AddCommand("customhud_force_enableitem", function(_, itemName)
	local item = customhud.FindItem(itemName);
	if (item == nil) then
		-- Item doesn't exist.
		return;
	end

	customhud.enable(itemName);
end, COM_LOCAL);

COM_AddCommand("customhud_force_disableitem", function(_, itemName)
	local item = customhud.FindItem(itemName);
	if (item == nil) then
		-- Item doesn't exist.
		return;
	end

	customhud.disable(itemName);
end, COM_LOCAL);

COM_AddCommand("customhud_force_reset", function(_)
	for _,v in pairs(defaultitems) do
		customhud.enable(v[1]);
	end
end, COM_LOCAL);

COM_AddCommand("customhud_setmod", function(_, modName)
	for _,hook in pairs(hooktypes) do
		for _,item in pairs(huditems[hook]) do
			if (item.funcs[modName])
			or (modName == "vanilla" and item.isDefaultItem == true) then
				customhud.SwapItem(item.name, modName);
				customhud.UpdateHudItemStatus(item);
			end
		end
	end
end, COM_LOCAL);

COM_AddCommand("customhud_setitem", function(_, itemName, modName)
	local item = customhud.FindItem(itemName);
	if (item == nil) then
		-- Item doesn't exist.
		return;
	end

	customhud.SwapItem(itemName, modName);
end, COM_LOCAL);

COM_AddCommand("customhud_getitemtype", function(_, itemName)
	local item = customhud.FindItem(itemName);
	if (item == nil) then
		-- Item doesn't exist.
		return;
	end

	print(item.type)
end, COM_LOCAL);

---creates and returns metadata of hud item
---@param itemName string
---@return table?
function customhud.metadata(itemName)
	if type(itemName) ~= "string" then
		warn("Invalid item string \""..itemName.."\" in customhud.etadata");
		return;
	end

	local item = FindItem(itemName);

	if item == nil then
		warn("Item \""..itemName.."\" was not found in customhud.metadata");
		return;
	else
		if item.metadata == nil then
			item.metadata = {};
		end

		return item.metadata;
	end
end

local hudMeta = {
	easeInOut = true,
	hide = false,

	margin_left = 0,
	margin_right = 0,
	margin_top = 0,
	margin_bottom = 0,
}

---gets hud system meta variables, like margins, ease in and out, hiding the hud etc.
---@return table
function customhud.GetMeta()
	return hudMeta;
end

function customhud.ValidateRawsFunc(hook, path, archive, funcname, line, funcsource)
	if not debug then 
		warn("Vanilla debug library is missing. Please update to 2.2.16 to use this functionality.");
		return true;
	end

	if type(hook) ~= "string" then
		local datatype = type(hook);
		warn("Expected: string; Got: "..datatype.." in "..funcsource.."'s hook parameter");
		return true;
	end

	if type(path) ~= "string" then
		local datatype = type(path);
		warn("Expected: string; Got: "..datatype.." in "..funcsource.."'s path parameter");
		return true;
	end

	if archive and type(archive) ~= "string" then
		local datatype = type(archive);
		warn("Expected: string; Got: "..datatype.." in "..funcsource.."'s archive parameter");
		return true;
	end

	if funcname and type(funcname) ~= "string" then
		local datatype = type(funcname);
		warn("Expected: string; Got: "..datatype.." in "..funcsource.."'s name parameter");
		return true;
	end

	if line and type(line) ~= "string" then
		local datatype = type(line);
		warn("Expected: string; Got: "..datatype.." in "..funcsource.."'s line parameter");
		return true;
	end

	if not customhud.rawAdditions[hook] then
		warn("Hook type \""..hook.."\" is invalid in "..funcsource);
		return true;
	end

	return false
end

---Identifies raw Custom HUDs by parameters
---@param hook string
---@param path string
---@param archive string?
---@param funcname string?
---@param line string?
---@return boolean?
function customhud.CheckRaws(hook, path, archive, funcname, line)
	if customhud.ValidateRawsFunc(hook, path, archive, funcname, line, "customhud.CheckRaws") then
		return;
	end

	local defaultarchivebool = (archive == nil);
	local defaultnamebool = (funcname == nil);
	local defaultlinebool = (line == nil);

	for _,item in ipairs(customhud.rawAdditions[hook]) do
		local _debuginfo = item[3];

		if not _debuginfo then
			continue;
		end

		local pathmatch = false;
		local namematch   = false;
		local archivematch = false;
		local linematch   = false;

		local _path = _debuginfo.path;

		if path == _path then
			pathmatch = true;
		end

		if defaultarchivebool then
			archivematch = true;
		else
			local _archive = _debuginfo.archive;

			if archive == _archive then
				archivematch = true;
			end
		end

		if defaultnamebool then
			namematch = true;
		else
			local _name = _debuginfo.name;

			if funcname == _name then
				namematch = true;
			end
		end

		if defaultlinebool then
			linematch = true;
		else
			local _line = _debuginfo.line;

			if line == _line then
				linematch = true;
			end
		end

		if pathmatch and archivematch and namematch and linematch then
			return item[2];
		end
	end
end

---Identifies raw Custom HUDs by parameters and toggles it
---@param hook string
---@param path string
---@param archive string?
---@param funcname string?
---@param line string?
---@param toggle boolean
function customhud.ToggleRaws(hook, path, archive, funcname, line, toggle)
	if customhud.ValidateRawsFunc(hook, path, archive, funcname, line, "customhud.ToggleRaws") then
		return;
	end

	if type(toggle) ~= "boolean" then
		local datatype = type(toggle);
		warn("Expected: boolean; Got: "..datatype.." in customhud.ToggleRaws's toggle parameter");
		return;
	end

	local defaultarchivebool = (archive == nil);
	local defaultnamebool = (funcname == nil);
	local defaultlinebool = (line == nil);

	for _,item in ipairs(customhud.rawAdditions[hook]) do
		local _debuginfo = item[3];

		if not _debuginfo then
			continue;
		end

		local pathmatch = false;
		local namematch   = false;
		local archivematch = false;
		local linematch   = false;

		local _path = _debuginfo.path;

		if path == _path then
			pathmatch = true;
		end

		if defaultarchivebool then
			archivematch = true;
		else
			local _archive = _debuginfo.archive;

			if archive == _archive then
				archivematch = true;
			end
		end

		if defaultnamebool then
			namematch = true;
		else
			local _name = _debuginfo.name;

			if funcname == _name then
				namematch = true;
			end
		end

		if defaultlinebool then
			linematch = true;
		else
			local _line = _debuginfo.line;

			if line == _line then
				linematch = true;
			end
		end

		if pathmatch and archivematch and namematch and linematch then
			item[2] = toggle;
		end
	end
end

COM_AddCommand("customhud_rawlist", function(_, hook)
	local count = 0
	
	if type(hook) ~= "string" then
		local datatype = type(hook);
		warn("Expected: string; Got: "..datatype.." in customhud.ToggleRaws's hook parameter");
		return true;
	end

	if not customhud.rawAdditions[hook] then
		warn("Hook type \""..hook.."\" is invalid in customhud.ToggleRaws");
		return true;
	end	

	for _,item in ipairs(customhud.rawAdditions[hook]) do
		count = $ + 1

		local _debuginfo = item[3];

		print()
		print("RAW #"..count)
		print("-----")
		print("function name: "..(_debuginfo.name))
		print("function archive: "..(_debuginfo.archive))
		print("function path: "..(_debuginfo.path))
		print("function line: "..(_debuginfo.line))
		print()
	end
end, COM_LOCAL);

if hud.cachePatch then
	---* In case of hud.cachePatch existing, just caches patches right away, when not queues strings for patching at first oppurnity.	
	---* This is more so cross version solution, as cachePatch was made standalone from hook's own videolib
	---@param container table<string>
	---@return table<patch_t>
	function customhud.PreCache(container)
		for k,v in ipairs(container) do
			container[k] = hud.cachePatch(v)
		end
	end

	function customhud.CacheQueue(v)
		if customhud.cachingQueue then
			for _,containers in ipairs(customhud.cachingQueue) do
				for k,item in ipairs(containers) do
					containers[k] = v.cachePatch(item)
				end
			end

			customhud.cachingQueue = {}
		end
	end
else
	customhud.cachingQueue = {}

	function customhud.PreCache(container)	
		table.insert(customhud.cachingQueue, container)
		return container ---@cast container patch_t
	end

	function customhud.CacheQueue()
		return
	end
end

--#endregion
--#region Hooks

local unpack = unpack
local ipairs = ipairs
local pairs = pairs

local function RunRawHooks(hook, v, ...)
	if (customhud.rawAdditions[hook] == nil) then
		return;
	end

	local arg = {...};

	for _,item in ipairs(customhud.rawAdditions[hook]) do
		local status = item[2]

		if status == true and item[1] then
			local func = item[1]
			func(v, unpack(arg));
		end
	end
end

local function RunCustomHooks(hook, v, ...)
	if (huditems[hook] == nil) then
		return;
	end

	local arg = {...};

	for _,item in pairs(huditems[hook]) do
		if (item.enabled == false) then
			continue;
		end

		if (item.type == nil) then
			continue;
		end

		local func = item.funcs[item.type];
		if (func == nil) then
			continue;
		end

		func(v, unpack(arg));
	end
end

hudadd(function(v, player, camera)
	customhud.CacheQueue(v)

	RunRawHooks("game", v, player, camera);
	RunCustomHooks("overlay", v, player, camera);

	RunCustomHooks("game", v, player, camera);
	RunCustomHooks("gameandscores", v);

	RunCustomHooks("ingameintermission", v, player, camera);

	RunCustomHooks("gamemenu", v, player);
	RunCustomHooks("menu", v, player);

	RunCustomHooks("system", v);
end, "game");

hudadd(function(v)
	RunRawHooks("scores", v);

	RunCustomHooks("scores", v);
	RunCustomHooks("gameandscores", v);
	RunCustomHooks("menu", v);

	RunCustomHooks("system", v);
end, "scores");

hudadd(function(v)
	customhud.CacheQueue(v)

	RunRawHooks("title", v);
	RunCustomHooks("title", v);

	RunCustomHooks("system", v);
end, "title");

hudadd(function(v, player, ticker, endtime)
	customhud.CacheQueue(v)

	RunRawHooks("titlecard", v, player, ticker, endtime);
	RunCustomHooks("titlecard", v, player, ticker, endtime);

	RunCustomHooks("system", v);
end, "titlecard");

hudadd(function(v)
	customhud.CacheQueue(v)

	RunRawHooks("intermission", v);
	RunCustomHooks("intermission", v);
end, "intermission");

hudadd(function(v, player, x, y, scale, skin, sprite2, frame, rotation, color, ticker, continuing)
	customhud.CacheQueue(v)

	RunRawHooks("continue", v, player, x, y, scale, skin, sprite2, frame, rotation, color, ticker, continuing);
	RunCustomHooks("continue", v, player, x, y, scale, skin, sprite2, frame, rotation, color, ticker, continuing);

	RunCustomHooks("system", v);
end, "continue");

hudadd(function(v, player, x, y, scale, skin, sprite2, frame, rotation, color, ticker, paused)
	customhud.CacheQueue(v)

	RunRawHooks("playersetup", v, player, x, y, scale, skin, sprite2, frame, rotation, color, ticker, paused);
	RunCustomHooks("playersetup", v, player, x, y, scale, skin, sprite2, frame, rotation, color, ticker, paused);

	RunCustomHooks("system", v);
end, "playersetup");

if SUBVERSION > 15 then
	hudadd(function(v, x, y, width, height)
		customhud.CacheQueue(v)

		RunRawHooks("escpanel", v, x, y, width, height);
		RunCustomHooks("escpanel", v, x, y, width, height);

		RunCustomHooks("system", v);
	end, "escpanel");
end

rawset(hud, "enable",  customhud.enable)
rawset(hud, "enabled", customhud.enabled)
rawset(hud, "disable", customhud.disable)

local function fin_lastpathsep(path)
    local revpath = string.reverse(path)
    local slash = string.find(revpath, "/", 1, true)
    local backslash = string.find(revpath, "\\", 1, true)

    local pos = 0
    if slash and backslash then
        pos = min(slash, backslash)
    elseif slash then
        pos = slash
    elseif backslash then
        pos = backslash
    end

    if pos > 0 then
        return #path - pos + 1
    else
        return 0
    end
end

local function parse_debugsource(source)
    local realsource = string.sub(source, 2)

    local archive = nil
    local rawpath = nil

    local index = string.find(realsource, "|", 1, true)

    if index then
        local fullpath = string.sub(realsource, 1, index - 1)

		rawpath = string.sub(realsource, index + 1)
        local lastslash = fin_lastpathsep(fullpath)

        if lastslash > 0 then
            archive = fullpath:sub(lastslash + 1)
        else
            archive = fullpath
        end
    else
        rawpath = realsource
    end


    local scriptpath = rawpath

    if not archive then
        local filepathslash = fin_lastpathsep(rawpath)
        if filepathslash > 0 then
            scriptpath = string.sub(rawpath, filepathslash + 1)
        end
    end

    return archive, scriptpath
end

local function newhud_add(func, hook, ...)
	local _hook = hook or "game"

	if type(func) ~= "function" then 
		warn("While adding HUD hook non-drawer-function was provided.");
		return
	end

	if type(_hook) ~= "string" then 
		warn("Invalid hook type provided \""..type(hook).."\"");
		return
	end

	if customhud.rawAdditions[_hook] then
		local debuginfo = {
			name =    "none",
			path =	  "unknown",
			archive = "unknown",
			line =    "unknown"
		}

		if debug then
			local info = debug.getinfo(func, "nSl")
			local archive, scriptpath = "unknown", "unknown"

			if info.source then
				local _archive, _scriptpath = parse_debugsource(info.source)

				archive = _archive or $
				scriptpath = _scriptpath or $
			end

			debuginfo = {
				name = info.name or "none",
				path = scriptpath,
				archive = archive,
				line = info.linedefined or "unknown"
			}
		end
		
		table.insert(customhud.rawAdditions[_hook], {func, true, debuginfo})
	else
		hudadd(func, hook, ...)
	end
end

rawset(hud, "add", newhud_add)

rawset(_G, "addHook", function(_type, func, specifics, ...)
	if _type == "HUD" then
		newhud_add(func, specifics, ...)
	else
		hookadd(_type, func, specifics, ...)
	end
end)

--#endregion
--#region Fonts -- Currently unsupported

if not customhud.fonts then
	customhud.fonts = {};
end

local fonts = customhud.fonts;

local function CreateNewFont(fontName, kerning, space, mono)
	if (type(kerning) ~= "number") then
		kerning = 0;
	end

	if (type(space) ~= "number") then
		space = 4;
	end

	local newFont = {
		name = fontName,
		kerning = kerning,
		space = space,
		mono = nil,
		patches = {},
		number = false,
	};

	if (type(mono) == "number") then
		newFont.mono = mono;
	end

	return newFont;
end

function customhud.CreateNewFont(fontName, kerning, space, mono)
	return CreateNewFont(fontName, kerning, space, mono)
end

---Defines a new font. This should be done before using any of the font functions.
---@param fontName string is the font's prefix. This is used for determining the patch to use, which is in xxxxxyyy, where x is the font prefix and y is the ASCII decimal of each character. This cannot be longer than 5 characters.
---@param kerning number? is the spacing between letters. Negative numbers makes letters overlap, positive numbers are spaced farther apart. Defaults to 0.
---@param space number? is how many pixels a space should be. Defaults to 4
---@param mono number? makes all characters mono-spaced instead of being based on each patch size. Defaults to nil, for a variable-width font.
---@return table|nil
function customhud.SetupFont(fontName, kerning, space, mono)
	if (type(fontName) ~= "string") then
		warn("Invalid font name \""..fontName.."\" in customhud.SetupFont");
		return;
	end

	if (fontName:find(" ")) then
		warn("Font name \""..fontName.."\" cannot have spaces in customhud.SetupFont");
		return;
	end

	if (fontName:len() > 5) or (fontName:len() < 1) then
		warn("Bad font name length in customhud.SetupFont");
		return;
	end

	fonts[fontName] = CreateNewFont(fontName, kerning, space, mono);
end

---Returns font data from customhud.SetupFont or customhud.SetupNumberFont.
---@param fontName string
---@return table
function customhud.GetFont(fontName)
	return fonts[fontName];
end

local function FontPatchNameDirect(fontName, charByte)
	return fontName .. string.format("%03d", charByte);
end

function customhud.FontPatchNameDirect(fontName, charByte)
	return FontPatchNameDirect(fontName, charByte);
end

local function FontPatchName(v, fontName, charByte)
	local patchName = FontPatchNameDirect(fontName, charByte);

	local capsOffset = 32;
	if (charByte >= 65 and charByte <= 90 and not v.patchExists(patchName)) then
		charByte = $1 + capsOffset;
		patchName = FontPatchNameDirect(fontName, charByte);
	elseif (charByte >= 97 and charByte <= 122 and not v.patchExists(patchName)) then
		charByte = $1 - capsOffset;
		patchName = FontPatchNameDirect(fontName, charByte);
	end

	return patchName;
end

function customhud.FontPatchName(v, fontName, charByte)
	return FontPatchName(v, fontName, charByte);
end

local function NumberPatchName(v, fontName, charByte)
	local charNumber = charByte - 48;
	if (charNumber >= 0 and charNumber <= 9) then
		return fontName .. string.format("%d", charNumber);
	end
	return "";
end

function customhud.NumberPatchName(v, fontName, charByte)
	return NumberPatchName(v, fontName, charByte);
end

---Caches and returns a specific character patch from font data.
---@param v 	   videolib
---@param font 	   table
---@param charByte number
---@return patch_t|nil
function customhud.GetFontPatch(v, font, charByte)
	if not (font.patches[charByte] and font.patches[charByte].valid) then
		local patchName = "";

		if (font.number == true) then -- Number-only font
			patchName = NumberPatchName(v, font.name, charByte);
		else
			patchName = FontPatchName(v, font.name, charByte);
		end

		if (patchName == "") then
			return nil;
		end

		-- Try to create a new patch & cache it
		if (v.patchExists(patchName)) then
			font.patches[charByte] = v.cachePatch(patchName);
		end
	end

	return font.patches[charByte];
end

---Caches and returns a specific character patch from font data.
---@param v 	   videolib
---@param str 	   string
---@param fontName string?
---@param scale    number?
---@return number|nil
function customhud.CustomFontStringWidth(v, str, fontName, scale)
	if not (type(str) == "string") then
		warn("No string given in customhud.CustomFontStringWidth");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontStringWidth");
		return;
	end

	local font = customhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	local strwidth = 0;
	if (str == "") then
		return strwidth;
	end

	if (type(scale) ~= "number") then
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale ~= nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale ~= nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono ~= nil and scale ~= nil) then
		mono = $1 * scale;
	end

	for i = 1,str:len() do
		local charByte = str:byte(i,i);
		local patch = customhud.GetFontPatch(v, font, charByte);

		if (patch and patch.valid) then
			local charWidth = patch.width;

			if (mono ~= nil) then
				charWidth = mono;
			elseif (scale ~= nil) then
				charWidth = $1 * scale;
			end

			strwidth = $1 + charWidth + kerning;
		else
			strwidth = $1 + space;
		end
	end

	return strwidth;
end

---Draws a single character of a custom font. Returns the X position to draw another character at, if trying to draw an entire string.
---@param v videolib
---@param x fixed_t|number
---@param y fixed_t|number
---@param charByte number
---@param fontName string
---@param flags number
---@param scale fixed_t
---@param color number
---@return number|nil
function customhud.CustomFontChar(v, x, y, charByte, fontName, flags, scale, color)
	if not (type(charByte) == "number") then
		warn("No character byte given in customhud.CustomFontChar");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontChar");
		return;
	end

	local font = customhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	if (type(scale) ~= "number") then
		scale = nil;
	end

	if (type(flags) ~= "number") then
		flags = 0;
	end

	local kerning = font.kerning;
	if (scale ~= nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale ~= nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono ~= nil and scale ~= nil) then
		mono = $1 * scale;
	end

	local wc = nil;
	if (color) then
		wc = v.getColormap(TC_DEFAULT, color);
	end

	local patch = customhud.GetFontPatch(v, font, charByte);
	if (patch and patch.valid) then
		if (scale ~= nil) then
			v.drawScaled(x, y, scale, patch, flags, wc);
		else
			v.draw(x, y, patch, flags, wc);
		end
	end

	local nextx = x;
	if (patch and patch.valid) then
		local charWidth = patch.width;

		if (mono ~= nil) then
			charWidth = mono;
		elseif (scale ~= nil) then
			charWidth = $1 * scale;
		end

		nextx = $1 + charWidth + kerning;
	else
		nextx = $1 + space;
	end

	return nextx;
end

---Draws a string in a custom font. If scale is not nil, then the X/Y coordinates are expected to be in fixed point scale, otherwise they are expected to be integers. color uses skincolors rather than the base games' text colors.
---@param v videolib
---@param x fixed_t|number
---@param y fixed_t|number
---@param str number
---@param fontName string
---@param flags number
---@param align string
---@param scale fixed_t
---@param color number
function customhud.CustomFontString(v, x, y, str, fontName, flags, align, scale, color)
	if not (type(str) == "string") then
		warn("No string given in customhud.CustomFontString");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontChar");
		return;
	end

	local font = customhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	if (type(scale) ~= "number") then
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale ~= nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale ~= nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono ~= nil and scale ~= nil) then
		mono = $1 * scale;
	end

	local wc = nil;
	if (color) then
		wc = v.getColormap(TC_DEFAULT, color);
	end

	local nextx = x;

	if (align == "right") then
		nextx = $1 - customhud.CustomFontStringWidth(v, str, fontName, scale);
	elseif (align == "center") then
		nextx = $1 - (customhud.CustomFontStringWidth(v, str, fontName, scale) / 2);
	end

	for i = 1,str:len() do
		local nextByte = str:byte(i,i);
		nextx = customhud.CustomFontChar(v, nextx, y, nextByte, fontName, flags, scale, color);
	end
end

---Defines a new number font. Unlike standard fonts, the font prefix can be up to 7 characters long, but it only uses 0-9 as bytes to represent numbers. Generally, it's recommended to use customhud.SetupFont instead, as this is mostly only for backwards compatibility with some older mods' number font names.
---@param fontName string
---@param kerning number?
---@param space number?
---@param mono number?
function customhud.SetupNumberFont(fontName, kerning, space, mono)
	if (type(fontName) ~= "string") then
		warn("Invalid font name \""..fontName.."\" in customhud.SetupNumberFont");
		return;
	end

	if (fontName:find(" ")) then
		warn("Font name \""..fontName.."\" cannot have spaces in customhud.SetupNumberFont");
		return;
	end

	if (fontName:len() > 7) or (fontName:len() < 1) then
		warn("Bad font name length in customhud.SetupNumberFont");
		return;
	end

	local newFont = CreateNewFont(fontName, kerning, space, mono);
	newFont.number = true;

	fonts[fontName] = newFont;
end

---Returns the width of a number if it were drawn in a custom font. padding is the number of padding zeroes to use, set to nil for no padding.
---@param v 		videolib
---@param num 		number
---@param fontName 	string
---@param padding 	string?
---@param scale 	fixed_t?
---@return number|nil
function customhud.CustomNumWidth(v, num, fontName, padding, scale)
	local str = "";

	if (padding ~= nil) then
		str = string.format("%0"..padding.."d", num);
	else
		str = string.format("%d", num);
	end

	return customhud.CustomFontStringWidth(v, str, fontName, scale);
end

---Draws a number in a custom number font.
---comment
---@param v videolib
---@param x fixed_t|number
---@param y fixed_t|number
---@param num number
---@param fontName string
---@param padding number?
---@param flags number?
---@param align string?
---@param scale number?
---@param color number?
---@return nil
function customhud.CustomNum(v, x, y, num, fontName, padding, flags, align, scale, color)
	local str = "";

	if (padding ~= nil) then
		str = string.format("%0"..padding.."d", num);
	else
		str = string.format("%d", num);
	end

	return customhud.CustomFontString(v, x, y, str, fontName, flags, align, scale, color);
end

--#endregion