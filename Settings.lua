local _, ns = ...

---------------------------------------------------------------------------
-- Minimap Icon (LibDBIcon + LibDataBroker)
---------------------------------------------------------------------------

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

if LDB then
    local cmLDB = LDB:NewDataObject("CooldownMaster", {
        type = "launcher",
        icon = "Interface\\Icons\\spell_holy_avengingwrath",
        label = "CooldownMaster",
        OnClick = function(self, button)
            if button == "LeftButton" then
                ns.ToggleUI()
            elseif button == "RightButton" then
                ns.OpenSettings()
            end
        end,
        OnTooltipShow = function(tip)
            tip:AddLine("|cFF00CCFFCooldownMaster|r")
            local active = ns.GetActiveProfileName and ns.GetActiveProfileName()
            if active then
                tip:AddLine("Active: |cFF00FF00" .. active .. "|r", 1, 1, 1)
            end
            local count = ns.GetProfileCount and ns.GetProfileCount() or 0
            if count > 0 then
                tip:AddLine("Profiles: " .. count, 0.7, 0.7, 0.7)
            end
            tip:AddLine(" ")
            tip:AddLine("|cFFCCCCCCLeft-click|r to toggle window", 0.8, 0.8, 0.8)
            tip:AddLine("|cFFCCCCCCRight-click|r to open settings", 0.8, 0.8, 0.8)
        end,
    })
    ns.cmLDB = cmLDB
end

function ns.InitMinimapIcon()
    if not LDBIcon or not ns.cmLDB then return end
    if not ns.db or not ns.db.settings then return end
    LDBIcon:Register("CooldownMaster", ns.cmLDB, ns.db.settings.minimapPos)
    if ns.db.settings.showMinimap then
        LDBIcon:Show("CooldownMaster")
    else
        LDBIcon:Hide("CooldownMaster")
    end
end

function ns.UpdateMinimapIcon()
    if not LDBIcon then return end
    if ns.db and ns.db.settings and ns.db.settings.showMinimap then
        LDBIcon:Show("CooldownMaster")
    else
        LDBIcon:Hide("CooldownMaster")
    end
end

---------------------------------------------------------------------------
-- ESC → AddOns Settings Panel
---------------------------------------------------------------------------

local settingsFrame
local settingsCategoryID

local function CreateCheckbox(parent, label, yOffset, getValue, setValue)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 16, yOffset)

    local text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    text:SetText(label)

    cb:SetScript("OnShow", function(self)
        self:SetChecked(getValue())
    end)
    cb:SetScript("OnClick", function(self)
        setValue(self:GetChecked())
    end)

    return cb, text
end

local function CreateSettingsPanel()
    if settingsFrame then return settingsFrame end

    settingsFrame = CreateFrame("Frame", "CooldownMasterSettingsPanel", UIParent)
    settingsFrame:Hide()

    -- Title
    local title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cFF00CCFFCooldownMaster|r Settings")

    local subtitle = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Manage addon behavior and appearance.")

    local yPos = -70

    -- Open CooldownMaster button
    local openBtn = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
    openBtn:SetSize(180, 28)
    openBtn:SetPoint("TOPLEFT", 16, yPos)
    openBtn:SetText("Open CooldownMaster")
    openBtn:SetScript("OnClick", function()
        ns.ToggleUI()
    end)

    yPos = yPos - 44

    -- Separator
    local sep1 = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sep1:SetPoint("TOPLEFT", 16, yPos)
    sep1:SetText("|cFFFFCC00General|r")
    yPos = yPos - 24

    -- Show Minimap Icon
    local cbMinimap = CreateCheckbox(settingsFrame, "Show minimap icon", yPos,
        function()
            return ns.db and ns.db.settings and ns.db.settings.showMinimap
        end,
        function(val)
            if ns.db and ns.db.settings then
                ns.db.settings.showMinimap = val
                ns.UpdateMinimapIcon()
            end
        end
    )
    yPos = yPos - 30

    -- Auto-switch on spec change
    local cbAutoSwitch = CreateCheckbox(settingsFrame, "Auto-switch profile on spec change", yPos,
        function()
            return ns.db and ns.db.settings and ns.db.settings.autoSwitch
        end,
        function(val)
            if ns.db and ns.db.settings then
                ns.db.settings.autoSwitch = val
            end
        end
    )
    yPos = yPos - 30

    -- Verbose chat messages
    local cbVerbose = CreateCheckbox(settingsFrame, "Verbose chat notifications", yPos,
        function()
            return ns.db and ns.db.settings and ns.db.settings.verboseChat
        end,
        function(val)
            if ns.db and ns.db.settings then
                ns.db.settings.verboseChat = val
            end
        end
    )

    local verboseHint = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    verboseHint:SetPoint("TOPLEFT", cbVerbose, "BOTTOMLEFT", 26, -2)
    verboseHint:SetText("|cFF888888Show detailed messages for profile saves, loads, and syncs.|r")

    yPos = yPos - 50

    -- Separator
    local sep2 = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sep2:SetPoint("TOPLEFT", 16, yPos)
    sep2:SetText("|cFFFFCC00Info|r")
    yPos = yPos - 24

    -- Info text
    local infoText = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    infoText:SetPoint("TOPLEFT", 16, yPos)
    infoText:SetPoint("RIGHT", settingsFrame, "RIGHT", -16, 0)
    infoText:SetJustifyH("LEFT")
    infoText:SetWordWrap(true)
    infoText:SetText(
        "CooldownMaster lets you manage Cooldown Manager layouts with " ..
        "a global Template Library and cross-character Profiles.\n\n" ..
        "Features:\n" ..
        "  - Template Library: store layouts organized by class\n" ..
        "  - Global Profiles: group layouts for all classes\n" ..
        "  - Load profile layouts for your current class\n" ..
        "  - Export/Import profiles, classes, or individual layouts\n\n" ..
        "Commands:\n" ..
        "  /cm — Toggle the main window\n" ..
        "  /cm save <name> — Save current Blizzard state as profile\n" ..
        "  /cm load <name> — Load a profile\n" ..
        "  /cm list — List all profiles and layouts\n" ..
        "  /cm help — Show all commands"
    )

    return settingsFrame
end

function ns.RegisterSettings()
    if not Settings or not Settings.RegisterCanvasLayoutCategory then return end

    local panel = CreateSettingsPanel()
    local category = Settings.RegisterCanvasLayoutCategory(panel, "CooldownMaster")
    Settings.RegisterAddOnCategory(category)
    settingsCategoryID = category:GetID()
end

function ns.OpenSettings()
    if settingsCategoryID then
        Settings.OpenToCategory(settingsCategoryID)
    else
        ns.Print("Settings panel not available. Try /cm instead.")
    end
end
