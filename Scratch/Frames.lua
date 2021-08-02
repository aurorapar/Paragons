local function makeFrameMovable(f)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("RightButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

local function CreateBar(name, previous) -- Create StatusBar with a text overlay
	local f = CreateFrame("StatusBar", "Fizzle"..name, UIParent)
	f:SetSize(500, 500)
	if not previous then
		f:SetPoint("TOP", "UIParent", "TOP", 0, -500)
		makeFrameMovable(f)
	else
		f:SetPoint("TOP", previous, "BOTTOM")
	end
	f:SetStatusBarTexture("Interface\\MainMenuBar\\UI-XP-Bar")
	f.Text = f:CreateFontString()
	f.Text:SetFontObject(GameFontNormal)
	f.Text:SetPoint("CENTER")
	f.Text:SetJustifyH("CENTER")
	f.Text:SetJustifyV("CENTER")
	return f
end

local function UpdateHealth(self, unit) -- Update the health bar
	local health = UnitHealth(unit)
	self:SetValue(health)
	self.Text:SetText(FormatLargeNumber(health) .. "/" .. FormatLargeNumber(self.healthMax))
end
local function UpdatePower(self, unit) -- Update the power bar
	local power = UnitPower(unit)
	self:SetValue(power)
	self.Text:SetText(FormatLargeNumber(power) .. "/" .. FormatLargeNumber(self.powerMax))
end
local function UpdateHealthMax(self, unit) -- Update min./max. health values
	self.healthMax = UnitHealthMax(unit)
	self:SetMinMaxValues(0, self.healthMax)
	UpdateHealth(self, unit)
end
local function UpdatePowerMax(self, unit) -- Update min./max. power values
	self.powerMax = UnitPowerMax(unit)
	self:SetMinMaxValues(0, self.powerMax)
	UpdatePower(self, unit)
end
local HealthBar = CreateBar("PlayerHealth") -- Create the health bar
HealthBar:SetStatusBarColor(0, 1, 0) -- make it green
local PowerBar = CreateBar("PlayerPower", HealthBar) -- Create the power bar (set to anchor below Health)
PowerBar:SetStatusBarColor(0, 0, 1) -- make it blue
HealthBar:SetScript("OnEvent", function(self, event, ...)
	local unit = ... -- For events starting with UNIT_ the first parameter is the unit
	if unit ~= "player" then  -- We"re only updating the player status ATM
		return -- So ignore any other unit
	end
	if event == "UNIT_HEALTH_FREQUENT" then -- Fired when health changes
		UpdateHealth(self, unit)
	elseif event == "UNIT_POWER_FREQUENT" then -- Fired when power changes
		UpdatePower(PowerBar, unit)
	elseif event == "UNIT_MAXHEALTH" then -- Fired when max. health changes
		UpdateHealthMax(self, unit)
	elseif event == "UNIT_MAXPOWER" then -- Fired when max. power changes
		UpdatePowerMax(PowerBar, unit)
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateHealthMax(HealthBar, "player") -- initialise the health bar for Player health
        UpdatePowerMax(PowerBar, "player") -- initialise the power bar for Player power
        self:SetSize(15,15)
	end
end)
HealthBar:RegisterEvent("UNIT_HEALTH_FREQUENT") -- register the events to be used
HealthBar:RegisterEvent("UNIT_POWER_FREQUENT") -- Health bar is handling events for both bars
HealthBar:RegisterEvent("UNIT_MAXHEALTH")
HealthBar:RegisterEvent("UNIT_MAXPOWER")
HealthBar:RegisterEvent("PLAYER_ENTERING_WORLD")
