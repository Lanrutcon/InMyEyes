local Addon = CreateFrame("FRAME", "InMyEyes");

local select = select;
local strfind = string.find;

local forbiddenNameplates;
local nameplatesCache = {};


local function searchNamePlates(frame,...)
	if not frame then
		return;
	end
	
	if nameplatesCache[frame] and forbiddenNameplates[select(2, frame:GetChildren()):GetRegions():GetText()] then
		frame:Hide();
	elseif not nameplatesCache[frame] and strfind(frame:GetName() or "","NamePlate") then
	
		local _, nameFrame = frame:GetChildren():
		local name = nameFrame:GetRegions():GetText();
		
		if forbiddenNameplates[name] then
			frame:Hide();
		end

		-- Store in cache
		nameplatesCache[frame] = true;
	end
	return searchNamePlates(...);
end


SLASH_InMyEyes1, SLASH_InMyEyes2 = "/inmyeyes", "/ime";

function SlashCmd(cmd)
	if (cmd:match"add ") then
		forbiddenNameplates[string.sub(cmd, strfind(cmd, "add ")+4)] = true;
	elseif (cmd:match"remove ") then
		forbiddenNameplates[string.sub(cmd, strfind(cmd, "remove ")+7)] = nil;
	elseif (cmd:match"list") then
		SendSystemMessage("InMyEyes - The hidden nameplates are:");
		for k,_ in pairs(forbiddenNameplates) do
			SendSystemMessage(k);
		end
	end
end

SlashCmdList["InMyEyes"] = SlashCmd;


local total = 0;
Addon:SetScript("OnUpdate", function(self, elapsed)
	total = total + elapsed;
	if(total > 0.05) then
		total = 0;
		searchNamePlates(WorldFrame:GetChildren());
	end
end);


Addon:SetScript("OnEvent", function(self, event, ...)
	if(event == "ZONE_CHANGED") then
		wipe(nameplatesCache);
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