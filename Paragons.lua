
local targetedPrefixEvents = {'SWING', 'RANGE', 'SPELL'}
local isTappedByPlayer = {}

local function trackKills(callback, event, ...)
    print("Xp gained")
end


local KillEventFrame = CreateFrame("frame", "EventFrame")
KillEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
KillEventFrame:RegisterEvent("PLAYER_XP_UPDATE")
KillEventFrame:SetScript("OnEvent", function(self, event)
	self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
end)

function KillEventFrame:COMBAT_LOG_EVENT_UNFILTERED(...)

    if event == 'PLAYER_XP_UPDATE' then
        trackKills(...)
        return
    end

	local _, subEvent, _, sourceGUID, sourceName, _, _, destinationGUID, targetName = ...
	local spellId, spellName, spellSchool
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand


    for i=1, #targetedPrefixEvents do
        if string.find(subEvent, targetedPrefixEvents[i]) then
            if UnitGUID("player") == sourceGUID then
                if UnitGUID("target") == destinationGUID then
                    if not UnitIsTapDenied("target") then
                        isTappedByPlayer.destinationGUID = true
                    end
                end
            end
        end
    end

    if(subEvent=='UNIT_DIED') then
        if isTappedByPlayer.destinationGUID == true then
            print("You killed your target " .. targetName)
        end
    end
end
