
local MAX_LEVEL = 70
local lastNotification = 0

local azerothInstanceIDs = {0, 1, 48, 189, 289, 230, 229, 429, 90, 349, 389, 129, 47, 1001, 1004, 1007, 33, 329, 36, 34, 109,
                      70, 43, 209, 469, 409, 509, 531, 1411, 1412, 1413, 1414, 1415, 1416, 1417, 1418, 1419, 1420, 1421,
                      1422, 1423, 1424, 1425, 1426, 1427, 1428, 1429, 1430, 1431, 1432, 1433, 1434, 1435, 1436, 1437,
                      1438, 1439, 1440, 1441, 1442, 1443, 1444, 1445, 1446, 1447, 1448, 1449, 1450, 1451, 1452, 1453,
                      1454, 1455, 1456, 1457, 1458, 1459, 1460, 1461, 1462, 1463, 1464}

local outlandsInstanceIDs = {564, 565, 534, 532, 544, 548, 580, 550, 530, 543, 557, 558, 585, 560, 556, 555, 552, 269, 542,
                       553, 554, 540, 547, 545, 546, 1941, 1942, 1943, 1944, 1945, 1946, 1947, 1948, 1949, 1950, 1951,
                       1952, 1953, 1954, 1955, 1956, 1957}

local function in_array(haystack, needle)
    for k,v in ipairs(haystack) do
        if needle == v then
            return true
        end
    end
    return false
end

local function dumpTable(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dumpTable(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local function getInstanceID()
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID,
        instanceGroupSize, LfgDungeonID = GetInstanceInfo()
    return instanceID
end

local function isElite(status)
    return string.find(status, "elite") or string.find(status, "boss")
end

local function getXPReward(levelDifference, eliteCheck)

    local reward = 45
    if in_array(outlandsInstanceIDs, getInstanceID()) then
        reward = 235
    end

    if levelDifference == 0 then
        reward = reward + MAX_LEVEL * 5
    elseif levelDifference > 0 then
        reward = math.ceil((reward + MAX_LEVEL * 5) * (1 + 0.05 * levelDifference))
    elseif levelDifference < 0 then
        reward = (reward + MAX_LEVEL * 5) * (1 - math.abs(levelDifference)/17)
    end

    if isElite(eliteCheck) then
        reward = reward * 2
    end

    local partySize = max(GetNumGroupMembers(), 1)
    reward = math.floor(reward * math.ceil(1+ (partySize/100) - 0.1) / partySize)

    return reward
end

local function checkLevelUp()
    local neededXP = (8 * ParagonsLevel + 5 * (ParagonsLevel-30)) * (235 + (5*ParagonsLevel))
    if ParagonsXP > neededXP then
        ParagonsLevel = ParagonsLevel + 1
        ParagonsXP = ParagonsXP - neededXP
        PlaySound(888);
    end
end

local function giveParagonXP(xp, reason)
    if ParagonsLevel == nil then ParagonsLevel = MAX_LEVEL end
    if ParagonsXP == nil then ParagonsXP = 0 end
    reason = reason or "killing a mob"
    if math.floor(GetTime()) - lastNotification > 10 then
        lastNotification = math.floor(GetTime())
        print("You have earned " .. xp .. " Paragon XP for " .. reason)
    end

    ParagonsXP = ParagonsXP + xp
    checkLevelUp()

end

local function trackKills(guidTarget)
    if dumpTable == nil then return end
    if UnitLevel("player") == MAX_LEVEL then
        local level = guidTarget['level']
        local name = guidTarget['name']
        local elite = guidTarget['elite']
        if elite ~= 'trivial' then
            local reason = "killing a mob, " .. name
            if isElite(elite) then
                reason = "killing an " .. elite .. ", " .. name
            end
            giveParagonXP(getXPReward(level - MAX_LEVEL, elite), reason)
        end
    end
end

local targetedPrefixEvents = {'SWING', 'RANGE', 'SPELL', 'DAMAGE'}
local guidInfo = {}
local function readCombatLog(...)
    local _, subEvent, _, sourceGUID, sourceName, _, _, destinationGUID, targetName, _, _, _, _, _, _, _, level = ...

    for i=1, #targetedPrefixEvents do
        if string.find(subEvent, targetedPrefixEvents[i]) then
            if UnitGUID("player") == sourceGUID then
                if UnitGUID("target") == destinationGUID and not UnitIsPlayer("target") then
                    if not UnitIsTapDenied("target") then
                        if guidInfo[destinationGUID] == nil then
                            guidInfo[destinationGUID] = {
                                ['tapped'] = true;
                                ['level'] = UnitLevel("target");
                                ['name'] = targetName;
                                ['elite'] = UnitClassification("target")
                            }
                        end
                    end
                end
            end
        end
    end

    if(subEvent=='UNIT_DIED') then
        if guidInfo[destinationGUID] ~= nil then
            if guidInfo[destinationGUID]['tapped'] == true then
                trackKills(guidInfo[destinationGUID])
            end
        end
    end
end

local function loadStuff()

end

local KillEventFrame = CreateFrame("frame", "EventFrame")
KillEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
KillEventFrame:RegisterEvent("ADDON_LOADED")
KillEventFrame:SetScript("OnEvent", function(self, event)
    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        readCombatLog(CombatLogGetCurrentEventInfo())
    elseif event == 'ADDON_LOADED'  then
        loadStuff()
    end
end)
 "[string "pets=['Infernal', 'Ruljub'] x=UnitName("pet") print(x) for i=1,..."]:1: unexpected symbol near '['"
