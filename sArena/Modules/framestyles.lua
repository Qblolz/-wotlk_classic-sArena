local addonName, addon = ...
local module = addon:CreateModule("Frame Styles")

module.defaultSettings = {
    frameStyle = "Blizz Arena",
    mirroredFrames = false,
    barTexture = "Interface\\TargetingFrame\\UI-StatusBar",
    width = 150,
    height = 32,
    healthBarHeight = 18,
    powerBarHeight = 8,
    healthBarFontSize = 12,
    powerBarFontSize = 12,
}

module.optionsTable = {
    frameStyle = {
        order = 1,
        type = "select",
        name = "Style",
        values = addon:GetLayouts(),
        set = module.UpdateSettings,
    },
    barTexture = {
        order = 2,
        type = "select",
        name = "Bar Textures",
        values = {
            ["Interface\\TargetingFrame\\UI-StatusBar"] = "Default",
            ["Interface\\RaidFrame\\Raid-Bar-Hp-Fill"] = "Raid",
        },
        set = module.UpdateSettings,
    },
    width = {
        order = 3,
        name = "Width (for custom Styles)",
        type = "range",
        min = 40,
        max = 400,
        step = 1,
        set = module.UpdateSettings,
    },
    break1 = {
		order = 4,
		type = "header",
		name = "",
	},
	healthBarHeight = {
		order = 6,
		name = "Health Bar Height (for custom Styles)",
		type = "range",
		min = 1,
		max = 50,
		step = 1,
		set = module.UpdateSettings,
	},
    powerBarHeight = {
        order = 6,
        name = "Power Bar Height (for custom Styles)",
        type = "range",
        min = 1,
        max = 50,
        step = 1,
        set = module.UpdateSettings,
    },
    healthBarFontSize = {
        order = 7,
        name = "Health Bar Font Size",
        type = "range",
        min = 0,
        max = 50,
        step = 1,
        set = module.UpdateSettings,
    },
    powerBarFontSize = {
        order = 8,
        name = "Power Bar Font Size",
        type = "range",
        min = 0,
        max = 50,
        step = 1,
        set = module.UpdateSettings,
    },
    mirroredFrames = {
        order = 9,
        type = "toggle",
        name = "Mirrored Frames",
        set = module.UpdateSettings,
    },
}

local UnitClass = UnitClass
local unpack = unpack
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local showStatusText
local statusTextDisplay

-- some of the options depend on CVARS, so we fetch them
local function FetchCVars()
    showStatusText = GetCVar("statusText")
    statusTextDisplay = GetCVar("statusTextDisplay")
end


function module:OnEvent(event, ...)
    for i = 1, MAX_ARENA_ENEMIES do
        local arenaFrame = _G["ArenaEnemyFrame"..i]
        if event == "ADDON_LOADED" then
            arenaFrame.texture = _G["ArenaEnemyFrame"..i.."Texture"]
            arenaFrame.CastingBar = _G["ArenaEnemyFrame"..i.."CastingBar"];
            arenaFrame.backgroundFrame = _G["ArenaEnemyFrame"..i.."Background"];
        elseif event == "UPDATE_SETTINGS" then
            local _layout = addon.layouts[self.db.frameStyle]
            arenaFrame.healthbar:SetStatusBarTexture(self.db.barTexture)
            arenaFrame.manabar:SetStatusBarTexture(self.db.barTexture)
            arenaFrame.CastingBar:SetStatusBarTexture(self.db.barTexture)

            if _layout then
                _layout:SetFrameStyle(arenaFrame, self.db)
            end

            local font, _, flags = arenaFrame.healthbar.TextString:GetFont()
            FetchCVars()

            if showStatusText and self.db.healthBarFontSize > 0 then
                arenaFrame.healthbar.TextString:SetFont(font, self.db.healthBarFontSize, flags)
                arenaFrame.healthbar.LeftText:SetFont(font, self.db.healthBarFontSize, flags)
                arenaFrame.healthbar.RightText:SetFont(font, self.db.healthBarFontSize, flags)
                if statusTextDisplay == "BOTH" then
                    arenaFrame.healthbar.RightText:Show()
                    arenaFrame.healthbar.LeftText:Show()
                elseif statusTextDisplay ~= "NONE" then
                    arenaFrame.healthbar.TextString:Show()
                end
            else
                arenaFrame.healthbar.TextString:Hide()
                arenaFrame.healthbar.RightText:Hide()
                arenaFrame.healthbar.LeftText:Hide()
            end

            if showStatusText and self.db.powerBarFontSize > 0 then
                arenaFrame.manabar.TextString:SetFont(font, self.db.powerBarFontSize, flags)
                arenaFrame.manabar.LeftText:SetFont(font, self.db.powerBarFontSize, flags)
                arenaFrame.manabar.RightText:SetFont(font, self.db.powerBarFontSize, flags)
                if statusTextDisplay == "BOTH" then
                    arenaFrame.manabar.RightText:Show()
                    arenaFrame.manabar.LeftText:Show()
                elseif statusTextDisplay ~= "NONE" then
                    arenaFrame.manabar.TextString:Show()
                end
            else
                arenaFrame.manabar.TextString:Hide()
                arenaFrame.manabar.RightText:Hide()
                arenaFrame.manabar.LeftText:Hide()
            end
        end
    end

    if event == "UPDATE_SETTINGS" then
        -- reshape class portrait during test mode
        if addon.testMode and addon.modules["Unit Frames"] then
            addon.modules["Unit Frames"]:OnEvent("TEST_MODE")
        end
    elseif event == "CVAR_UPDATE" then
        FetchCVars()
    elseif event == "ADDON_LOADED" then
        self:OnEvent("UPDATE_SETTINGS")
    end
end

for i = 1, MAX_ARENA_ENEMIES do
    local arenaFrame = _G["ArenaEnemyFrame"..i]

    arenaFrame.healthbar.TextString:ClearAllPoints()
    arenaFrame.healthbar.TextString:SetPoint("CENTER", arenaFrame.healthbar)
    arenaFrame.healthbar.LeftText:ClearAllPoints()
    arenaFrame.healthbar.LeftText:SetPoint("LEFT", arenaFrame.healthbar)
    arenaFrame.healthbar.RightText:ClearAllPoints()
    arenaFrame.healthbar.RightText:SetPoint("RIGHT", arenaFrame.healthbar)
    arenaFrame.manabar.TextString:ClearAllPoints()
    arenaFrame.manabar.TextString:SetPoint("CENTER", arenaFrame.manabar)
    arenaFrame.manabar.LeftText:ClearAllPoints()
    arenaFrame.manabar.LeftText:SetPoint("LEFT", arenaFrame.manabar)
    arenaFrame.manabar.RightText:ClearAllPoints()
    arenaFrame.manabar.RightText:SetPoint("RIGHT", arenaFrame.manabar)
end

local classIcons = {
    "DRUID",
    "HUNTER",
    "MAGE",
    "PALADIN",
    "PRIEST",
    "ROGUE",
    "SHAMAN",
    "WARLOCK",
    "WARRIOR",
    "DEATHKNIGHT",
}

hooksecurefunc("ArenaEnemyFrame_UpdatePlayer", function(self)
    local _, class = UnitClass(self.unit)
    local _, race = UnitRace(self.unit)

    local raceData = raceIcons[race]
    if raceData and not self.racial.Icon:GetTexture() then
        self.racial:Show()
        self.racial.Icon:SetTexture(raceData.icon)
    end

    if not self.TR.Icon:IsShown() then
        self.TR.Icon:Show()
    end

    if class then
        if addon.squareClassPortrait then
            self.classPortrait:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
        else
            self.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        end
        self.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
    end
end)

hooksecurefunc("ArenaEnemyFrame_SetMysteryPlayer", function(self)
    local i = random(1,10)

    if addon.squareClassPortrait then
        self.classPortrait:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
    else
        self.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
    end

    self.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classIcons[i]]))
end)
