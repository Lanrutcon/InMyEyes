local Addon = CreateFrame("FRAME", "InMyEyes");

--"Localing" most used functions
local select = select;
local strfind = string.find;
local pairs = pairs;

local UnitAffectingCombat = UnitAffectingCombat;

--Table with the unwanted names
local forbiddenNameplates;
--Table with all searched nameplates
local nameplatesCache = {};


-------------------------------------
--
-- Shows the nameplate.
-- Blizzard blocks actions directly to the nameplate itself, while in-combat.
-- Used when the player is in-combat.
-- @param #nameplate self : the nameplate
--
-------------------------------------
local function showNameplate(self)
	if self.healthborder then
		self.healthborder:Show();
		self.glow:SetAlpha(1);
		self.level:SetAlpha(1);
		self.skull:SetAlpha(1);
		self.raidicons:SetAlpha(1);
		self.eliteicon:SetAlpha(1);
		
		self.castbarfill:SetAlpha(1);
		self.castborder:SetAlpha(1);
		self.shield:SetAlpha(1);
		self.spellicon:SetAlpha(1);
		
		self.healthbarfill:SetAlpha(1);
	end
end


-------------------------------------
--
-- Hides the nameplate.
-- Blizzard blocks actions directly to the nameplate itself, while in-combat.
-- Used when the player is in-combat.
-- @param #nameplate self : the nameplate
--
-------------------------------------
local function hideNameplate(self)
	self.targetflash:SetTexture(nil);
	self.healthborder:Hide();
	self.glow:SetAlpha(0);
	self.name:SetText("");
	self.level:SetAlpha(0);
	self.skull:SetAlpha(0);
	self.raidicons:SetAlpha(0);
	self.eliteicon:SetAlpha(0);
	
	self.castbarfill:SetAlpha(0);
	self.castborder:SetAlpha(0);
	self.shield:SetAlpha(0);
	self.spellicon:SetAlpha(0);
	
	self.healthbarfill:SetAlpha(0);
end


-------------------------------------
--
-- Checks its name. If it's in the "forbidden list", the frame hides itself.
-- When searching the nameplates, all nameplates will have this function hooked to "OnShow" event.
-- @param #frame self : the frame that will call this function
--
-------------------------------------
local function checkName(self)
	if forbiddenNameplates[select(4, self:GetRegions()):GetText()] then
		if UnitAffectingCombat("player") then
		
			local healthbar, castbar = self:GetChildren();
			self.targetflash, self.healthborder, self.glow, self.name, self.level, self.skull, self.raidicons, self.eliteicon = self:GetRegions();
			self.castbarfill, self.castborder, self.shield, self.spellicon = castbar:GetRegions();
			self.healthbarfill = healthbar:GetRegions();
			
			hideNameplate(self);
			
		else
			self:Hide();
		end
	else
		showNameplate(self);
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
	if (event == "ZONE_CHANGED") then
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