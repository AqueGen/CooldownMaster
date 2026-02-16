local _, ns = ...

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

local DEFAULT_WIDTH = 900
local DEFAULT_HEIGHT = 680
local MIN_WIDTH = 800
local MIN_HEIGHT = 500
local MAX_WIDTH = 1200
local MAX_HEIGHT = 1000
local ROW_HEIGHT = 24
local PADDING = 10

-- Column width ratios (left / center / right)
local COL_LEFT   = 0.25
local COL_CENTER = 0.40
-- COL_RIGHT fills the remainder

local COLOR_TITLE   = "|cFF00CCFF"
local COLOR_DIM     = "|cFF888888"
local COLOR_GREEN   = "|cFF00FF00"
local COLOR_RED     = "|cFFFF4444"
local COLOR_YELLOW  = "|cFFFFCC00"
local COLOR_ORANGE  = "|cFFFF9933"
local COLOR_BLUE    = "|cFF4488FF"

local CLASS_COLORS = {
    WARRIOR     = "C79C6E", PALADIN     = "F58CBA", HUNTER      = "ABD473",
    ROGUE       = "FFF569", PRIEST      = "FFFFFF", DEATHKNIGHT = "C41F3B",
    SHAMAN      = "0070DE", MAGE        = "69CCF0", WARLOCK     = "9482C9",
    MONK        = "00FF96", DRUID       = "FF7D0A", DEMONHUNTER = "A330C9",
    EVOKER      = "33937F",
    -- Lowercase aliases for case-insensitive lookup
    warrior     = "C79C6E", paladin     = "F58CBA", hunter      = "ABD473",
    rogue       = "FFF569", priest      = "FFFFFF", deathknight = "C41F3B",
    shaman      = "0070DE", mage        = "69CCF0", warlock     = "9482C9",
    monk        = "00FF96", druid       = "FF7D0A", demonhunter = "A330C9",
    evoker      = "33937F",
}

local CLASS_DISPLAY = {
    WARRIOR = "Warrior", PALADIN = "Paladin", HUNTER = "Hunter",
    ROGUE = "Rogue", PRIEST = "Priest", DEATHKNIGHT = "Death Knight",
    SHAMAN = "Shaman", MAGE = "Mage", WARLOCK = "Warlock",
    MONK = "Monk", DRUID = "Druid", DEMONHUNTER = "Demon Hunter",
    EVOKER = "Evoker",
    -- Lowercase aliases for case-insensitive lookup
    warrior = "Warrior", paladin = "Paladin", hunter = "Hunter",
    rogue = "Rogue", priest = "Priest", deathknight = "Death Knight",
    shaman = "Shaman", mage = "Mage", warlock = "Warlock",
    monk = "Monk", druid = "Druid", demonhunter = "Demon Hunter",
    evoker = "Evoker",
}

local CLASS_TOKEN_TO_ID = {
    WARRIOR = 1, PALADIN = 2, HUNTER = 3, ROGUE = 4, PRIEST = 5,
    DEATHKNIGHT = 6, SHAMAN = 7, MAGE = 8, WARLOCK = 9, MONK = 10,
    DRUID = 11, DEMONHUNTER = 12, EVOKER = 13,
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function CreateBackdropFrame(name, parent, width, height)
    local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
    f:SetSize(width, height)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileEdge = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    f:SetBackdropColor(0.08, 0.08, 0.12, 0.95)
    return f
end

local function CreateBtn(parent, text, w, h)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(w or 60, h or 20)
    btn:SetText(text)
    return btn
end

local function CreateSectionHeader(parent, text)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetText(COLOR_YELLOW .. text .. "|r")
    return header
end

--- Detect class from specTag string (e.g. "MageArcane" -> "mage")
local function DetectClass(specTag)
    if not specTag or specTag == "" then return nil end
    specTag = tostring(specTag)
    local lower = specTag:lower()
    for _, token in ipairs(ns.CLASS_TOKENS) do
        if lower:find(token:lower()) then return token:lower() end
    end
    return nil
end

--- Colorize a specTag with its class color
local function ColorizeSpecTag(specTag)
    if not specTag or specTag == "" then return COLOR_DIM .. "?|r" end
    specTag = tostring(specTag)
    local cls = DetectClass(specTag)
    if cls then return "|cFF" .. CLASS_COLORS[cls] .. specTag .. "|r" end
    return COLOR_DIM .. specTag .. "|r"
end

--- Custom dropdown widget (label + trigger button + popup list)
local function CreateCustomDropdown(parent, labelText)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(22)

    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", 0, 0)
    label:SetWidth(72)
    label:SetJustifyH("LEFT")
    label:SetText(labelText)

    local trigger = CreateFrame("Button", nil, container, "BackdropTemplate")
    trigger:SetPoint("LEFT", label, "RIGHT", 4, 0)
    trigger:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    trigger:SetHeight(22)
    trigger:SetBackdrop({
        bgFile = "Interface\\Buttons\\White8x8",
        edgeFile = "Interface\\Buttons\\White8x8",
        edgeSize = 1,
    })
    trigger:SetBackdropColor(0.1, 0.1, 0.15, 0.8)
    trigger:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)

    local selectedText = trigger:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selectedText:SetPoint("LEFT", 6, 0)
    selectedText:SetPoint("RIGHT", -16, 0)
    selectedText:SetJustifyH("LEFT")

    local arrow = trigger:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrow:SetPoint("RIGHT", -4, 0)
    arrow:SetText(COLOR_DIM .. "v|r")

    -- Popup
    local popup = CreateFrame("Frame", nil, trigger, "BackdropTemplate")
    popup:SetPoint("TOPLEFT", trigger, "BOTTOMLEFT", 0, -2)
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetBackdrop({
        bgFile = "Interface\\Buttons\\White8x8",
        edgeFile = "Interface\\Buttons\\White8x8",
        edgeSize = 1,
    })
    popup:SetBackdropColor(0.08, 0.08, 0.12, 0.98)
    popup:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)
    popup:Hide()

    -- Click-outside overlay
    local overlay = CreateFrame("Button", nil, UIParent)
    overlay:SetAllPoints(UIParent)
    overlay:SetFrameStrata("FULLSCREEN_DIALOG")
    overlay:Hide()
    overlay:SetScript("OnClick", function() popup:Hide(); overlay:Hide() end)

    -- State
    container.selectedValue = nil
    container.onChanged = nil
    container.items = {}
    container.rows = {}

    function container:SetItems(items)
        self.items = items
        for i, item in ipairs(items) do
            local row = self.rows[i]
            if not row then
                row = CreateFrame("Button", nil, popup)
                row:SetHeight(20)
                local bg = row:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(0, 0, 0, 0)
                row.bg = bg
                local txt = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                txt:SetPoint("LEFT", 6, 0)
                txt:SetJustifyH("LEFT")
                row.text = txt
                row:SetScript("OnEnter", function(r) r.bg:SetColorTexture(0.2, 0.2, 0.3, 0.6) end)
                row:SetScript("OnLeave", function(r) r.bg:SetColorTexture(0, 0, 0, 0) end)
                self.rows[i] = row
            end
            row:Show()
            row:SetPoint("TOPLEFT", popup, "TOPLEFT", 2, -2 - (i - 1) * 20)
            row:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, -2 - (i - 1) * 20)
            row.text:SetText(item.color and ("|cFF" .. item.color .. item.text .. "|r") or item.text)
            row.value = item.value
            row.displayText = item.text
            row.displayColor = item.color
            row:SetScript("OnClick", function(r)
                container:SetSelected(r.value)
                popup:Hide()
                overlay:Hide()
                if container.onChanged then container.onChanged(r.value, r.displayText) end
            end)
        end
        for i = #items + 1, #self.rows do self.rows[i]:Hide() end
        popup:SetWidth(trigger:GetWidth())
        popup:SetHeight(4 + #items * 20)
    end

    function container:SetSelected(value)
        self.selectedValue = value
        for _, item in ipairs(self.items) do
            if item.value == value then
                selectedText:SetText(item.color and ("|cFF" .. item.color .. item.text .. "|r") or item.text)
                return
            end
        end
        selectedText:SetText(COLOR_DIM .. "None|r")
    end

    function container:GetSelected()
        return self.selectedValue
    end

    trigger:SetScript("OnClick", function()
        if popup:IsShown() then
            popup:Hide()
            overlay:Hide()
        else
            popup:SetFrameLevel(trigger:GetFrameLevel() + 10)
            overlay:SetFrameLevel(popup:GetFrameLevel() - 1)
            popup:Show()
            overlay:Show()
        end
    end)

    return container
end

local function BuildClassItems()
    local items = {}
    for _, token in ipairs(ns.CLASS_TOKENS) do
        items[#items + 1] = { value = token, text = CLASS_DISPLAY[token], color = CLASS_COLORS[token] }
    end
    return items
end

local function BuildSpecItems(classToken)
    local items = { { value = nil, text = "(Any Spec)" } }
    local classID = CLASS_TOKEN_TO_ID[classToken]
    if not classID then return items end
    local numSpecs = GetNumSpecializationsForClassID(classID)
    for i = 1, numSpecs do
        local _, specName = GetSpecializationInfoForClassID(classID, i)
        if specName then
            items[#items + 1] = { value = specName, text = specName, color = CLASS_COLORS[classToken] }
        end
    end
    return items
end

--- Group a list of items by class.
--- Supports both specTag-based items and CLASS_TOKEN-based items.
--- Each item may have .class (uppercase CLASS_TOKEN) or .specTag.
--- Returns ordered list of { class=key, displayName=str, color=hex, items={...} }
local function GroupByClass(items)
    local groups = {}
    local order = {}
    for _, item in ipairs(items) do
        local cls
        -- Prefer .class (uppercase CLASS_TOKEN) for new data
        if item.class and CLASS_COLORS[item.class] then
            cls = item.class
        elseif item.specTag then
            -- Detect from specTag, convert to uppercase
            local lower = DetectClass(item.specTag)
            cls = lower and lower:upper() or "UNKNOWN"
        else
            cls = "UNKNOWN"
        end
        if not groups[cls] then
            groups[cls] = {}
            order[#order + 1] = cls
        end
        groups[cls][#groups[cls] + 1] = item
    end
    -- Sort by canonical CLASS_TOKENS order
    local tokenOrder = {}
    for i, t in ipairs(ns.CLASS_TOKENS) do tokenOrder[t] = i end
    tokenOrder["UNKNOWN"] = 999
    table.sort(order, function(a, b)
        return (tokenOrder[a] or 998) < (tokenOrder[b] or 998)
    end)
    local result = {}
    for _, cls in ipairs(order) do
        result[#result + 1] = {
            class = cls,
            displayName = CLASS_DISPLAY[cls] or cls,
            color = CLASS_COLORS[cls] or "888888",
            items = groups[cls],
        }
    end
    return result
end

local function FormatDate(ts)
    if not ts or ts == 0 then return "?" end
    return date("%m/%d", ts)
end

---------------------------------------------------------------------------
-- Frame Pool System
---------------------------------------------------------------------------

local pools = {}

local function GetOrCreateFrame(poolName, createFunc, parent)
    if not pools[poolName] then pools[poolName] = {} end
    local pool = pools[poolName]
    for _, f in ipairs(pool) do
        if not f._inUse then
            f._inUse = true
            f:SetParent(parent)
            f:Show()
            return f
        end
    end
    local f = createFunc(parent)
    f._inUse = true
    pool[#pool + 1] = f
    return f
end

local function ReleasePool(poolName)
    if not pools[poolName] then return end
    for _, f in ipairs(pools[poolName]) do
        f._inUse = false
        f:Hide()
        f:ClearAllPoints()
    end
end

---------------------------------------------------------------------------
-- Reusable Row Constructors
---------------------------------------------------------------------------

--- Class group header bar (colored class name + divider line)
local function CreateClassGroupHeader(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(20)
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", 4, 0)
    text:SetJustifyH("LEFT")
    row.text = text

    local line = row:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("LEFT", text, "RIGHT", 6, 0)
    line:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    line:SetColorTexture(0.3, 0.3, 0.4, 0.5)
    row.line = line

    return row
end

local function SetClassHeaderColor(hdr, hexColor)
    hdr.line:SetColorTexture(
        tonumber(hexColor:sub(1, 2), 16) / 255 * 0.5,
        tonumber(hexColor:sub(3, 4), 16) / 255 * 0.5,
        tonumber(hexColor:sub(5, 6), 16) / 255 * 0.5,
        0.6
    )
end

--- Global profile list row (left panel)
local function CreateProfileListRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROW_HEIGHT)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.15, 0.15, 0.25, 0.3)
    row.bg = bg

    local marker = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    marker:SetPoint("LEFT", 4, 0)
    marker:SetWidth(14)
    row.marker = marker

    local delBtn = CreateBtn(row, "X", 20, 18)
    delBtn:SetPoint("RIGHT", -2, 0)
    delBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Delete Profile")
        GameTooltip:AddLine("Remove this profile for all characters.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    delBtn:SetScript("OnLeave", GameTooltip_Hide)
    row.delBtn = delBtn

    local renBtn = CreateBtn(row, "R", 20, 18)
    renBtn:SetPoint("RIGHT", delBtn, "LEFT", -2, 0)
    renBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Rename Profile")
        GameTooltip:AddLine("Change this profile's name.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    renBtn:SetScript("OnLeave", GameTooltip_Hide)
    row.renBtn = renBtn

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", 18, 0)
    nameText:SetPoint("RIGHT", renBtn, "LEFT", -4, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    local infoText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    infoText:SetPoint("RIGHT", renBtn, "LEFT", -4, 0)
    infoText:SetJustifyH("RIGHT")
    row.infoText = infoText

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.2, 0.2, 0.35, 0.4)
    end)
    row:SetScript("OnLeave", function(self)
        if self.isActive then
            self.bg:SetColorTexture(0.15, 0.25, 0.35, 0.4)
        elseif self.isSelected then
            self.bg:SetColorTexture(0.25, 0.2, 0.35, 0.5)
        else
            self.bg:SetColorTexture(0.15, 0.15, 0.25, 0.3)
        end
    end)

    return row
end

--- Profile content layout row (center panel)
local function CreateProfileLayoutRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.12, 0.12, 0.18, 0.3)
    row.bg = bg

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", 8, 0)
    nameText:SetPoint("RIGHT", -163, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    local renameBtn = CreateBtn(row, "Rename", 48, 18)
    renameBtn:SetPoint("RIGHT", -113, 0)
    row.renameBtn = renameBtn

    local expBtn = CreateBtn(row, "Export", 44, 18)
    expBtn:SetPoint("RIGHT", -65, 0)
    row.expBtn = expBtn

    local libBtn = CreateBtn(row, ">Lib", 36, 18)
    libBtn:SetPoint("RIGHT", -26, 0)
    row.libBtn = libBtn

    local delBtn = CreateBtn(row, "X", 20, 18)
    delBtn:SetPoint("RIGHT", -4, 0)
    row.delBtn = delBtn

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self) self.bg:SetColorTexture(0.18, 0.18, 0.26, 0.4) end)
    row:SetScript("OnLeave", function(self) self.bg:SetColorTexture(0.12, 0.12, 0.18, 0.3) end)

    return row
end

--- Blizzard layout row (center panel, bottom section)
local function CreateBlizzRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.15, 0.25, 0.15, 0.3)
    row.bg = bg

    local marker = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    marker:SetPoint("LEFT", 8, 0)
    marker:SetWidth(14)
    row.marker = marker

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", 22, 0)
    nameText:SetPoint("RIGHT", -4, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self) self.bg:SetColorTexture(0.2, 0.35, 0.2, 0.4) end)
    row:SetScript("OnLeave", function(self)
        if self.isActive then
            self.bg:SetColorTexture(0.15, 0.35, 0.15, 0.35)
        else
            self.bg:SetColorTexture(0.15, 0.25, 0.15, 0.3)
        end
    end)

    return row
end

--- Template library row (right panel)
local function CreateTemplateRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.15, 0.1, 0.3)
    row.bg = bg

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", 8, 0)
    nameText:SetPoint("RIGHT", -150, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    local profBtn = CreateBtn(row, ">Prof", 40, 18)
    profBtn:SetPoint("RIGHT", -106, 0)
    row.profBtn = profBtn

    local expBtn = CreateBtn(row, "Export", 44, 18)
    expBtn:SetPoint("RIGHT", -58, 0)
    row.expBtn = expBtn

    local editBtn = CreateBtn(row, "Edit", 32, 18)
    editBtn:SetPoint("RIGHT", -22, 0)
    row.editBtn = editBtn

    local delBtn = CreateBtn(row, "X", 18, 18)
    delBtn:SetPoint("RIGHT", -2, 0)
    row.delBtn = delBtn

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self) self.bg:SetColorTexture(0.3, 0.2, 0.1, 0.4) end)
    row:SetScript("OnLeave", function(self) self.bg:SetColorTexture(0.2, 0.15, 0.1, 0.3) end)

    return row
end

---------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------

local mainFrame
local selectedProfileUUID = nil  -- currently selected global profile UUID

local function RefreshAll() end  -- forward declare

---------------------------------------------------------------------------
-- Main Frame Construction
---------------------------------------------------------------------------

local function CreateMainFrame()
    if mainFrame then return mainFrame end

    mainFrame = CreateBackdropFrame("CooldownMasterFrame", UIParent, DEFAULT_WIDTH, DEFAULT_HEIGHT)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetClampedToScreen(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:SetFrameStrata("DIALOG")
    mainFrame:Hide()

    table.insert(UISpecialFrames, "CooldownMasterFrame")

    -- Title
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText(COLOR_TITLE .. "CooldownMaster v" .. ns.VERSION .. "|r")

    -- Close
    local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)

    -- Version
    local ver = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ver:SetPoint("BOTTOMRIGHT", -PADDING, 8)
    ver:SetText(COLOR_DIM .. "v" .. ns.VERSION .. "|r")

    -- Resizable
    mainFrame:SetResizable(true)
    mainFrame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)

    local resizeGrip = CreateFrame("Button", nil, mainFrame)
    resizeGrip:SetSize(16, 16)
    resizeGrip:SetPoint("BOTTOMRIGHT", -6, 6)
    resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeGrip:SetScript("OnMouseDown", function()
        mainFrame:StartSizing("BOTTOMRIGHT")
    end)
    resizeGrip:SetScript("OnMouseUp", function()
        mainFrame:StopMovingOrSizing()
        if ns.db and ns.db.settings then
            ns.db.settings.uiWidth = math.floor(mainFrame:GetWidth() + 0.5)
            ns.db.settings.uiHeight = math.floor(mainFrame:GetHeight() + 0.5)
        end
    end)

    -- Restore saved size
    local savedW = ns.db and ns.db.settings and ns.db.settings.uiWidth or DEFAULT_WIDTH
    local savedH = ns.db and ns.db.settings and ns.db.settings.uiHeight or DEFAULT_HEIGHT
    if savedW < MIN_WIDTH then savedW = DEFAULT_WIDTH end
    if savedH < MIN_HEIGHT then savedH = DEFAULT_HEIGHT end
    mainFrame:SetSize(savedW, savedH)

    ---------------------------------------------------------------------------
    -- Three-column containers
    ---------------------------------------------------------------------------

    local topY = -38
    local botY = 60

    -- Left column container (profiles)
    mainFrame.leftCol = CreateFrame("Frame", nil, mainFrame)
    mainFrame.leftCol:SetPoint("TOPLEFT", PADDING, topY)
    mainFrame.leftCol:SetPoint("BOTTOMLEFT", PADDING, botY)

    -- Center column container (profile contents)
    mainFrame.centerCol = CreateFrame("Frame", nil, mainFrame)
    mainFrame.centerCol:SetPoint("TOPLEFT", 0, topY)  -- anchored by sizing
    mainFrame.centerCol:SetPoint("BOTTOMLEFT", 0, botY)

    -- Right column container (template library)
    mainFrame.rightCol = CreateFrame("Frame", nil, mainFrame)
    mainFrame.rightCol:SetPoint("TOPRIGHT", -PADDING, topY)
    mainFrame.rightCol:SetPoint("BOTTOMRIGHT", -PADDING, botY)

    -- Vertical divider lines
    mainFrame.divider1 = mainFrame:CreateTexture(nil, "ARTWORK")
    mainFrame.divider1:SetColorTexture(0.3, 0.3, 0.4, 0.6)
    mainFrame.divider1:SetWidth(1)

    mainFrame.divider2 = mainFrame:CreateTexture(nil, "ARTWORK")
    mainFrame.divider2:SetColorTexture(0.3, 0.3, 0.4, 0.6)
    mainFrame.divider2:SetWidth(1)

    ---------------------------------------------------------------------------
    -- LEFT COLUMN: Global Profiles
    ---------------------------------------------------------------------------

    local left = mainFrame.leftCol
    local yL = 0

    left.header = CreateSectionHeader(left, "Profiles")
    left.header:SetPoint("TOPLEFT", 4, yL)

    left.countText = left:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    left.countText:SetPoint("TOPRIGHT", -4, yL)
    left.countText:SetJustifyH("RIGHT")

    yL = yL - 18

    -- New profile button (above scroll)
    local newBtn = CreateBtn(left, "New", 42, 20)
    newBtn:SetPoint("TOPLEFT", 4, yL)
    newBtn:SetScript("OnClick", function()
        StaticPopup_Show("COOLDOWNMASTER_NEW_GLOBAL_PROFILE")
    end)
    newBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("New Profile")
        GameTooltip:AddLine("Create a new global profile.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    newBtn:SetScript("OnLeave", GameTooltip_Hide)

    yL = yL - 24

    -- Profile scroll area
    local profScroll = CreateFrame("ScrollFrame", "CMGlobalProfScroll", left, "UIPanelScrollFrameTemplate")
    profScroll:SetPoint("TOPLEFT", 4, yL)
    profScroll:SetPoint("TOPRIGHT", -22, yL)
    profScroll:SetHeight(200) -- will be adjusted by sizing
    mainFrame.profScroll = profScroll

    local profContent = CreateFrame("Frame", nil, profScroll)
    profContent:SetSize(200, 1)
    profScroll:SetScrollChild(profContent)
    mainFrame.profContent = profContent

    ---------------------------------------------------------------------------
    -- CENTER COLUMN: Profile Contents + Blizzard Layouts
    ---------------------------------------------------------------------------

    local center = mainFrame.centerCol
    local yC = 0

    center.header = CreateSectionHeader(center, "Profile Contents")
    center.header:SetPoint("TOPLEFT", 4, yC)

    center.profileNameText = center:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    center.profileNameText:SetPoint("TOPRIGHT", -4, yC)
    center.profileNameText:SetJustifyH("RIGHT")

    yC = yC - 18

    center.hint = center:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    center.hint:SetPoint("TOPLEFT", 8, yC)
    center.hint:SetText(COLOR_DIM .. "Select a profile on the left|r")

    -- Profile contents scroll (upper part of center column)
    local contScroll = CreateFrame("ScrollFrame", "CMProfileContScroll", center, "UIPanelScrollFrameTemplate")
    contScroll:SetPoint("TOPLEFT", 4, yC)
    contScroll:SetPoint("TOPRIGHT", -22, yC)
    contScroll:SetHeight(300) -- adjusted by sizing
    mainFrame.contScroll = contScroll

    local contContent = CreateFrame("Frame", nil, contScroll)
    contContent:SetSize(300, 1)
    contScroll:SetScrollChild(contContent)
    mainFrame.contContent = contContent

    -- Action buttons below profile contents scroll
    mainFrame.centerBtnFrame = CreateFrame("Frame", nil, center)
    mainFrame.centerBtnFrame:SetHeight(24)
    mainFrame.centerBtnFrame:SetPoint("TOPLEFT", 4, -322) -- adjusted by sizing
    mainFrame.centerBtnFrame:SetPoint("TOPRIGHT", -4, -322)

    local syncBtn = CreateBtn(mainFrame.centerBtnFrame, "Sync from Blizz", 105, 20)
    syncBtn:SetPoint("LEFT", 0, 0)
    syncBtn:SetScript("OnClick", function()
        if not selectedProfileUUID then ns.Print("Select a profile first."); return end
        local ok, msg = ns.SyncBlizzardToGlobalProfile(selectedProfileUUID)
        if ok then
            ns.Print(COLOR_GREEN .. (msg or "Synced.") .. "|r")
        else
            ns.Print("|cFFFF0000Error:|r " .. (msg or "unknown"))
        end
    end)
    syncBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Sync from Blizzard")
        GameTooltip:AddLine("Capture current Blizzard CDM layouts\nfor your class into this profile.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    syncBtn:SetScript("OnLeave", GameTooltip_Hide)
    mainFrame.syncBtn = syncBtn

    local loadBtn = CreateBtn(mainFrame.centerBtnFrame, "Load to Blizz", 95, 20)
    loadBtn:SetPoint("LEFT", syncBtn, "RIGHT", 4, 0)
    loadBtn:SetScript("OnClick", function()
        if not selectedProfileUUID then ns.Print("Select a profile first."); return end
        local ok, msg = ns.LoadGlobalProfile(selectedProfileUUID)
        if ok then
            ns.Print(COLOR_GREEN .. (msg or "Loaded.") .. "|r")
        else
            ns.Print("|cFFFF0000Error:|r " .. (msg or "unknown"))
        end
    end)
    loadBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Load to Blizzard")
        GameTooltip:AddLine("Load this profile's layouts for your\ncurrent class into Blizzard CDM.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    loadBtn:SetScript("OnLeave", GameTooltip_Hide)
    mainFrame.loadBtn = loadBtn

    -- Blizzard Layouts section (lower part of center column)
    local blizzY = -350  -- adjusted by sizing

    center.blizzHeader = CreateSectionHeader(center, "Blizzard Layouts (0/5)")
    center.blizzHeader:SetPoint("TOPLEFT", 4, blizzY)

    local blizzManageBtn = CreateBtn(center, "Manage", 52, 16)
    blizzManageBtn:SetPoint("TOPRIGHT", center, "TOPRIGHT", -4, blizzY + 2)
    blizzManageBtn:SetScript("OnClick", function()
        ns.EnsureCDMLoaded()
        if CooldownViewerSettings and not InCombatLockdown() then
            CooldownViewerSettings:Show()
        end
    end)
    blizzManageBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Open Cooldown Manager settings")
        GameTooltip:Show()
    end)
    blizzManageBtn:SetScript("OnLeave", GameTooltip_Hide)
    center.blizzManageBtn = blizzManageBtn

    center.blizzSlotInfo = center:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    center.blizzSlotInfo:SetPoint("RIGHT", blizzManageBtn, "LEFT", -4, 0)
    center.blizzSlotInfo:SetJustifyH("RIGHT")

    local blizzScroll = CreateFrame("ScrollFrame", "CMBlizzScroll", center, "UIPanelScrollFrameTemplate")
    blizzScroll:SetPoint("TOPLEFT", 4, blizzY - 18)
    blizzScroll:SetPoint("BOTTOMRIGHT", center, "BOTTOMRIGHT", -22, 0)
    mainFrame.blizzScroll = blizzScroll

    local blizzContent = CreateFrame("Frame", nil, blizzScroll)
    blizzContent:SetSize(300, 1)
    blizzScroll:SetScrollChild(blizzContent)
    mainFrame.blizzContent = blizzContent

    ---------------------------------------------------------------------------
    -- RIGHT COLUMN: Template Library
    ---------------------------------------------------------------------------

    local right = mainFrame.rightCol
    local yR = 0

    right.header = CreateSectionHeader(right, "Template Library")
    right.header:SetPoint("TOPLEFT", 4, yR)

    right.countText = right:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    right.countText:SetPoint("TOPRIGHT", -4, yR)
    right.countText:SetJustifyH("RIGHT")

    yR = yR - 18

    -- Import CDM button at top of template library
    local importCDMBtn = CreateBtn(right, "Import CDM", 80, 20)
    importCDMBtn:SetPoint("TOPLEFT", 4, yR)
    importCDMBtn:SetScript("OnClick", function()
        ns.ShowImportWindow()
    end)
    importCDMBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Import CDM String")
        GameTooltip:AddLine("Import a CDM layout string or\nCooldownMaster export as a template.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    importCDMBtn:SetScript("OnLeave", GameTooltip_Hide)

    yR = yR - 24

    -- Template library scroll
    local tmplScroll = CreateFrame("ScrollFrame", "CMTemplateScroll", right, "UIPanelScrollFrameTemplate")
    tmplScroll:SetPoint("TOPLEFT", 4, yR)
    tmplScroll:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -22, 0)
    mainFrame.tmplScroll = tmplScroll

    local tmplContent = CreateFrame("Frame", nil, tmplScroll)
    tmplContent:SetSize(300, 1)
    tmplScroll:SetScrollChild(tmplContent)
    mainFrame.tmplContent = tmplContent

    ---------------------------------------------------------------------------
    -- Bottom Bar Buttons (full width)
    ---------------------------------------------------------------------------

    local importBtn = CreateBtn(mainFrame, "Import", 70, 26)
    importBtn:SetPoint("BOTTOMLEFT", PADDING + 4, 28)
    importBtn:SetScript("OnClick", function() ns.ShowImportWindow() end)

    local exportProfBtn = CreateBtn(mainFrame, "Export Profile", 100, 26)
    exportProfBtn:SetPoint("LEFT", importBtn, "RIGHT", 6, 0)
    exportProfBtn:SetScript("OnClick", function()
        if not selectedProfileUUID then
            ns.Print("Select a global profile first.")
            return
        end
        local str, err = ns.ExportGlobalProfile(selectedProfileUUID)
        if str then
            local profile = ns.GetGlobalProfile(selectedProfileUUID)
            ns.ShowExportStringWindow(str, "Profile: " .. (profile and profile.name or "?"))
        else
            ns.Print("|cFFFF0000Error:|r " .. (err or "Nothing to export."))
        end
    end)

    local exportClassBtn = CreateBtn(mainFrame, "Export Class", 90, 26)
    exportClassBtn:SetPoint("LEFT", exportProfBtn, "RIGHT", 6, 0)
    exportClassBtn:SetScript("OnClick", function()
        if not selectedProfileUUID then
            ns.Print("Select a global profile first.")
            return
        end
        local classToken = ns.GetClassToken()
        local str, err = ns.ExportProfileClass(selectedProfileUUID, classToken)
        if str then
            local profile = ns.GetGlobalProfile(selectedProfileUUID)
            ns.ShowExportStringWindow(str, classToken .. " from " .. (profile and profile.name or "?"))
        else
            ns.Print("|cFFFF0000Error:|r " .. (err or "No layouts for " .. classToken .. "."))
        end
    end)

    ---------------------------------------------------------------------------
    -- Sizing logic
    ---------------------------------------------------------------------------

    local function ApplySizing()
        local w = mainFrame:GetWidth()
        local h = mainFrame:GetHeight()
        local inner = w - 2 * PADDING
        local gap = 6 -- gap between columns

        local leftW = math.floor(inner * COL_LEFT)
        local centerW = math.floor(inner * COL_CENTER)
        local rightW = inner - leftW - centerW - 2 * gap

        -- Left column
        mainFrame.leftCol:SetWidth(leftW)

        -- Divider 1
        local div1X = PADDING + leftW + gap / 2
        mainFrame.divider1:ClearAllPoints()
        mainFrame.divider1:SetPoint("TOP", mainFrame, "TOPLEFT", div1X, -38)
        mainFrame.divider1:SetPoint("BOTTOM", mainFrame, "BOTTOMLEFT", div1X, 60)

        -- Center column
        local centerStartX = PADDING + leftW + gap
        mainFrame.centerCol:ClearAllPoints()
        mainFrame.centerCol:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", centerStartX, -38)
        mainFrame.centerCol:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", centerStartX, 60)
        mainFrame.centerCol:SetWidth(centerW)

        -- Divider 2
        local div2X = centerStartX + centerW + gap / 2
        mainFrame.divider2:ClearAllPoints()
        mainFrame.divider2:SetPoint("TOP", mainFrame, "TOPLEFT", div2X, -38)
        mainFrame.divider2:SetPoint("BOTTOM", mainFrame, "BOTTOMLEFT", div2X, 60)

        -- Right column
        local rightStartX = centerStartX + centerW + gap
        mainFrame.rightCol:ClearAllPoints()
        mainFrame.rightCol:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", rightStartX, -38)
        mainFrame.rightCol:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -PADDING, 60)

        -- Scroll content widths
        local leftScrollW = math.max(60, leftW - 26)
        local centerScrollW = math.max(60, centerW - 26)
        local rightScrollW = math.max(60, rightW - 26)

        if mainFrame.profContent then mainFrame.profContent:SetWidth(leftScrollW) end
        if mainFrame.contContent then mainFrame.contContent:SetWidth(centerScrollW) end
        if mainFrame.blizzContent then mainFrame.blizzContent:SetWidth(centerScrollW) end
        if mainFrame.tmplContent then mainFrame.tmplContent:SetWidth(rightScrollW) end

        -- Center column layout: top part (profile contents) gets ~65% of column height,
        -- bottom (Blizzard layouts) gets the rest
        local colHeight = h - 38 - 60  -- total usable column height
        local contScrollH = math.floor(colHeight * 0.60) - 18 -- minus header
        local btnRowY = -(18 + contScrollH)
        local blizzY = btnRowY - 28

        mainFrame.contScroll:SetHeight(math.max(50, contScrollH))
        mainFrame.centerBtnFrame:ClearAllPoints()
        mainFrame.centerBtnFrame:SetPoint("TOPLEFT", mainFrame.centerCol, "TOPLEFT", 4, btnRowY)
        mainFrame.centerBtnFrame:SetPoint("TOPRIGHT", mainFrame.centerCol, "TOPRIGHT", -4, btnRowY)

        mainFrame.centerCol.blizzHeader:ClearAllPoints()
        mainFrame.centerCol.blizzHeader:SetPoint("TOPLEFT", mainFrame.centerCol, "TOPLEFT", 4, blizzY)
        mainFrame.centerCol.blizzManageBtn:ClearAllPoints()
        mainFrame.centerCol.blizzManageBtn:SetPoint("TOPRIGHT", mainFrame.centerCol, "TOPRIGHT", -4, blizzY + 2)
        mainFrame.centerCol.blizzSlotInfo:ClearAllPoints()
        mainFrame.centerCol.blizzSlotInfo:SetPoint("RIGHT", mainFrame.centerCol.blizzManageBtn, "LEFT", -4, 0)

        mainFrame.blizzScroll:ClearAllPoints()
        mainFrame.blizzScroll:SetPoint("TOPLEFT", mainFrame.centerCol, "TOPLEFT", 4, blizzY - 18)
        mainFrame.blizzScroll:SetPoint("BOTTOMRIGHT", mainFrame.centerCol, "BOTTOMRIGHT", -22, 0)

        -- Left column: profile scroll fills available space (header + New btn + scroll)
        local profScrollH = math.max(60, colHeight - 18 - 24 - 4)
        mainFrame.profScroll:SetHeight(profScrollH)
    end

    mainFrame.ApplySizing = ApplySizing
    mainFrame:SetScript("OnSizeChanged", function() ApplySizing() end)
    ApplySizing()

    return mainFrame
end

---------------------------------------------------------------------------
-- Refresh: Global Profiles (left panel)
---------------------------------------------------------------------------

local function RefreshProfileSection()
    if not mainFrame then return end
    local left = mainFrame.leftCol

    ReleasePool("profileRows")

    local profiles = ns.GetGlobalProfileList()
    local activeUUID = ns.GetActiveGlobalProfileUUID()
    local count = #profiles

    left.header:SetText(COLOR_YELLOW .. "Profiles (" .. count .. ")|r")
    left.countText:SetText(
        activeUUID and (COLOR_GREEN .. "Active set|r") or (COLOR_DIM .. "No active|r")
    )

    if count == 0 then
        mainFrame.profContent:SetHeight(20)
        return
    end

    local yOff = 0
    for _, p in ipairs(profiles) do
        local row = GetOrCreateFrame("profileRows", CreateProfileListRow, mainFrame.profContent)
        row:SetPoint("TOPLEFT", 0, yOff)
        row:SetPoint("TOPRIGHT", 0, yOff)

        local isActive = (p.uuid == activeUUID)
        local isSelected = (p.uuid == selectedProfileUUID)
        row.isActive = isActive
        row.isSelected = isSelected

        if isActive then
            row.marker:SetText(COLOR_GREEN .. ">" .. "|r")
            row.bg:SetColorTexture(0.15, 0.25, 0.35, 0.4)
            row.nameText:SetTextColor(0.3, 0.85, 1.0)
        elseif isSelected then
            row.marker:SetText(COLOR_ORANGE .. ">" .. "|r")
            row.bg:SetColorTexture(0.25, 0.2, 0.35, 0.5)
            row.nameText:SetTextColor(0.9, 0.9, 0.9)
        else
            row.marker:SetText("")
            row.bg:SetColorTexture(0.15, 0.15, 0.25, 0.3)
            row.nameText:SetTextColor(0.9, 0.9, 0.9)
        end

        row.nameText:SetText(p.name)
        row.infoText:SetText(COLOR_DIM .. p.layoutCount .. "L " .. p.classCount .. "C|r")

        local uuid = p.uuid
        local pName = p.name
        row:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                selectedProfileUUID = uuid
                RefreshAll()
            end
        end)

        row.renBtn:SetScript("OnClick", function()
            local dialog = StaticPopup_Show("COOLDOWNMASTER_RENAME_GLOBAL_PROFILE", pName)
            if dialog then dialog.data = { uuid = uuid, oldName = pName } end
        end)

        row.delBtn:SetScript("OnClick", function()
            local dialog = StaticPopup_Show("COOLDOWNMASTER_DELETE_GLOBAL_PROFILE", pName)
            if dialog then dialog.data = { uuid = uuid } end
        end)

        yOff = yOff - ROW_HEIGHT
    end

    mainFrame.profContent:SetHeight(math.max(1, math.abs(yOff)))
end

---------------------------------------------------------------------------
-- Refresh: Profile Contents (center panel, upper)
---------------------------------------------------------------------------

local function RefreshProfileContents()
    if not mainFrame then return end
    local center = mainFrame.centerCol

    ReleasePool("contHeaders")
    ReleasePool("contRows")

    if not selectedProfileUUID then
        center.header:SetText(COLOR_YELLOW .. "Profile Contents|r")
        center.profileNameText:SetText("")
        center.hint:Show()
        mainFrame.contContent:SetHeight(20)
        return
    end

    center.hint:Hide()

    local profile = ns.GetGlobalProfile(selectedProfileUUID)
    if not profile then
        center.header:SetText(COLOR_YELLOW .. "Profile Contents|r")
        center.profileNameText:SetText(COLOR_RED .. "Not found|r")
        mainFrame.contContent:SetHeight(20)
        return
    end

    center.header:SetText(COLOR_YELLOW .. "Profile Contents|r")
    center.profileNameText:SetText(COLOR_TITLE .. profile.name .. "|r")

    local layouts = ns.GetProfileLayouts(selectedProfileUUID)

    if #layouts == 0 then
        local emptyText = GetOrCreateFrame("contRows", function(parent)
            local f = CreateFrame("Frame", nil, parent)
            f:SetHeight(20)
            f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            f.text:SetPoint("LEFT", 8, 0)
            return f
        end, mainFrame.contContent)
        emptyText:SetPoint("TOPLEFT", 0, 0)
        emptyText:SetPoint("TOPRIGHT", 0, 0)
        -- Hide buttons from recycled layout rows
        if emptyText.renameBtn then emptyText.renameBtn:Hide() end
        if emptyText.expBtn then emptyText.expBtn:Hide() end
        if emptyText.libBtn then emptyText.libBtn:Hide() end
        if emptyText.delBtn then emptyText.delBtn:Hide() end
        if emptyText.text then
            emptyText.text:SetText(COLOR_DIM .. "No layouts. Use Sync or add from Library.|r")
        end
        if emptyText.nameText then
            emptyText.nameText:SetText(COLOR_DIM .. "No layouts. Use Sync or add from Library.|r")
        end
        mainFrame.contContent:SetHeight(24)
        return
    end

    local groups = GroupByClass(layouts)
    local yOff = 0

    for _, group in ipairs(groups) do
        -- Class header
        local hdr = GetOrCreateFrame("contHeaders", CreateClassGroupHeader, mainFrame.contContent)
        hdr:SetPoint("TOPLEFT", 0, yOff)
        hdr:SetPoint("TOPRIGHT", 0, yOff)
        hdr.text:SetText("|cFF" .. group.color .. group.displayName .. "|r")
        SetClassHeaderColor(hdr, group.color)
        yOff = yOff - 20

        for _, layout in ipairs(group.items) do
            local row = GetOrCreateFrame("contRows", CreateProfileLayoutRow, mainFrame.contContent)
            row:SetPoint("TOPLEFT", 0, yOff)
            row:SetPoint("TOPRIGHT", 0, yOff)

            -- Re-show buttons (may have been hidden when recycled as empty-text row)
            if row.renameBtn then row.renameBtn:Show() end
            if row.expBtn then row.expBtn:Show() end
            if row.libBtn then row.libBtn:Show() end
            if row.delBtn then row.delBtn:Show() end

            row.nameText:SetText(layout.name)
            row.nameText:SetTextColor(0.9, 0.9, 0.9)

            local cls = layout.class
            local idx = layout.index
            local pUUID = selectedProfileUUID
            local layoutName = layout.name

            -- Rename button
            row.renameBtn:SetScript("OnClick", function()
                local dialog = StaticPopup_Show("COOLDOWNMASTER_RENAME_PROFILE_LAYOUT", layoutName)
                if dialog then
                    dialog.data = { profileUUID = pUUID, class = cls, index = idx, oldName = layoutName }
                end
            end)
            row.renameBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Rename Layout")
                GameTooltip:Show()
            end)
            row.renameBtn:SetScript("OnLeave", GameTooltip_Hide)

            -- Export button
            row.expBtn:SetScript("OnClick", function()
                if layout.data then
                    local str, err = ns.ExportSingleLayout(layout.data, layoutName, cls, layout.spec)
                    if str then
                        ns.ShowExportStringWindow(str, "Layout: " .. layoutName)
                    else
                        ns.Print("|cFFFF0000Error:|r " .. (err or "Export failed."))
                    end
                else
                    ns.Print("No data for this layout.")
                end
            end)
            row.expBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Export Layout")
                GameTooltip:AddLine("Export as a shareable string.", 1, 1, 1, true)
                GameTooltip:Show()
            end)
            row.expBtn:SetScript("OnLeave", GameTooltip_Hide)

            -- Save to Library button
            row.libBtn:SetScript("OnClick", function()
                local uuid, err = ns.SaveLayoutAsTemplate(pUUID, cls, idx)
                if uuid then
                    ns.Print("Saved to library: " .. layoutName)
                else
                    ns.Print("|cFFFF0000Error:|r " .. (err or "unknown"))
                end
            end)
            row.libBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Save to Library")
                GameTooltip:AddLine("Copy this layout to the\nTemplate Library.", 1, 1, 1, true)
                GameTooltip:Show()
            end)
            row.libBtn:SetScript("OnLeave", GameTooltip_Hide)

            -- Remove button
            row.delBtn:SetScript("OnClick", function()
                local dialog = StaticPopup_Show("COOLDOWNMASTER_REMOVE_FROM_PROFILE", layoutName)
                if dialog then
                    dialog.data = { profileUUID = pUUID, class = cls, index = idx }
                end
            end)
            row.delBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Remove from Profile")
                GameTooltip:Show()
            end)
            row.delBtn:SetScript("OnLeave", GameTooltip_Hide)

            yOff = yOff - ROW_HEIGHT
        end
    end

    mainFrame.contContent:SetHeight(math.max(1, math.abs(yOff)))
end

---------------------------------------------------------------------------
-- Refresh: Blizzard Layouts (center panel, lower)
---------------------------------------------------------------------------

local function RefreshBlizzardSection()
    if not mainFrame then return end
    local center = mainFrame.centerCol

    ReleasePool("blizzHeaders")
    ReleasePool("blizzRows")

    local layouts = ns.GetBlizzardLayouts()
    local count = #layouts

    center.blizzHeader:SetText(COLOR_YELLOW .. "Blizzard Layouts (" .. count .. "/5)|r")
    center.blizzSlotInfo:SetText(
        ns.HasFreeBlizzardSlot()
            and (COLOR_GREEN .. (5 - count) .. " free|r")
            or (COLOR_RED .. "Full|r")
    )

    if count == 0 then
        mainFrame.blizzContent:SetHeight(20)
        return
    end

    local groups = GroupByClass(layouts)
    local yOff = 0

    for _, group in ipairs(groups) do
        local hdr = GetOrCreateFrame("blizzHeaders", CreateClassGroupHeader, mainFrame.blizzContent)
        hdr:SetPoint("TOPLEFT", 0, yOff)
        hdr:SetPoint("TOPRIGHT", 0, yOff)
        hdr.text:SetText("|cFF" .. group.color .. group.displayName .. "|r")
        SetClassHeaderColor(hdr, group.color)
        yOff = yOff - 20

        for _, l in ipairs(group.items) do
            local row = GetOrCreateFrame("blizzRows", CreateBlizzRow, mainFrame.blizzContent)
            row:SetPoint("TOPLEFT", 0, yOff)
            row:SetPoint("TOPRIGHT", 0, yOff)

            row.nameText:SetText(l.name)
            row.isActive = l.isActive

            if l.isActive then
                row.marker:SetText(COLOR_GREEN .. ">|r")
                row.bg:SetColorTexture(0.15, 0.35, 0.15, 0.35)
                row.nameText:SetTextColor(0.2, 0.9, 0.2)
            else
                row.marker:SetText("")
                row.bg:SetColorTexture(0.15, 0.25, 0.15, 0.3)
                row.nameText:SetTextColor(0.9, 0.9, 0.9)
            end

            yOff = yOff - ROW_HEIGHT
        end
    end

    mainFrame.blizzContent:SetHeight(math.max(1, math.abs(yOff)))
end

---------------------------------------------------------------------------
-- Refresh: Template Library (right panel)
---------------------------------------------------------------------------

local function RefreshTemplateSection()
    if not mainFrame then return end
    local right = mainFrame.rightCol

    ReleasePool("tmplHeaders")
    ReleasePool("tmplRows")

    local templates = ns.GetTemplateList()
    local count = #templates

    right.header:SetText(COLOR_YELLOW .. "Template Library|r")
    right.countText:SetText(COLOR_DIM .. count .. " template(s)|r")

    if count == 0 then
        mainFrame.tmplContent:SetHeight(20)
        return
    end

    local groups = GroupByClass(templates)
    local yOff = 0

    for _, group in ipairs(groups) do
        local hdr = GetOrCreateFrame("tmplHeaders", CreateClassGroupHeader, mainFrame.tmplContent)
        hdr:SetPoint("TOPLEFT", 0, yOff)
        hdr:SetPoint("TOPRIGHT", 0, yOff)
        hdr.text:SetText("|cFF" .. group.color .. group.displayName .. "|r")
        SetClassHeaderColor(hdr, group.color)
        yOff = yOff - 20

        for _, tmpl in ipairs(group.items) do
            local row = GetOrCreateFrame("tmplRows", CreateTemplateRow, mainFrame.tmplContent)
            row:SetPoint("TOPLEFT", 0, yOff)
            row:SetPoint("TOPRIGHT", 0, yOff)

            row.nameText:SetText(tmpl.name)
            row.nameText:SetTextColor(0.9, 0.8, 0.6)

            local tmplUUID = tmpl.uuid
            local tmplName = tmpl.name

            -- Add to profile button
            row.profBtn:SetScript("OnClick", function()
                if not selectedProfileUUID then
                    ns.Print("Select a global profile first.")
                    return
                end
                local ok, err = ns.AddTemplateToProfile(selectedProfileUUID, tmplUUID)
                if ok then
                    ns.Print("Added '" .. tmplName .. "' to profile.")
                else
                    ns.Print("|cFFFF0000Error:|r " .. (err or "unknown"))
                end
            end)
            row.profBtn:SetEnabled(selectedProfileUUID ~= nil)
            row.profBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Add to Profile")
                if selectedProfileUUID then
                    local profile = ns.GetGlobalProfile(selectedProfileUUID)
                    GameTooltip:AddLine("Copy this template into\n'" .. (profile and profile.name or "?") .. "'.", 1, 1, 1, true)
                else
                    GameTooltip:AddLine("Select a profile first.", 1, 0.5, 0.5, true)
                end
                GameTooltip:Show()
            end)
            row.profBtn:SetScript("OnLeave", GameTooltip_Hide)

            -- Export button
            row.expBtn:SetScript("OnClick", function()
                local str, err = ns.ExportTemplate(tmplUUID)
                if str then
                    ns.ShowExportStringWindow(str, "Template: " .. tmplName)
                else
                    ns.Print("|cFFFF0000Error:|r " .. (err or "Export failed."))
                end
            end)
            row.expBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Export Template")
                GameTooltip:AddLine("Export as a shareable string.", 1, 1, 1, true)
                GameTooltip:Show()
            end)
            row.expBtn:SetScript("OnLeave", GameTooltip_Hide)

            -- Edit button
            row.editBtn:SetScript("OnClick", function()
                ns.ShowEditTemplateWindow(tmplUUID)
            end)
            row.editBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Edit Template")
                GameTooltip:AddLine("Edit name, class, spec, and layout data.", 1, 1, 1, true)
                GameTooltip:Show()
            end)
            row.editBtn:SetScript("OnLeave", GameTooltip_Hide)

            -- Delete button
            row.delBtn:SetScript("OnClick", function()
                local dialog = StaticPopup_Show("COOLDOWNMASTER_DELETE_TEMPLATE", tmplName)
                if dialog then
                    dialog.data = { uuid = tmplUUID }
                end
            end)
            row.delBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Delete Template")
                GameTooltip:Show()
            end)
            row.delBtn:SetScript("OnLeave", GameTooltip_Hide)

            yOff = yOff - ROW_HEIGHT
        end
    end

    mainFrame.tmplContent:SetHeight(math.max(1, math.abs(yOff)))
end

---------------------------------------------------------------------------
-- Refresh All
---------------------------------------------------------------------------

RefreshAll = function()
    if not mainFrame or not mainFrame:IsShown() then return end
    RefreshProfileSection()
    RefreshProfileContents()
    RefreshBlizzardSection()
    RefreshTemplateSection()
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

function ns.ToggleUI()
    local frame = CreateMainFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        -- Auto-select the active global profile if none selected
        if not selectedProfileUUID then
            selectedProfileUUID = ns.GetActiveGlobalProfileUUID()
        end
        frame:Show()
        RefreshAll()
    end
end

function ns.RefreshUI()
    RefreshAll()
end

---------------------------------------------------------------------------
-- Export String Window
---------------------------------------------------------------------------

local exportStringFrame

function ns.ShowExportStringWindow(str, title)
    if not exportStringFrame then
        exportStringFrame = CreateBackdropFrame("CooldownMasterExportStringFrame", UIParent, 460, 300)
        exportStringFrame:SetPoint("CENTER", 220, 0)
        exportStringFrame:SetMovable(true)
        exportStringFrame:EnableMouse(true)
        exportStringFrame:SetClampedToScreen(true)
        exportStringFrame:RegisterForDrag("LeftButton")
        exportStringFrame:SetScript("OnDragStart", exportStringFrame.StartMoving)
        exportStringFrame:SetScript("OnDragStop", exportStringFrame.StopMovingOrSizing)
        exportStringFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        exportStringFrame:Hide()

        table.insert(UISpecialFrames, "CooldownMasterExportStringFrame")

        exportStringFrame.titleText = exportStringFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        exportStringFrame.titleText:SetPoint("TOP", 0, -14)

        local closeBtn = CreateFrame("Button", nil, exportStringFrame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -4, -4)

        local scrollFrame = CreateFrame("ScrollFrame", nil, exportStringFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", PADDING + 4, -40)
        scrollFrame:SetSize(420, 200)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject("ChatFontNormal")
        editBox:SetWidth(400)
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        scrollFrame:SetScrollChild(editBox)
        exportStringFrame.editBox = editBox

        local selectBtn = CreateBtn(exportStringFrame, "Select All", 100, 26)
        selectBtn:SetPoint("BOTTOM", 0, PADDING + 4)
        selectBtn:SetScript("OnClick", function()
            editBox:SetFocus()
            editBox:HighlightText()
        end)

        exportStringFrame.lenText = exportStringFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        exportStringFrame.lenText:SetPoint("BOTTOMLEFT", PADDING + 4, PADDING + 8)
    end

    exportStringFrame.titleText:SetText(COLOR_TITLE .. "Export|r")
    exportStringFrame.editBox:SetText(str or "")
    exportStringFrame.lenText:SetText(COLOR_DIM .. string.len(str or "") .. " chars|r")
    exportStringFrame:Show()
    exportStringFrame:Raise()

    C_Timer.After(0.05, function()
        exportStringFrame.editBox:SetFocus()
        exportStringFrame.editBox:HighlightText()
    end)
end

---------------------------------------------------------------------------
-- Export Window
---------------------------------------------------------------------------

function ns.ShowExportWindow()
    local lm = ns.GetLayoutManager()
    if lm then
        local activeID = lm:GetActiveLayoutID()
        if activeID and activeID ~= 0 then
            local str, err = ns.ExportBlizzardLayout(activeID)
            if str then
                ns.ShowExportStringWindow(str, "Active Layout")
                return
            end
        end
    end
    ns.Print("No active layout to export. Use the UI buttons to export specific layouts.")
end

---------------------------------------------------------------------------
-- Import Window
---------------------------------------------------------------------------

local importFrame

function ns.ShowImportWindow()
    if not importFrame then
        importFrame = CreateBackdropFrame("CooldownMasterImportFrame", UIParent, 480, 452)
        importFrame:SetPoint("CENTER", -220, 0)
        importFrame:SetMovable(true)
        importFrame:EnableMouse(true)
        importFrame:SetClampedToScreen(true)
        importFrame:RegisterForDrag("LeftButton")
        importFrame:SetScript("OnDragStart", importFrame.StartMoving)
        importFrame:SetScript("OnDragStop", importFrame.StopMovingOrSizing)
        importFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        importFrame:Hide()

        table.insert(UISpecialFrames, "CooldownMasterImportFrame")

        local title = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -14)
        title:SetText(COLOR_TITLE .. "Import|r")

        local closeBtn = CreateFrame("Button", nil, importFrame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -4, -4)

        local instr = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        instr:SetPoint("TOPLEFT", PADDING + 4, -38)
        instr:SetPoint("TOPRIGHT", -(PADDING + 4), -38)
        instr:SetJustifyH("LEFT")
        instr:SetWordWrap(true)
        instr:SetText("Paste a CDM string, template export, or profile export:")

        local nameLabel = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameLabel:SetPoint("TOPLEFT", PADDING + 4, -62)
        nameLabel:SetText("Name (CDM):")

        local nameBox = CreateFrame("EditBox", nil, importFrame, "InputBoxTemplate")
        nameBox:SetSize(200, 22)
        nameBox:SetPoint("TOPLEFT", PADDING + 80, -59)
        nameBox:SetAutoFocus(false)
        nameBox:SetText("Imported")
        importFrame.nameBox = nameBox

        local classDropdown = CreateCustomDropdown(importFrame, "Class (CDM):")
        classDropdown:SetPoint("TOPLEFT", PADDING + 4, -86)
        classDropdown:SetPoint("TOPRIGHT", -(PADDING + 4), -86)
        classDropdown:SetItems(BuildClassItems())
        classDropdown:SetSelected(ns.GetClassToken())
        importFrame.classDropdown = classDropdown

        local specDropdown = CreateCustomDropdown(importFrame, "Spec (CDM):")
        specDropdown:SetPoint("TOPLEFT", PADDING + 4, -110)
        specDropdown:SetPoint("TOPRIGHT", -(PADDING + 4), -110)
        specDropdown:SetItems(BuildSpecItems(ns.GetClassToken()))
        specDropdown:SetSelected(nil)
        importFrame.specDropdown = specDropdown

        classDropdown.onChanged = function(classToken)
            specDropdown:SetItems(BuildSpecItems(classToken))
            specDropdown:SetSelected(nil)
        end

        local scrollFrame = CreateFrame("ScrollFrame", nil, importFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", PADDING + 4, -134)
        scrollFrame:SetSize(440, 210)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject("ChatFontNormal")
        editBox:SetWidth(420)
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        scrollFrame:SetScrollChild(editBox)
        importFrame.editBox = editBox

        local statusText = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statusText:SetPoint("BOTTOMLEFT", PADDING + 4, PADDING + 36)
        statusText:SetPoint("BOTTOMRIGHT", -PADDING - 4, PADDING + 36)
        statusText:SetJustifyH("LEFT")
        statusText:SetWordWrap(true)
        importFrame.statusText = statusText

        editBox:SetScript("OnTextChanged", function(self, userInput)
            if not userInput then return end
            local text = self:GetText()
            if not text or text:match("^%s*$") then
                importFrame.statusText:SetText(COLOR_DIM .. "Waiting for input...|r")
                importFrame.decoded = nil
                importFrame.scope = nil
                return
            end

            local decoded, scope, err = ns.ImportString(text)
            if decoded then
                importFrame.decoded = decoded
                importFrame.scope = scope
                if scope == "cdm" then
                    importFrame.statusText:SetText(COLOR_GREEN .. "Detected: CDM layout string|r")
                elseif scope == "globalProfile" then
                    local lCount = 0
                    if decoded.layouts then
                        for _, cl in pairs(decoded.layouts) do lCount = lCount + #cl end
                    end
                    importFrame.statusText:SetText(COLOR_GREEN .. "Detected: Global profile '" .. (decoded.name or "?") .. "' (" .. lCount .. " layouts)|r")
                elseif scope == "classLayouts" then
                    local lCount = decoded.layouts and #decoded.layouts or 0
                    importFrame.statusText:SetText(COLOR_GREEN .. "Detected: Class layouts for " .. (decoded.class or "?") .. " (" .. lCount .. ")|r")
                elseif scope == "singleLayout" then
                    importFrame.statusText:SetText(COLOR_GREEN .. "Detected: Single layout '" .. (decoded.name or "?") .. "' (" .. (decoded.class or "?") .. ")|r")
                elseif scope == "template" then
                    importFrame.statusText:SetText(COLOR_GREEN .. "Detected: Template '" .. (decoded.name or "?") .. "' (" .. (decoded.class or "?") .. ")|r")
                else
                    importFrame.statusText:SetText(COLOR_GREEN .. "Detected: " .. tostring(scope) .. "|r")
                end
            else
                importFrame.decoded = nil
                importFrame.scope = nil
                importFrame.statusText:SetText(COLOR_RED .. (err or "Invalid string.") .. "|r")
            end
        end)

        local importBtn = CreateBtn(importFrame, "Import", 120, 28)
        importBtn:SetPoint("BOTTOMRIGHT", -PADDING - 4, PADDING + 4)
        importBtn:SetScript("OnClick", function()
            if not importFrame.decoded or not importFrame.scope then
                ns.Print("Paste a valid string first.")
                return
            end

            local scope = importFrame.scope
            if scope == "cdm" then
                local name = importFrame.nameBox:GetText()
                if not name then name = "" end
                name = name:match("^%s*(.-)%s*$")
                if name == "" then name = "Imported" end

                -- For CDM strings, import as template into library
                local class = importFrame.classDropdown:GetSelected() or ns.GetClassToken()
                local spec = importFrame.specDropdown:GetSelected()
                local uuid, errMsg = ns.AddTemplate(name, class, spec, importFrame.decoded.data)
                if uuid then
                    local specStr = spec and (" / " .. spec) or ""
                    ns.Print(COLOR_GREEN .. "Imported template: " .. name .. " (" .. class .. specStr .. ")|r")
                    importFrame:Hide()
                    ns.RefreshUI()
                else
                    ns.Print("|cFFFF0000Error:|r " .. (errMsg or "unknown"))
                end
            elseif scope == "globalProfile" then
                local existingUUID = ns.FindGlobalProfileByName(importFrame.decoded.name)
                if existingUUID then
                    local dialog = StaticPopup_Show("COOLDOWNMASTER_IMPORT_PROFILE_CONFLICT", importFrame.decoded.name)
                    if dialog then
                        dialog.data = { decoded = importFrame.decoded, existingUUID = existingUUID }
                    end
                else
                    local ok, msg = ns.ApplyImport(importFrame.decoded, scope)
                    if ok then
                        ns.Print(COLOR_GREEN .. msg .. "|r")
                    else
                        ns.Print("|cFFFF0000Error:|r " .. (msg or "unknown"))
                    end
                end
                importFrame:Hide()
                ns.RefreshUI()

            elseif scope == "classLayouts" then
                local classToken = importFrame.decoded.class
                local activeUUID = ns.GetActiveGlobalProfileUUID and ns.GetActiveGlobalProfileUUID()
                if not activeUUID then
                    -- No active profile — create one, then import directly (no conflicts possible)
                    local ok, msg = ns.ApplyImport(importFrame.decoded, scope)
                    if ok then
                        ns.Print(COLOR_GREEN .. msg .. "|r")
                    else
                        ns.Print("|cFFFF0000Error:|r " .. (msg or "unknown"))
                    end
                else
                    local conflicts = ns.FindConflictingLayerNames(activeUUID, classToken, importFrame.decoded.layouts)
                    if #conflicts > 0 then
                        local conflictStr = table.concat(conflicts, ", ")
                        local dialog = StaticPopup_Show("COOLDOWNMASTER_IMPORT_LAYERS_CONFLICT", conflictStr)
                        if dialog then
                            dialog.data = { decoded = importFrame.decoded, profileUUID = activeUUID }
                        end
                    else
                        local ok, msg = ns.ApplyImport(importFrame.decoded, scope)
                        if ok then
                            ns.Print(COLOR_GREEN .. msg .. "|r")
                        else
                            ns.Print("|cFFFF0000Error:|r " .. (msg or "unknown"))
                        end
                    end
                end
                importFrame:Hide()
                ns.RefreshUI()

            else
                local ok, msg = ns.ApplyImport(importFrame.decoded, scope)
                if ok then
                    ns.Print(COLOR_GREEN .. msg .. "|r")
                    importFrame:Hide()
                    ns.RefreshUI()
                else
                    ns.Print("|cFFFF0000Error:|r " .. (msg or "unknown"))
                end
            end

            importFrame.decoded = nil
            importFrame.scope = nil
        end)

        local cancelBtn = CreateBtn(importFrame, "Cancel", 80, 28)
        cancelBtn:SetPoint("RIGHT", importBtn, "LEFT", -6, 0)
        cancelBtn:SetScript("OnClick", function()
            importFrame:Hide()
        end)
    end

    importFrame.editBox:SetText("")
    importFrame.nameBox:SetText("Imported")
    importFrame.classDropdown:SetSelected(ns.GetClassToken())
    importFrame.specDropdown:SetItems(BuildSpecItems(ns.GetClassToken()))
    importFrame.specDropdown:SetSelected(nil)
    importFrame.statusText:SetText(COLOR_DIM .. "Waiting for input...|r")
    importFrame.decoded = nil
    importFrame.scope = nil
    importFrame:Show()
    importFrame:Raise()

    C_Timer.After(0.05, function()
        importFrame.editBox:SetFocus()
    end)
end

---------------------------------------------------------------------------
-- Edit Template Window
---------------------------------------------------------------------------

local editTmplFrame

function ns.ShowEditTemplateWindow(uuid)
    local tmpl = ns.GetTemplateByUUID(uuid)
    if not tmpl then
        ns.Print("|cFFFF0000Template not found.|r")
        return
    end

    if not editTmplFrame then
        editTmplFrame = CreateBackdropFrame("CooldownMasterEditTmplFrame", UIParent, 480, 420)
        editTmplFrame:SetPoint("CENTER", 220, 0)
        editTmplFrame:SetMovable(true)
        editTmplFrame:EnableMouse(true)
        editTmplFrame:SetClampedToScreen(true)
        editTmplFrame:RegisterForDrag("LeftButton")
        editTmplFrame:SetScript("OnDragStart", editTmplFrame.StartMoving)
        editTmplFrame:SetScript("OnDragStop", editTmplFrame.StopMovingOrSizing)
        editTmplFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        editTmplFrame:Hide()

        table.insert(UISpecialFrames, "CooldownMasterEditTmplFrame")

        local title = editTmplFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -14)
        title:SetText(COLOR_TITLE .. "Edit Template|r")

        local closeBtn = CreateFrame("Button", nil, editTmplFrame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -4, -4)

        -- Name
        local nameLabel = editTmplFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameLabel:SetPoint("TOPLEFT", PADDING + 4, -42)
        nameLabel:SetText("Name:")

        local nameBox = CreateFrame("EditBox", nil, editTmplFrame, "InputBoxTemplate")
        nameBox:SetSize(200, 22)
        nameBox:SetPoint("TOPLEFT", PADDING + 80, -39)
        nameBox:SetAutoFocus(false)
        nameBox:SetMaxLetters(50)
        editTmplFrame.nameBox = nameBox

        -- Class
        local classDropdown = CreateCustomDropdown(editTmplFrame, "Class:")
        classDropdown:SetPoint("TOPLEFT", PADDING + 4, -66)
        classDropdown:SetPoint("TOPRIGHT", -(PADDING + 4), -66)
        classDropdown:SetItems(BuildClassItems())
        editTmplFrame.classDropdown = classDropdown

        -- Spec
        local specDropdown = CreateCustomDropdown(editTmplFrame, "Spec:")
        specDropdown:SetPoint("TOPLEFT", PADDING + 4, -90)
        specDropdown:SetPoint("TOPRIGHT", -(PADDING + 4), -90)
        editTmplFrame.specDropdown = specDropdown

        classDropdown.onChanged = function(classToken)
            specDropdown:SetItems(BuildSpecItems(classToken))
            specDropdown:SetSelected(nil)
        end

        -- Data label
        local dataLabel = editTmplFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        dataLabel:SetPoint("TOPLEFT", PADDING + 4, -116)
        dataLabel:SetText("Layout data:")

        -- Data text area
        local scrollFrame = CreateFrame("ScrollFrame", nil, editTmplFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", PADDING + 4, -132)
        scrollFrame:SetSize(440, 190)

        local dataBox = CreateFrame("EditBox", nil, scrollFrame)
        dataBox:SetMultiLine(true)
        dataBox:SetAutoFocus(false)
        dataBox:SetFontObject("ChatFontNormal")
        dataBox:SetWidth(420)
        dataBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        scrollFrame:SetScrollChild(dataBox)
        editTmplFrame.dataBox = dataBox

        -- Save button
        local saveBtn = CreateBtn(editTmplFrame, "Save", 120, 28)
        saveBtn:SetPoint("BOTTOMRIGHT", -PADDING - 4, PADDING + 4)
        saveBtn:SetScript("OnClick", function()
            local curUUID = editTmplFrame.editingUUID
            if not curUUID then return end

            local name = (editTmplFrame.nameBox:GetText() or ""):match("^%s*(.-)%s*$")
            if name == "" then
                ns.Print("|cFFFF0000Name cannot be empty.|r")
                return
            end

            local class = editTmplFrame.classDropdown:GetSelected()
            local spec = editTmplFrame.specDropdown:GetSelected()
            local data = editTmplFrame.dataBox:GetText()
            if not data or data:match("^%s*$") then
                ns.Print("|cFFFF0000Layout data cannot be empty.|r")
                return
            end

            local ok, err = ns.UpdateTemplate(curUUID, name, class, spec, data)
            if ok then
                ns.Print(COLOR_GREEN .. "Template updated: " .. name .. "|r")
                editTmplFrame:Hide()
            else
                ns.Print("|cFFFF0000Error:|r " .. (err or "unknown"))
            end
        end)

        -- Cancel button
        local cancelBtn = CreateBtn(editTmplFrame, "Cancel", 80, 28)
        cancelBtn:SetPoint("BOTTOMLEFT", PADDING + 4, PADDING + 4)
        cancelBtn:SetScript("OnClick", function() editTmplFrame:Hide() end)
    end

    -- Populate fields from template
    editTmplFrame.editingUUID = uuid
    editTmplFrame.nameBox:SetText(tmpl.name or "")
    editTmplFrame.classDropdown:SetItems(BuildClassItems())
    editTmplFrame.classDropdown:SetSelected(tmpl.class)
    editTmplFrame.specDropdown:SetItems(BuildSpecItems(tmpl.class))
    editTmplFrame.specDropdown:SetSelected(tmpl.spec)
    editTmplFrame.dataBox:SetText(tmpl.data or "")

    editTmplFrame:Show()
    editTmplFrame:Raise()
end
