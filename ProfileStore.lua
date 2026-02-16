local _, ns = ...

---------------------------------------------------------------------------
-- Layout Metadata Capture
-- Stores layout names/class/spec info alongside profile blob for preview
---------------------------------------------------------------------------

--- Capture current Blizzard layout metadata (names, specs, classes)
function ns.CaptureLayoutMeta()
    local lm = ns.GetLayoutManager()
    if not lm or not lm.EnumerateLayouts then return nil end
    local meta = {}
    local ok = pcall(function()
        for layoutID, layout in lm:EnumerateLayouts() do
            local entry = { id = layoutID }
            if CooldownManagerLayout_GetName then
                pcall(function() entry.name = CooldownManagerLayout_GetName(layout) end)
            end
            if CooldownManagerLayout_GetClassAndSpecTag then
                pcall(function() entry.specTag = CooldownManagerLayout_GetClassAndSpecTag(layout) end)
            end
            entry.name = entry.name or ("Layout " .. layoutID)
            entry.specTag = entry.specTag and tostring(entry.specTag) or ""
            meta[#meta + 1] = entry
        end
    end)
    if not ok or #meta == 0 then return nil end
    return meta
end

---------------------------------------------------------------------------
-- PROFILES (blob swap — each profile = full Blizzard state, up to 5 layouts)
---------------------------------------------------------------------------

--- Save current Blizzard state as a named profile
function ns.SaveProfile(name, overwrite)
    if not name or name == "" then return false, "Name cannot be empty." end
    if #name > 50 then return false, "Name too long (max 50)." end
    if not ns.charKey then return false, "Character not ready." end
    if not C_CooldownViewer then return false, "CDM not available." end

    ns.EnsureCharTables()
    local profiles = ns.db.profiles[ns.charKey]
    if profiles[name] and not overwrite then
        return false, "Profile '" .. name .. "' already exists."
    end

    local data = C_CooldownViewer.GetLayoutData()
    if not data or data == "" then
        return false, "No layout data. Configure the Cooldown Manager first."
    end

    profiles[name] = {
        data = data,
        created = profiles[name] and profiles[name].created or time(),
        modified = time(),
        layoutInfo = ns.CaptureLayoutMeta(),
    }
    ns.db.activeProfile[ns.charKey] = name

    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Load a profile into Blizzard (replaces all 5 slots)
function ns.LoadProfile(name)
    if not name or name == "" then return false, "Name cannot be empty." end
    if not ns.charKey then return false, "Character not ready." end
    if InCombatLockdown() then
        ns.pendingProfileLoad = name
        return false, "In combat. Queued for after."
    end
    if not ns.dataLoaded then return false, "CDM data not loaded yet." end

    ns.EnsureCharTables()
    local profile = ns.db.profiles[ns.charKey][name]
    if not profile then return false, "Profile '" .. name .. "' not found." end
    if not profile.data or profile.data == "" then return false, "Profile has no data." end

    -- Auto-save current state to active profile before switching
    local active = ns.db.activeProfile[ns.charKey]
    if active and active ~= name and ns.db.profiles[ns.charKey][active] then
        local curData = C_CooldownViewer.GetLayoutData()
        if curData and curData ~= "" then
            ns.db.profiles[ns.charKey][active].data = curData
            ns.db.profiles[ns.charKey][active].modified = time()
            ns.db.profiles[ns.charKey][active].layoutInfo = ns.CaptureLayoutMeta()
        end
    end

    C_CooldownViewer.SetLayoutData(profile.data)
    ns.db.activeProfile[ns.charKey] = name
    ns.RefreshViewers()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.DeleteProfile(name)
    if not name or not ns.charKey then return false, "Invalid." end
    ns.EnsureCharTables()
    if not ns.db.profiles[ns.charKey][name] then
        return false, "Profile not found."
    end
    if ns.db.activeProfile[ns.charKey] == name then
        return false, "Cannot delete active profile. Switch first."
    end
    ns.db.profiles[ns.charKey][name] = nil
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.RenameProfile(oldName, newName)
    if not oldName or not newName or newName == "" then return false, "Invalid names." end
    if #newName > 50 then return false, "Name too long." end
    if not ns.charKey then return false, "Character not ready." end
    ns.EnsureCharTables()
    local profiles = ns.db.profiles[ns.charKey]
    if not profiles[oldName] then return false, "Profile not found." end
    if profiles[newName] then return false, "Name already taken." end

    profiles[newName] = profiles[oldName]
    profiles[oldName] = nil
    if ns.db.activeProfile[ns.charKey] == oldName then
        ns.db.activeProfile[ns.charKey] = newName
    end
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.GetActiveProfileName()
    if not ns.charKey then return nil end
    return ns.db.activeProfile[ns.charKey]
end

function ns.GetProfileList()
    if not ns.charKey then return {} end
    ns.EnsureCharTables()
    local list = {}
    for name, info in pairs(ns.db.profiles[ns.charKey]) do
        list[#list + 1] = { name = name, created = info.created or 0, modified = info.modified or 0 }
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function ns.GetProfileLayoutInfo(profileName)
    if not ns.charKey or not profileName then return nil end
    ns.EnsureCharTables()
    local profile = ns.db.profiles[ns.charKey][profileName]
    if not profile then return nil end
    return profile.layoutInfo
end

function ns.GetProfileCount()
    local n = 0
    if ns.charKey and ns.db.profiles[ns.charKey] then
        for _ in pairs(ns.db.profiles[ns.charKey]) do n = n + 1 end
    end
    return n
end

---------------------------------------------------------------------------
-- BLIZZARD LAYOUTS (individual layouts within active profile)
-- NOTE: LayoutManager API (EnumerateLayouts, GetSerializer, etc.) is
-- internal Blizzard API that may not exist. All calls are pcall-guarded.
---------------------------------------------------------------------------

function ns.GetBlizzardLayouts()
    local lm = ns.GetLayoutManager()
    if not lm or not lm.EnumerateLayouts then return {} end
    local layouts = {}
    local ok, err = pcall(function()
        for layoutID, layout in lm:EnumerateLayouts() do
            local name = "Layout " .. layoutID
            local specTag = ""
            local isDef = false
            if CooldownManagerLayout_GetName then
                name = CooldownManagerLayout_GetName(layout) or name
            end
            if CooldownManagerLayout_GetClassAndSpecTag then
                local raw = CooldownManagerLayout_GetClassAndSpecTag(layout)
                specTag = raw and tostring(raw) or ""
            end
            if CooldownManagerLayout_IsDefaultLayout then
                isDef = CooldownManagerLayout_IsDefaultLayout(layout) or false
            end
            layouts[#layouts + 1] = {
                id = layoutID, name = name, specTag = specTag, isDefault = isDef,
            }
        end
    end)
    if not ok then return {} end
    table.sort(layouts, function(a, b) return a.id < b.id end)
    -- Apply local name overrides
    local overrides = ns.charKey and ns.db.layoutNameOverrides
        and ns.db.layoutNameOverrides[ns.charKey]
    if overrides then
        for _, l in ipairs(layouts) do
            if overrides[l.id] then l.name = overrides[l.id] end
        end
    end
    local activeOk, activeID = pcall(lm.GetActiveLayoutID, lm)
    if activeOk and activeID then
        for _, l in ipairs(layouts) do
            l.isActive = (l.id == activeID)
        end
    end
    return layouts
end

function ns.GetBlizzardLayoutCount()
    local lm = ns.GetLayoutManager()
    if not lm or not lm.EnumerateLayouts then return 0 end
    local n = 0
    local ok = pcall(function()
        for _ in lm:EnumerateLayouts() do n = n + 1 end
    end)
    return ok and n or 0
end

function ns.HasFreeBlizzardSlot()
    return ns.GetBlizzardLayoutCount() < 5
end

---------------------------------------------------------------------------
-- STORED LAYOUTS (unattached, not in any profile, not in Blizzard)
---------------------------------------------------------------------------

function ns.GetStoredLayouts()
    if not ns.charKey then return {} end
    ns.EnsureCharTables()
    return ns.db.storedLayouts[ns.charKey]
end

--- Move a Blizzard layout to unattached storage (frees a Blizzard slot)
function ns.StoreBlizzardLayout(layoutID)
    local lm = ns.GetLayoutManager()
    if not lm then return false, "Layout manager not available." end
    if InCombatLockdown() then return false, "In combat." end

    -- Try to get layout info and serialize it
    local ok, layout = pcall(lm.GetLayout, lm, layoutID)
    if not ok or not layout then return false, "Layout not found." end

    local name = "Layout " .. layoutID
    local specTag = ""
    if CooldownManagerLayout_GetName then
        pcall(function() name = CooldownManagerLayout_GetName(layout) or name end)
    end
    if CooldownManagerLayout_GetClassAndSpecTag then
        pcall(function()
            local raw = CooldownManagerLayout_GetClassAndSpecTag(layout)
            specTag = raw and tostring(raw) or ""
        end)
    end

    -- Try to serialize individual layout
    local data
    if lm.GetSerializer then
        local serOk, serializer = pcall(lm.GetSerializer, lm)
        if serOk and serializer and serializer.SerializeLayouts then
            local dataOk, result = pcall(serializer.SerializeLayouts, serializer, layoutID)
            if dataOk then data = result end
        end
    end
    if not data or data == "" then return false, "Serialize failed. LayoutManager API may not support this." end

    ns.EnsureCharTables()
    local stored = ns.db.storedLayouts[ns.charKey]
    stored[#stored + 1] = {
        name = name, specTag = specTag, data = data,
        created = time(), modified = time(),
    }

    pcall(lm.RemoveLayout, lm, layoutID)

    ns.AutoSaveActiveProfile()
    ns.RefreshViewers()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Copy a Blizzard layout to storage (keeps original in Blizzard)
function ns.CopyBlizzardLayout(layoutID)
    local lm = ns.GetLayoutManager()
    if not lm then return false, "Layout manager not available." end

    local ok, layout = pcall(lm.GetLayout, lm, layoutID)
    if not ok or not layout then return false, "Layout not found." end

    local name = "Layout " .. layoutID
    local specTag = ""
    if CooldownManagerLayout_GetName then
        pcall(function() name = CooldownManagerLayout_GetName(layout) or name end)
    end
    if CooldownManagerLayout_GetClassAndSpecTag then
        pcall(function()
            local raw = CooldownManagerLayout_GetClassAndSpecTag(layout)
            specTag = raw and tostring(raw) or ""
        end)
    end

    local data
    if lm.GetSerializer then
        local serOk, serializer = pcall(lm.GetSerializer, lm)
        if serOk and serializer and serializer.SerializeLayouts then
            local dataOk, result = pcall(serializer.SerializeLayouts, serializer, layoutID)
            if dataOk then data = result end
        end
    end
    if not data or data == "" then return false, "Serialize failed." end

    ns.EnsureCharTables()
    local stored = ns.db.storedLayouts[ns.charKey]
    stored[#stored + 1] = {
        name = name, specTag = specTag, data = data,
        created = time(), modified = time(),
    }

    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Delete a Blizzard layout without storing it
function ns.DeleteBlizzardLayout(layoutID)
    local lm = ns.GetLayoutManager()
    if not lm then return false, "Layout manager not available." end
    if InCombatLockdown() then return false, "In combat." end

    local ok, layout = pcall(lm.GetLayout, lm, layoutID)
    if not ok or not layout then return false, "Layout not found." end

    pcall(lm.RemoveLayout, lm, layoutID)

    ns.AutoSaveActiveProfile()
    ns.RefreshViewers()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Rename a Blizzard layout (local override + Blizzard API if available)
function ns.RenameBlizzardLayout(layoutID, newName)
    if not newName or newName == "" then return false, "Empty name." end
    if #newName > 50 then return false, "Name too long (max 50)." end
    if not ns.charKey then return false, "Character not ready." end

    local lm = ns.GetLayoutManager()
    if not lm then return false, "Layout manager not available." end

    local ok, layout = pcall(lm.GetLayout, lm, layoutID)
    if not ok or not layout then return false, "Layout not found." end

    -- Try Blizzard API if available
    if CooldownManagerLayout_SetName then
        pcall(CooldownManagerLayout_SetName, layout, newName)
    end

    -- Always store local override as fallback
    ns.EnsureCharTables()
    ns.db.layoutNameOverrides[ns.charKey][layoutID] = newName

    ns.AutoSaveActiveProfile()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Move a stored layout into Blizzard (needs free slot)
function ns.ActivateStoredLayout(index)
    local lm = ns.GetLayoutManager()
    if not lm then return false, "Layout manager not available." end
    if InCombatLockdown() then return false, "In combat." end
    if not ns.dataLoaded then return false, "CDM not loaded." end
    if not ns.HasFreeBlizzardSlot() then
        return false, "No free Blizzard slots (5/5). Store one first."
    end

    ns.EnsureCharTables()
    local stored = ns.db.storedLayouts[ns.charKey]
    local entry = stored[index]
    if not entry then return false, "Stored layout #" .. index .. " not found." end
    if not entry.data or entry.data == "" then return false, "No data." end

    if not lm.CreateLayoutsFromSerializedData then
        return false, "LayoutManager does not support CreateLayoutsFromSerializedData."
    end

    local ok, result = pcall(lm.CreateLayoutsFromSerializedData, lm, entry.data)
    if not ok or not result then return false, "Import failed: " .. tostring(result or "unknown") end

    table.remove(stored, index)

    ns.AutoSaveActiveProfile()
    ns.RefreshViewers()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Import a CDM string to unattached storage
function ns.ImportCDMString(cdmString, customName)
    if not cdmString or cdmString == "" then return false, "Empty string." end
    cdmString = cdmString:match("^%s*(.-)%s*$")
    if not cdmString:match("^%d+|") then
        return false, "Not a valid CDM string."
    end
    ns.EnsureCharTables()
    local stored = ns.db.storedLayouts[ns.charKey]
    stored[#stored + 1] = {
        name = customName or "Imported", specTag = "", data = cdmString,
        created = time(), modified = time(),
    }
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Import a CDM string directly into Blizzard (active profile)
function ns.ImportCDMToBlizzard(cdmString)
    local lm = ns.GetLayoutManager()
    if not lm then return false, "Layout manager not available." end
    if InCombatLockdown() then return false, "In combat." end
    if not ns.HasFreeBlizzardSlot() then return false, "No free slots (5/5)." end

    if not lm.CreateLayoutsFromSerializedData then
        return false, "LayoutManager does not support this operation."
    end

    local ok, result = pcall(lm.CreateLayoutsFromSerializedData, lm, cdmString)
    if not ok or not result then return false, "Import failed." end

    ns.AutoSaveActiveProfile()
    ns.RefreshViewers()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Delete a stored layout
function ns.DeleteStoredLayout(index)
    ns.EnsureCharTables()
    local stored = ns.db.storedLayouts[ns.charKey]
    if not stored[index] then return false, "Not found." end
    table.remove(stored, index)
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Rename a stored layout
function ns.RenameStoredLayout(index, newName)
    if not newName or newName == "" then return false, "Empty name." end
    ns.EnsureCharTables()
    local stored = ns.db.storedLayouts[ns.charKey]
    if not stored[index] then return false, "Not found." end
    stored[index].name = newName
    stored[index].modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

---------------------------------------------------------------------------
-- Sync: capture current Blizzard state into active profile
---------------------------------------------------------------------------

function ns.SyncFromBlizzard(silent)
    if not ns.charKey then return false, "Character not ready." end
    if not C_CooldownViewer then return false, "CDM not available." end
    local data = C_CooldownViewer.GetLayoutData()
    if not data or data == "" then return false, "No layout data from Blizzard." end

    ns.EnsureCharTables()
    local active = ns.db.activeProfile[ns.charKey]
    local meta = ns.CaptureLayoutMeta()
    if not active then
        active = "Default"
        ns.db.profiles[ns.charKey][active] = {
            data = data, created = time(), modified = time(),
            layoutInfo = meta,
        }
        ns.db.activeProfile[ns.charKey] = active
        if not silent then ns.Print("Created 'Default' profile from Blizzard state.") end
    else
        ns.db.profiles[ns.charKey][active].data = data
        ns.db.profiles[ns.charKey][active].modified = time()
        ns.db.profiles[ns.charKey][active].layoutInfo = meta
        if not silent then ns.Print("Synced Blizzard state into profile: " .. active) end
    end
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

---------------------------------------------------------------------------
-- Export helpers
---------------------------------------------------------------------------

function ns.ExportBlizzardLayout(layoutID)
    local lm = ns.GetLayoutManager()
    if not lm then return nil, "Not available." end
    local ok, layout = pcall(lm.GetLayout, lm, layoutID)
    if not ok or not layout then return nil, "Not found." end
    if not lm.GetSerializer then return nil, "Serializer not available." end
    local serOk, serializer = pcall(lm.GetSerializer, lm)
    if not serOk or not serializer or not serializer.SerializeLayouts then
        return nil, "Serializer not available."
    end
    local dataOk, data = pcall(serializer.SerializeLayouts, serializer, layoutID)
    if not dataOk or not data or data == "" then return nil, "Serialize failed." end
    return data
end

function ns.ExportStoredLayout(index)
    ns.EnsureCharTables()
    local entry = ns.db.storedLayouts[ns.charKey][index]
    if not entry then return nil, "Not found." end
    return entry.data
end

function ns.ExportActiveProfile()
    local name = ns.GetActiveProfileName()
    if not name then return nil, "No active profile." end
    local profile = ns.db.profiles[ns.charKey][name]
    if not profile then return nil, "Profile not found." end
    return profile.data
end

---------------------------------------------------------------------------
-- Auto-save: keep active profile blob in sync with Blizzard
---------------------------------------------------------------------------

function ns.AutoSaveActiveProfile()
    if not ns.charKey or not ns.dataLoaded then return end
    local name = ns.db.activeProfile[ns.charKey]
    if not name then return end
    local profile = ns.db.profiles[ns.charKey] and ns.db.profiles[ns.charKey][name]
    if not profile then return end
    local data = C_CooldownViewer.GetLayoutData()
    if data and data ~= "" then
        profile.data = data
        profile.modified = time()
        profile.layoutInfo = ns.CaptureLayoutMeta()
    end
end

---------------------------------------------------------------------------
-- TEMPLATE LIBRARY (global, account-wide individual layouts)
---------------------------------------------------------------------------

function ns.AddTemplate(name, class, spec, data)
    if not name or name == "" then return nil, "Name cannot be empty." end
    if #name > 50 then return nil, "Name too long (max 50)." end
    if not data or data == "" then return nil, "No data." end
    class = class or "UNKNOWN"

    local uuid = ns.GenerateUUID()
    ns.db.templateLibrary[uuid] = {
        name = name,
        class = class,
        spec = spec,
        data = data,
        created = time(),
        modified = time(),
    }
    if ns.RefreshUI then ns.RefreshUI() end
    return uuid
end

function ns.DeleteTemplate(uuid)
    if not uuid or not ns.db.templateLibrary[uuid] then
        return false, "Template not found."
    end
    ns.db.templateLibrary[uuid] = nil
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.RenameTemplate(uuid, newName)
    if not newName or newName == "" then return false, "Empty name." end
    if #newName > 50 then return false, "Name too long (max 50)." end
    local tmpl = ns.db.templateLibrary[uuid]
    if not tmpl then return false, "Template not found." end
    tmpl.name = newName
    tmpl.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.UpdateTemplateClass(uuid, class)
    local tmpl = ns.db.templateLibrary[uuid]
    if not tmpl then return false, "Template not found." end
    tmpl.class = class or "UNKNOWN"
    tmpl.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.UpdateTemplate(uuid, name, class, spec, data)
    if not name or name == "" then return false, "Empty name." end
    if #name > 50 then return false, "Name too long (max 50)." end
    local tmpl = ns.db.templateLibrary[uuid]
    if not tmpl then return false, "Template not found." end
    tmpl.name = name
    tmpl.class = class or "UNKNOWN"
    tmpl.spec = spec
    tmpl.data = data or tmpl.data
    tmpl.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.GetTemplateList(classFilter)
    local list = {}
    for uuid, tmpl in pairs(ns.db.templateLibrary) do
        if not classFilter or tmpl.class == classFilter then
            list[#list + 1] = {
                uuid = uuid,
                name = tmpl.name,
                class = tmpl.class,
                spec = tmpl.spec,
                created = tmpl.created or 0,
                modified = tmpl.modified or 0,
            }
        end
    end
    table.sort(list, function(a, b)
        if a.class ~= b.class then return a.class < b.class end
        return a.name < b.name
    end)
    return list
end

function ns.GetTemplateByUUID(uuid)
    return ns.db.templateLibrary[uuid]
end

function ns.GetTemplateCount()
    local n = 0
    for _ in pairs(ns.db.templateLibrary) do n = n + 1 end
    return n
end

---------------------------------------------------------------------------
-- GLOBAL PROFILES (account-wide, layouts organized by class)
---------------------------------------------------------------------------

function ns.CreateGlobalProfile(name, description)
    if not name or name == "" then return nil, "Name cannot be empty." end
    if #name > 50 then return nil, "Name too long (max 50)." end

    local uuid = ns.GenerateUUID()
    ns.db.globalProfiles[uuid] = {
        name = name,
        description = description or "",
        created = time(),
        modified = time(),
        layouts = {},
    }
    if ns.RefreshUI then ns.RefreshUI() end
    return uuid
end

function ns.DeleteGlobalProfile(uuid)
    if not uuid or not ns.db.globalProfiles[uuid] then
        return false, "Profile not found."
    end
    -- Clear activeGlobalProfile references
    for charKey, charData in pairs(ns.db.characters) do
        if charData.activeGlobalProfile == uuid then
            charData.activeGlobalProfile = nil
        end
    end
    ns.db.globalProfiles[uuid] = nil
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.RenameGlobalProfile(uuid, newName)
    if not newName or newName == "" then return false, "Empty name." end
    if #newName > 50 then return false, "Name too long (max 50)." end
    local profile = ns.db.globalProfiles[uuid]
    if not profile then return false, "Profile not found." end
    profile.name = newName
    profile.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

function ns.GetGlobalProfileList()
    local list = {}
    for uuid, profile in pairs(ns.db.globalProfiles) do
        local layoutCount = 0
        local classCount = 0
        for classToken, layouts in pairs(profile.layouts) do
            classCount = classCount + 1
            layoutCount = layoutCount + #layouts
        end
        list[#list + 1] = {
            uuid = uuid,
            name = profile.name,
            description = profile.description,
            created = profile.created or 0,
            modified = profile.modified or 0,
            layoutCount = layoutCount,
            classCount = classCount,
        }
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function ns.GetGlobalProfile(uuid)
    return ns.db.globalProfiles[uuid]
end

function ns.GetGlobalProfileCount()
    local n = 0
    for _ in pairs(ns.db.globalProfiles) do n = n + 1 end
    return n
end

---------------------------------------------------------------------------
-- PROFILE LAYOUT MANAGEMENT
---------------------------------------------------------------------------

--- Add a layout directly to a profile (copies data)
function ns.AddLayoutToProfile(profileUUID, class, name, spec, data, sourceTemplate)
    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return false, "Profile not found." end
    if not class or not ns.CLASS_TOKEN_SET[class] then return false, "Invalid class." end
    if not data or data == "" then return false, "No data." end

    if not profile.layouts[class] then profile.layouts[class] = {} end
    local layouts = profile.layouts[class]

    layouts[#layouts + 1] = {
        name = name or "Layout",
        spec = spec,
        sourceTemplate = sourceTemplate,
        data = data,
        created = time(),
        modified = time(),
    }
    profile.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Add a template from the library to a profile (copies data)
function ns.AddTemplateToProfile(profileUUID, templateUUID)
    local tmpl = ns.db.templateLibrary[templateUUID]
    if not tmpl then return false, "Template not found." end
    return ns.AddLayoutToProfile(
        profileUUID, tmpl.class, tmpl.name, tmpl.spec, tmpl.data, templateUUID
    )
end

--- Remove a layout from a profile
function ns.RemoveLayoutFromProfile(profileUUID, class, index)
    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return false, "Profile not found." end
    local layouts = profile.layouts[class]
    if not layouts or not layouts[index] then return false, "Layout not found." end

    table.remove(layouts, index)
    if #layouts == 0 then profile.layouts[class] = nil end
    profile.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Rename a layout within a profile
function ns.RenameLayoutInProfile(profileUUID, class, index, newName)
    if not newName or newName == "" then return false, "Empty name." end
    if #newName > 50 then return false, "Name too long (max 50)." end
    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return false, "Profile not found." end
    local layouts = profile.layouts[class]
    if not layouts or not layouts[index] then return false, "Layout not found." end

    layouts[index].name = newName
    layouts[index].modified = time()
    profile.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

--- Get layouts for a profile, optionally filtered by class
function ns.GetProfileLayouts(profileUUID, classFilter)
    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return {} end

    local result = {}
    for classToken, layouts in pairs(profile.layouts) do
        if not classFilter or classToken == classFilter then
            for i, entry in ipairs(layouts) do
                result[#result + 1] = {
                    class = classToken,
                    index = i,
                    name = entry.name,
                    spec = entry.spec,
                    sourceTemplate = entry.sourceTemplate,
                    data = entry.data,
                    created = entry.created or 0,
                    modified = entry.modified or 0,
                }
            end
        end
    end

    table.sort(result, function(a, b)
        if a.class ~= b.class then return a.class < b.class end
        return a.index < b.index
    end)
    return result
end

--- Save a profile layout back to the template library
function ns.SaveLayoutAsTemplate(profileUUID, class, index)
    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return nil, "Profile not found." end
    local layouts = profile.layouts[class]
    if not layouts or not layouts[index] then return nil, "Layout not found." end

    local entry = layouts[index]
    return ns.AddTemplate(entry.name, class, entry.spec, entry.data)
end

--- Refresh a profile layout from its source template
function ns.RefreshLayoutFromTemplate(profileUUID, class, index)
    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return false, "Profile not found." end
    local layouts = profile.layouts[class]
    if not layouts or not layouts[index] then return false, "Layout not found." end

    local entry = layouts[index]
    if not entry.sourceTemplate then return false, "No source template linked." end

    local tmpl = ns.db.templateLibrary[entry.sourceTemplate]
    if not tmpl then return false, "Source template no longer exists." end

    entry.data = tmpl.data
    entry.modified = time()
    profile.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

---------------------------------------------------------------------------
-- LOAD GLOBAL PROFILE INTO BLIZZARD
---------------------------------------------------------------------------

function ns.GetActiveGlobalProfileUUID()
    if not ns.charKey then return nil end
    ns.EnsureCharTables()
    return ns.db.characters[ns.charKey].activeGlobalProfile
end

function ns.SetActiveGlobalProfileUUID(uuid)
    if not ns.charKey then return end
    ns.EnsureCharTables()
    ns.db.characters[ns.charKey].activeGlobalProfile = uuid
end

--- Load a global profile: applies layouts for the current character's class to Blizzard CDM
function ns.LoadGlobalProfile(profileUUID)
    if not profileUUID then return false, "No profile specified." end
    if not ns.charKey then return false, "Character not ready." end
    if InCombatLockdown() then
        ns.pendingGlobalProfileLoad = profileUUID
        return false, "In combat. Queued for after."
    end
    if not ns.dataLoaded then return false, "CDM data not loaded yet." end

    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return false, "Profile not found." end

    local classToken = ns.GetClassToken()
    local classLayouts = profile.layouts[classToken]

    if not classLayouts or #classLayouts == 0 then
        return false, "Profile has no layouts for " .. classToken .. "."
    end

    local lm = ns.GetLayoutManager()
    if not lm then return false, "Layout manager not available." end

    -- Auto-save current state into active profile before switching
    if ns.AutoSaveActiveProfile then ns.AutoSaveActiveProfile() end

    -- Remove all existing Blizzard layouts
    local existingLayouts = ns.GetBlizzardLayouts()
    for i = #existingLayouts, 1, -1 do
        pcall(lm.RemoveLayout, lm, existingLayouts[i].id)
    end

    -- Add each layout from the profile and rename to match profile names
    local loaded = 0
    for _, entry in ipairs(classLayouts) do
        if entry.data and entry.data ~= "" and loaded < 5 then
            if lm.CreateLayoutsFromSerializedData then
                -- Snapshot existing layout IDs before creating
                local beforeIDs = {}
                pcall(function()
                    for layoutID in lm:EnumerateLayouts() do
                        beforeIDs[layoutID] = true
                    end
                end)

                local ok = pcall(lm.CreateLayoutsFromSerializedData, lm, entry.data)
                if ok then
                    loaded = loaded + 1

                    -- Find newly created layout and rename it
                    if entry.name and entry.name ~= "" then
                        pcall(function()
                            for layoutID, layout in lm:EnumerateLayouts() do
                                if not beforeIDs[layoutID] then
                                    if CooldownManagerLayout_SetName then
                                        pcall(CooldownManagerLayout_SetName, layout, entry.name)
                                    end
                                    ns.EnsureCharTables()
                                    ns.db.layoutNameOverrides[ns.charKey][layoutID] = entry.name
                                    break
                                end
                            end
                        end)
                    end
                end
            end
        end
    end

    if loaded == 0 then
        return false, "Failed to load any layouts. Data may be incompatible."
    end

    ns.SetActiveGlobalProfileUUID(profileUUID)
    ns.RefreshViewers()
    if ns.RefreshUI then ns.RefreshUI() end
    return true, loaded .. " layout(s) loaded for " .. classToken .. "."
end

--- Capture current Blizzard layouts into a global profile for the current class
function ns.SyncBlizzardToGlobalProfile(profileUUID)
    if not profileUUID then return false, "No profile specified." end
    if not ns.charKey then return false, "Character not ready." end
    if not ns.dataLoaded then return false, "CDM not loaded." end

    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return false, "Profile not found." end

    local classToken = ns.GetClassToken()
    local lm = ns.GetLayoutManager()
    if not lm then return false, "Layout manager not available." end

    local blizzLayouts = ns.GetBlizzardLayouts()
    if #blizzLayouts == 0 then return false, "No Blizzard layouts to capture." end

    -- Replace class layouts in profile with current Blizzard state
    profile.layouts[classToken] = {}
    local captured = 0

    for _, l in ipairs(blizzLayouts) do
        local data = nil
        if lm.GetSerializer then
            local serOk, serializer = pcall(lm.GetSerializer, lm)
            if serOk and serializer and serializer.SerializeLayouts then
                local dataOk, result = pcall(serializer.SerializeLayouts, serializer, l.id)
                if dataOk then data = result end
            end
        end
        if data and data ~= "" then
            profile.layouts[classToken][#profile.layouts[classToken] + 1] = {
                name = l.name or ("Layout " .. l.id),
                spec = ns.SpecFromSpecTag(l.specTag),
                data = data,
                created = time(),
                modified = time(),
            }
            captured = captured + 1
        end
    end

    profile.modified = time()
    if ns.RefreshUI then ns.RefreshUI() end
    return true, captured .. " layout(s) captured for " .. classToken .. "."
end

---------------------------------------------------------------------------
-- Print all
---------------------------------------------------------------------------

function ns.PrintAll()
    local active = ns.GetActiveProfileName()
    ns.Print("=== Profiles ===")
    local profiles = ns.GetProfileList()
    if #profiles == 0 then
        print("  (none)")
    else
        for _, p in ipairs(profiles) do
            local m = p.name == active and " |cFF00FF00(active)|r" or ""
            print("  " .. p.name .. m)
        end
    end

    ns.Print("=== Blizzard Layouts (active profile) ===")
    local blizz = ns.GetBlizzardLayouts()
    if #blizz == 0 then
        print("  (none)")
    else
        for _, l in ipairs(blizz) do
            local m = l.isActive and " |cFF00FF00(active)|r" or ""
            print(string.format("  [%d] %s |cFF888888(%s)|r%s", l.id, l.name, l.specTag, m))
        end
    end

    ns.Print("=== Stored Layouts (unattached) ===")
    local stored = ns.GetStoredLayouts()
    if #stored == 0 then
        print("  (none)")
    else
        for i, s in ipairs(stored) do
            print(string.format("  #%d: %s |cFF888888(%s)|r", i, s.name, s.specTag ~= "" and s.specTag or "?"))
        end
    end
end

---------------------------------------------------------------------------
-- Viewer Refresh
---------------------------------------------------------------------------

function ns.RefreshViewers()
    C_Timer.After(0.1, function()
        if CooldownViewerSettings and CooldownViewerSettings.CheckSaveCurrentLayout then
            pcall(CooldownViewerSettings.CheckSaveCurrentLayout, CooldownViewerSettings)
        end
        for _, name in ipairs({
            "EssentialCooldownViewer", "UtilityCooldownViewer",
            "BuffIconCooldownViewer", "TrackedBarCooldownViewer",
        }) do
            local v = _G[name]
            if v then
                if v.RefreshData then pcall(v.RefreshData, v) end
                if v.RefreshLayout then pcall(v.RefreshLayout, v) end
            end
        end
    end)
end

---------------------------------------------------------------------------
-- StaticPopup Dialogs
---------------------------------------------------------------------------

StaticPopupDialogs["COOLDOWNMASTER_SAVE_PROFILE"] = {
    text = "CooldownMaster\nSave current state as profile:",
    button1 = "Save", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self)
        local active = ns.GetActiveProfileName()
        self.EditBox:SetText(active or "")
        self.EditBox:HighlightText()
        self.EditBox:SetFocus()
    end,
    OnAccept = function(self)
        local name = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if name == "" then return end
        local ok, err = ns.SaveProfile(name, true)
        ns.Print(ok and ("Saved: " .. name) or ("|cFFFF0000Error:|r " .. err))
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_SAVE_PROFILE"].OnAccept(p)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["COOLDOWNMASTER_NEW_PROFILE"] = {
    text = "CooldownMaster\nNew profile name:",
    button1 = "Create", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self) self.EditBox:SetText(""); self.EditBox:SetFocus() end,
    OnAccept = function(self)
        local name = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if name == "" then return end
        local ok, err = ns.SaveProfile(name, false)
        if ok then
            ns.Print("Created and activated: " .. name)
        elseif err then
            ns.Print("|cFFFF0000Error:|r " .. err)
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_NEW_PROFILE"].OnAccept(p)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["COOLDOWNMASTER_DELETE_PROFILE"] = {
    text = "CooldownMaster\nDelete profile '%s'?",
    button1 = "Delete", button2 = "Cancel",
    timeout = 0, whileDead = true, hideOnEscape = true, showAlert = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, err = ns.DeleteProfile(data.name)
        ns.Print(ok and "Deleted." or ("|cFFFF0000Error:|r " .. err))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_RENAME_PROFILE"] = {
    text = "CooldownMaster\nRename profile '%s':",
    button1 = "Rename", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self, data)
        self.EditBox:SetText(data and data.oldName or "")
        self.EditBox:HighlightText()
        self.EditBox:SetFocus()
    end,
    OnAccept = function(self, data)
        if not data then return end
        local newName = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if newName == "" then return end
        local ok, err = ns.RenameProfile(data.oldName, newName)
        ns.Print(ok and ("Renamed: " .. newName) or ("|cFFFF0000Error:|r " .. err))
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_RENAME_PROFILE"].OnAccept(p, p.data)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["COOLDOWNMASTER_STORE_CONFIRM"] = {
    text = "CooldownMaster\nStore '%s' to unattached and free a Blizzard slot?",
    button1 = "Store", button2 = "Cancel",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, err = ns.StoreBlizzardLayout(data.layoutID)
        ns.Print(ok and "Stored." or ("|cFFFF0000Error:|r " .. err))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_COPY_BLIZZARD"] = {
    text = "CooldownMaster\nCopy layout '%s' to storage?",
    button1 = "Copy", button2 = "Cancel",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, err = ns.CopyBlizzardLayout(data.layoutID)
        ns.Print(ok and "Copied to storage." or ("|cFFFF0000Error:|r " .. err))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_DELETE_BLIZZARD"] = {
    text = "CooldownMaster\nDelete Blizzard layout '%s'?\nThis cannot be undone.",
    button1 = "Delete", button2 = "Cancel",
    timeout = 0, whileDead = true, hideOnEscape = true, showAlert = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, err = ns.DeleteBlizzardLayout(data.layoutID)
        ns.Print(ok and "Deleted." or ("|cFFFF0000Error:|r " .. err))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_RENAME_BLIZZARD"] = {
    text = "CooldownMaster\nRename Blizzard layout '%s':",
    button1 = "Rename", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self, data)
        self.EditBox:SetText(data and data.oldName or "")
        self.EditBox:HighlightText(); self.EditBox:SetFocus()
    end,
    OnAccept = function(self, data)
        if not data then return end
        local n = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if n == "" then return end
        local ok, err = ns.RenameBlizzardLayout(data.layoutID, n)
        ns.Print(ok and ("Renamed: " .. n) or ("|cFFFF0000Error:|r " .. err))
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_RENAME_BLIZZARD"].OnAccept(p, p.data)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["COOLDOWNMASTER_DELETE_STORED"] = {
    text = "CooldownMaster\nDelete stored layout '%s'?",
    button1 = "Delete", button2 = "Cancel",
    timeout = 0, whileDead = true, hideOnEscape = true, showAlert = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, err = ns.DeleteStoredLayout(data.index)
        ns.Print(ok and "Deleted." or ("|cFFFF0000Error:|r " .. err))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_RENAME_STORED"] = {
    text = "CooldownMaster\nRename stored layout '%s':",
    button1 = "Rename", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self, data)
        self.EditBox:SetText(data and data.oldName or "")
        self.EditBox:HighlightText(); self.EditBox:SetFocus()
    end,
    OnAccept = function(self, data)
        if not data then return end
        local n = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if n == "" then return end
        local ok, err = ns.RenameStoredLayout(data.index, n)
        ns.Print(ok and ("Renamed: " .. n) or ("|cFFFF0000Error:|r " .. err))
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_RENAME_STORED"].OnAccept(p, p.data)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["COOLDOWNMASTER_IMPORT_CDM_NAME"] = {
    text = "CooldownMaster\nName for imported layout:",
    button1 = "Import", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self)
        self.EditBox:SetText("Imported")
        self.EditBox:HighlightText(); self.EditBox:SetFocus()
    end,
    OnAccept = function(self, data)
        if not data then return end
        local name = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if name == "" then name = "Imported" end
        local ok, err = ns.ImportCDMString(data.cdmString, name)
        ns.Print(ok and ("Imported: " .. name) or ("|cFFFF0000Error:|r " .. err))
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_IMPORT_CDM_NAME"].OnAccept(p, p.data)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

---------------------------------------------------------------------------
-- Global Profile StaticPopup Dialogs
---------------------------------------------------------------------------

StaticPopupDialogs["COOLDOWNMASTER_NEW_GLOBAL_PROFILE"] = {
    text = "CooldownMaster\nNew global profile name:",
    button1 = "Create", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self) self.EditBox:SetText(""); self.EditBox:SetFocus() end,
    OnAccept = function(self)
        local name = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if name == "" then return end
        local uuid, err = ns.CreateGlobalProfile(name)
        if uuid then
            ns.Print("Created global profile: " .. name)
        else
            ns.Print("|cFFFF0000Error:|r " .. (err or "unknown"))
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_NEW_GLOBAL_PROFILE"].OnAccept(p)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["COOLDOWNMASTER_DELETE_GLOBAL_PROFILE"] = {
    text = "CooldownMaster\nDelete global profile '%s'?\nThis will remove it for all characters.",
    button1 = "Delete", button2 = "Cancel",
    timeout = 0, whileDead = true, hideOnEscape = true, showAlert = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, err = ns.DeleteGlobalProfile(data.uuid)
        ns.Print(ok and "Deleted." or ("|cFFFF0000Error:|r " .. err))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_RENAME_GLOBAL_PROFILE"] = {
    text = "CooldownMaster\nRename global profile '%s':",
    button1 = "Rename", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self, data)
        self.EditBox:SetText(data and data.oldName or "")
        self.EditBox:HighlightText(); self.EditBox:SetFocus()
    end,
    OnAccept = function(self, data)
        if not data then return end
        local n = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if n == "" then return end
        local ok, err = ns.RenameGlobalProfile(data.uuid, n)
        ns.Print(ok and ("Renamed: " .. n) or ("|cFFFF0000Error:|r " .. err))
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_RENAME_GLOBAL_PROFILE"].OnAccept(p, p.data)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["COOLDOWNMASTER_DELETE_TEMPLATE"] = {
    text = "CooldownMaster\nDelete template '%s'?",
    button1 = "Delete", button2 = "Cancel",
    timeout = 0, whileDead = true, hideOnEscape = true, showAlert = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, err = ns.DeleteTemplate(data.uuid)
        ns.Print(ok and "Deleted." or ("|cFFFF0000Error:|r " .. err))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_RENAME_TEMPLATE"] = {
    text = "CooldownMaster\nRename template '%s':",
    button1 = "Rename", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self, data)
        self.EditBox:SetText(data and data.oldName or "")
        self.EditBox:HighlightText(); self.EditBox:SetFocus()
    end,
    OnAccept = function(self, data)
        if not data then return end
        local n = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if n == "" then return end
        local ok, err = ns.RenameTemplate(data.uuid, n)
        ns.Print(ok and ("Renamed: " .. n) or ("|cFFFF0000Error:|r " .. err))
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_RENAME_TEMPLATE"].OnAccept(p, p.data)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["COOLDOWNMASTER_REMOVE_FROM_PROFILE"] = {
    text = "CooldownMaster\nRemove layout '%s' from this profile?",
    button1 = "Remove", button2 = "Cancel",
    timeout = 0, whileDead = true, hideOnEscape = true, showAlert = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, err = ns.RemoveLayoutFromProfile(data.profileUUID, data.class, data.index)
        ns.Print(ok and "Removed." or ("|cFFFF0000Error:|r " .. err))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_RENAME_PROFILE_LAYOUT"] = {
    text = "CooldownMaster\nRename layout '%s':",
    button1 = "Rename", button2 = "Cancel",
    hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self, data)
        self.EditBox:SetText(data and data.oldName or "")
        self.EditBox:HighlightText(); self.EditBox:SetFocus()
    end,
    OnAccept = function(self, data)
        if not data then return end
        local n = (self.EditBox:GetText() or ""):match("^%s*(.-)%s*$")
        if n == "" then return end
        local ok, err = ns.RenameLayoutInProfile(data.profileUUID, data.class, data.index, n)
        ns.Print(ok and ("Renamed: " .. n) or ("|cFFFF0000Error:|r " .. err))
    end,
    EditBoxOnEnterPressed = function(self)
        local p = self:GetParent()
        StaticPopupDialogs["COOLDOWNMASTER_RENAME_PROFILE_LAYOUT"].OnAccept(p, p.data)
        p:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

---------------------------------------------------------------------------
-- Import Conflict Resolution Dialogs
---------------------------------------------------------------------------

StaticPopupDialogs["COOLDOWNMASTER_IMPORT_PROFILE_CONFLICT"] = {
    text = "CooldownMaster\nA profile named '%s' already exists.",
    button1 = "Create a Copy", button2 = "Cancel", button3 = "Overwrite",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, msg = ns.ApplyImportProfile(data.decoded, "copy")
        ns.Print(ok and ("|cFF00FF00" .. msg .. "|r") or ("|cFFFF0000Error:|r " .. msg))
    end,
    OnAlt = function(self, data)
        if not data then return end
        local ok, msg = ns.ApplyImportProfile(data.decoded, "overwrite", data.existingUUID)
        ns.Print(ok and ("|cFF00FF00" .. msg .. "|r") or ("|cFFFF0000Error:|r " .. msg))
    end,
}

StaticPopupDialogs["COOLDOWNMASTER_IMPORT_LAYERS_CONFLICT"] = {
    text = "CooldownMaster\nThese layers already exist:\n%s",
    button1 = "Create Copies", button2 = "Cancel", button3 = "Overwrite",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function(self, data)
        if not data then return end
        local ok, msg = ns.ApplyImportClassLayouts(data.decoded, data.profileUUID, "copy")
        ns.Print(ok and ("|cFF00FF00" .. msg .. "|r") or ("|cFFFF0000Error:|r " .. msg))
    end,
    OnAlt = function(self, data)
        if not data then return end
        local ok, msg = ns.ApplyImportClassLayouts(data.decoded, data.profileUUID, "overwrite")
        ns.Print(ok and ("|cFF00FF00" .. msg .. "|r") or ("|cFFFF0000Error:|r " .. msg))
    end,
}
