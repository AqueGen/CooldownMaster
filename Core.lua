local addonName, ns = ...

ns.ADDON_NAME = "Cooldown Manager Profiles"
ns.VERSION = "2.0.0"
ns.PREFIX_COLOR = "|cFF00CCFF"
ns.DB_VERSION = 4

-- State
ns.db = nil
ns.charKey = nil
ns.dataLoaded = false
ns.layoutManager = nil

-- Libraries
ns.LibDeflate = LibStub:GetLibrary("LibDeflate")

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

function ns.Print(msg)
    print(ns.PREFIX_COLOR .. "[CM]|r " .. tostring(msg))
end

function ns.GetCharKey()
    if ns.charKey then return ns.charKey end
    local name, realm = UnitFullName("player")
    if not name or name == "" then return nil end
    realm = realm or GetNormalizedRealmName() or ""
    ns.charKey = name .. "-" .. realm
    return ns.charKey
end

function ns.GetSpecID()
    local idx = GetSpecialization()
    if not idx then return 0 end
    return GetSpecializationInfo(idx) or 0
end

function ns.GetSpecName(id)
    if not id or id == 0 then return "No Spec" end
    local _, name = GetSpecializationInfoByID(id)
    return name or ("Spec " .. id)
end

function ns.GetClassID()
    local _, _, id = UnitClass("player")
    return id or 0
end

function ns.GetClassToken()
    local _, token = UnitClass("player")
    return token or "UNKNOWN"
end

-- Simple UUID generator (hex string, unique enough for addon use)
local uuidCounter = 0
function ns.GenerateUUID()
    uuidCounter = uuidCounter + 1
    return string.format("%x%x%x", time(), math.random(0, 0xFFFF), uuidCounter)
end

-- Canonical class tokens for display and lookup
ns.CLASS_TOKENS = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK",
    "DRUID", "DEMONHUNTER", "EVOKER",
}

ns.CLASS_TOKEN_SET = {}
ns.CLASS_TOKENS_INDEX = {}
for i, t in ipairs(ns.CLASS_TOKENS) do
    ns.CLASS_TOKEN_SET[t] = true
    ns.CLASS_TOKENS_INDEX[t] = i
end

function ns.EnsureCDMLoaded()
    if CooldownViewerSettings then return true end
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_CooldownViewer")
    end
    return CooldownViewerSettings ~= nil
end

function ns.GetLayoutManager()
    if ns.layoutManager then return ns.layoutManager end
    ns.EnsureCDMLoaded()
    if CooldownViewerSettings and CooldownViewerSettings.GetLayoutManager then
        local ok, lm = pcall(CooldownViewerSettings.GetLayoutManager, CooldownViewerSettings)
        if ok and lm then
            ns.layoutManager = lm
        end
    end
    return ns.layoutManager
end

---------------------------------------------------------------------------
-- Database
---------------------------------------------------------------------------

--[[
CooldownManagerProfilesDB = {
    version = 4,

    -- v4: Global Template Library (account-wide, individual layouts)
    templateLibrary = {
        [uuid] = { name = "M+ Burst", class = "MAGE", spec = "Arcane",
                    data = "1|...", created = N, modified = N },
    },

    -- v4: Global Profiles (account-wide, layouts organized by class)
    globalProfiles = {
        [uuid] = {
            name = "My Main Setup", description = "", created = N, modified = N,
            layouts = {
                ["MAGE"] = {
                    { name = "M+ Burst", spec = "Arcane", sourceTemplate = uuid,
                      data = "1|...", created = N, modified = N },
                },
            },
        },
    },

    -- v4: Per-character state for global profiles
    characters = {
        ["Char-Realm"] = { activeGlobalProfile = uuid },
    },

    -- Per-character profiles (full Blizzard CDM blobs)
    profiles = {
        ["Char-Realm"] = {
            ["Luxthos"]  = { data = "1|...", created = N, modified = N },
        }
    },
    activeProfile = { ["Char-Realm"] = "Luxthos" },

    settings = {},
}
]]

--- Detect class token from a specTag string (e.g. "MageArcane" -> "MAGE")
local SPEC_TAG_CLASS_MAP = {
    warrior = "WARRIOR", paladin = "PALADIN", hunter = "HUNTER",
    rogue = "ROGUE", priest = "PRIEST", deathknight = "DEATHKNIGHT",
    shaman = "SHAMAN", mage = "MAGE", warlock = "WARLOCK",
    monk = "MONK", druid = "DRUID", demonhunter = "DEMONHUNTER",
    evoker = "EVOKER",
}

function ns.ClassTokenFromSpecTag(specTag)
    if not specTag or specTag == "" then return nil end
    local lower = tostring(specTag):lower()
    for pattern, token in pairs(SPEC_TAG_CLASS_MAP) do
        if lower:find(pattern) then return token end
    end
    return nil
end

--- Extract spec portion from specTag (e.g. "MageArcane" -> "Arcane")
function ns.SpecFromSpecTag(specTag)
    if not specTag or specTag == "" then return nil end
    local s = tostring(specTag)
    for pattern in pairs(SPEC_TAG_CLASS_MAP) do
        local pos = s:lower():find(pattern)
        if pos then
            local after = s:sub(pos + #pattern)
            if after ~= "" then return after end
            return nil
        end
    end
    return nil
end

function ns.InitDB()
    -- Migrate from old CooldownMasterDB if it has data
    if CooldownMasterDB and next(CooldownMasterDB) then
        if not CooldownManagerProfilesDB or not next(CooldownManagerProfilesDB) then
            CooldownManagerProfilesDB = CooldownMasterDB
        end
        CooldownMasterDB = nil
    end

    if not CooldownManagerProfilesDB then CooldownManagerProfilesDB = {} end
    local db = CooldownManagerProfilesDB

    db.version = ns.DB_VERSION

    -- Ensure all tables exist
    if not db.profiles then db.profiles = {} end
    if not db.activeProfile then db.activeProfile = {} end
    if not db.layoutNameOverrides then db.layoutNameOverrides = {} end
    if not db.templateLibrary then db.templateLibrary = {} end
    if not db.globalProfiles then db.globalProfiles = {} end
    if not db.characters then db.characters = {} end
    if not db.settings then db.settings = {} end
    if db.settings.showMinimap == nil then db.settings.showMinimap = true end
    if db.settings.verboseChat == nil then db.settings.verboseChat = true end
    if not db.settings.minimapPos then db.settings.minimapPos = {} end

    ns.db = db
end

function ns.EnsureCharTables(charKey)
    charKey = charKey or ns.charKey
    if not charKey then return end
    if not ns.db.profiles[charKey] then ns.db.profiles[charKey] = {} end
    if not ns.db.layoutNameOverrides[charKey] then ns.db.layoutNameOverrides[charKey] = {} end
    if not ns.db.characters[charKey] then ns.db.characters[charKey] = {} end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local ef = CreateFrame("Frame")
ef:RegisterEvent("ADDON_LOADED")
ef:RegisterEvent("PLAYER_ENTERING_WORLD")
ef:RegisterEvent("PLAYER_REGEN_ENABLED")

ef:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addonName then
            ns.InitDB()
            ns.charKey = ns.GetCharKey()
            if ns.charKey then ns.EnsureCharTables() end
            if C_CooldownViewer then
                self:RegisterEvent("COOLDOWN_VIEWER_DATA_LOADED")
            end
            -- Init minimap icon & settings panel
            if ns.InitMinimapIcon then ns.InitMinimapIcon() end
            if ns.RegisterSettings then ns.RegisterSettings() end
            self:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        if not ns.charKey then
            ns.charKey = ns.GetCharKey()
            if ns.charKey then ns.EnsureCharTables() end
        end
        if C_CooldownViewer and not ns.dataLoaded then
            C_Timer.After(3, function()
                if not ns.dataLoaded then
                    if C_CooldownViewer.IsCooldownViewerAvailable() then
                        ns.dataLoaded = true
                        ns.GetLayoutManager()
                        ns.OnDataReady()
                    end
                end
            end)
        end

    elseif event == "COOLDOWN_VIEWER_DATA_LOADED" then
        ns.dataLoaded = true
        ns.GetLayoutManager()
        ns.OnDataReady()
        -- Subscribe to CDM changes for reactive UI updates
        if EventRegistry then
            EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
                if ns.AutoSaveActiveProfile then ns.AutoSaveActiveProfile() end
                if ns.RefreshUI then ns.RefreshUI() end
            end, ns)
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        if ns.pendingProfileLoad then
            local name = ns.pendingProfileLoad
            ns.pendingProfileLoad = nil
            ns.Print("Combat ended. Loading profile: " .. name)
            ns.LoadProfile(name)
        end
        if ns.pendingGlobalProfileLoad then
            local uuid = ns.pendingGlobalProfileLoad
            ns.pendingGlobalProfileLoad = nil
            ns.Print("Combat ended. Loading global profile.")
            ns.LoadGlobalProfile(uuid)
        end
    end
end)

function ns.OnDataReady()
    if not ns.charKey then return end
    ns.EnsureCharTables()

    -- Auto-create "Default" profile from current state if no profiles exist
    local hasAny = false
    for _ in pairs(ns.db.profiles[ns.charKey]) do hasAny = true; break end

    if not hasAny then
        local data = C_CooldownViewer.GetLayoutData()
        if data and data ~= "" then
            ns.db.profiles[ns.charKey]["Default"] = {
                data = data, created = time(), modified = time(),
                layoutInfo = ns.CaptureLayoutMeta and ns.CaptureLayoutMeta() or nil,
            }
            ns.db.activeProfile[ns.charKey] = "Default"
            ns.Print("Created 'Default' profile from current state.")
        end
    else
        -- Auto-sync: pull current Blizzard data into active profile (silent)
        if ns.SyncFromBlizzard then
            ns.SyncFromBlizzard(true)
        end
    end

    if ns.RefreshUI then ns.RefreshUI() end
end

---------------------------------------------------------------------------
-- Slash Commands
---------------------------------------------------------------------------

SLASH_COOLDOWNMANAGERPROFILES1 = "/cm"
SLASH_COOLDOWNMANAGERPROFILES2 = "/cmp"

SlashCmdList["COOLDOWNMANAGERPROFILES"] = function(msg)
    msg = msg or ""
    local cmd, arg = msg:match("^(%S+)%s*(.*)")
    if not cmd then ns.ToggleUI(); return end
    cmd = cmd:lower()
    arg = arg and arg:match("^%s*(.-)%s*$") or ""

    if cmd == "save" then
        if arg == "" then ns.Print("Usage: /cm save <profile name>"); return end
        local ok, err = ns.SaveProfile(arg, true)
        ns.Print(ok and ("Profile saved: " .. arg) or ("|cFFFF0000Error:|r " .. err))

    elseif cmd == "load" then
        if arg == "" then ns.Print("Usage: /cm load <profile name>"); return end
        local ok, err = ns.LoadProfile(arg)
        ns.Print(ok and ("Profile loaded: " .. arg) or ("|cFFFF0000Error:|r " .. err))

    elseif cmd == "list" then
        ns.PrintAll()

    elseif cmd == "import" then
        ns.ShowImportWindow()

    elseif cmd == "export" then
        ns.ShowExportWindow()

    elseif cmd == "settings" or cmd == "config" or cmd == "options" then
        if ns.OpenSettings then ns.OpenSettings() end

    elseif cmd == "help" then
        ns.Print("Commands:")
        print("  /cm              - Toggle UI")
        print("  /cm save <name>  - Save current Blizzard state as profile")
        print("  /cm load <name>  - Load a profile (replaces Blizzard layouts)")
        print("  /cm list         - List all profiles")
        print("  /cm import       - Open import window")
        print("  /cm export       - Open export window")
        print("  /cm settings     - Open addon settings (ESC panel)")
        print("  /cm help         - Show this help")
    else
        ns.Print("Unknown command. Type /cm help")
    end
end
