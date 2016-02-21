local Addon = CreateFrame("FRAME", "InMyEyes");

--"Localing" most used functions
local select = select;
local strfind = string.find;
local pairs = pairs;

--Table with the unwanted names
local forbiddenNameplates;
--Table with all searched nameplates
local nameplatesCache = {};


-------------------------------------
--
-- Checks its name. If it's in the "forbidden list", the frame hides itself.
-- When searching the nameplates, all nameplates will have this function hooked to "OnShow" event.
-- @param #frame self : the frame that will call this function
--
-------------------------------------
local function checkName(self)
	if forbiddenNameplates[select(4, self:GetRegions()):GetText()] then
		self:Hide();
	end
end


-------------------------------------
--
-- Searches for nameplates that WorldFrame contains.
--
-------------------------------------
local function searchNamePlates()
	
	local worldFrames = { WorldFrame:GetChildren() };

	for num, frame in pairs(worldFrames) do
		if not nameplatesCache[frame] and strfind(frame:GetName() or "","NamePlate") then
			frame:HookScript("OnShow", checkName)			
			-- Store in cache
			nameplatesCache[frame] = true;
		end
	end
end


SLASH_InMyEyes1, SLASH_InMyEyes2 = "/inmyeyes", "/ime";

-------------------------------------
--
-- Slash command function.
-- @param #string cmd: the command that player calls
--
-------------------------------------
function SlashCmd(cmd)
	if (cmd:match"add ") then
		forbiddenNameplates[string.sub(cmd, strfind(cmd, "add ")+4)] = true;
		for frame, _ in pairs(nameplatesCache) do
			checkName(frame);
		end
	elseif (cmd:match"remove ") then
		forbiddenNameplates[string.sub(cmd, strfind(cmd, "remove ")+7)] = nil;
	elseif (cmd:match"list") then
		SendSystemMessage("InMyEyes - The hidden nameplates are:");
		for k,_ in pairs(forbiddenNameplates) do
			SendSystemMessage(k);
		end
	else
		SendSystemMessage("InMyEyes - Commands:");
		SendSystemMessage("/ime add NPC's name");
		SendSystemMessage("/ime remove NPC's name");
		SendSystemMessage("/ime list");
	end
end

SlashCmdList["InMyEyes"] = SlashCmd;


local numChidlren;
-------------------------------------
--
-- Addon SetScript OnUpdate
-- Calls "searchNamePlates" function whenever the WorldFrame gains/loses a frame
--
-------------------------------------
Addon:SetScript("OnUpdate", function(self, elapsed)
	if (WorldFrame:GetNumChildren() ~= numChidlren) then
		numChidlren = WorldFrame:GetNumChildren();
		searchNamePlates();
	end
end);


-------------------------------------
--
-- Addon SetScript OnEvent
-- Clears the cache when player changes zones and handles the SavedVariables.
--
-- Handled events:
-- "ZONE_CHANGED"
-- "VARIABLES_LOADED"
--
-------------------------------------
Addon:SetScript("OnEvent", function(self, event, ...)
	if(event == "ZONE_CHANGED") then
		wipe(nameplatesCache);
		searchNamePlates();
	else --VARIABLES_LOADED
		if type(InMyEyesSV) ~= "table" then
			InMyEyesSV = {};
			InMyEyesSV[UnitName("player")] = {};
		elseif(not InMyEyesSV[UnitName("player")]) then
			InMyEyesSV[UnitName("player")] = {};
		end
		forbiddenNameplates = InMyEyesSV[UnitName("player")];
	end
end);

Addon:RegisterEvent("VARIABLES_LOADED");
Addon:RegisterEvent("ZONE_CHANGED");