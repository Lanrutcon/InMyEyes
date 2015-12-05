--todo
--
-- Clear cache on ZoneChange
--

local Addon = CreateFrame("FRAME", "InMyEyes");

local nameplatesCache = {};
local select = select;
local strfind = string.find;

local forbiddenNameplates = {
	["Bloodfang Stalker"] = true;	
}

local function searchNamePlates(frame,...)
	if not frame then
		return;
	end
	
	if not nameplatesCache[nameplate] and strfind(frame:GetName() or "","NamePlate") then
		local nameplate = frame;	
		local name = select(4, nameplate:GetRegions()):GetText();
		if forbiddenNameplates[name] then
			frame:Hide();
		end

		-- Store in cache
		nameplatesCache[nameplate] = true;
	end
	return searchNamePlates(...)
end



local total = 0;
Addon:SetScript("OnUpdate", function(self, elapsed)
	total = total + elapsed;
	if(total > 0.05) then
		total = 0;
		searchNamePlates(WorldFrame:GetChildren());
	end
end);
Addon:SetScript("OnEvent", function(self, event, ...)


end);