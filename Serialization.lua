local _, ns = ...

local LibDeflate = ns.LibDeflate

-- Export prefixes
local PREFIX_PROFILE    = "CM2P:"  -- full global profile (all classes)
local PREFIX_CLASS      = "CM2C:"  -- layouts for one class from a profile
local PREFIX_LAYOUT     = "CM2L:"  -- single layout
local PREFIX_TEMPLATE   = "CM2T:"  -- single template

---------------------------------------------------------------------------
-- Minimal Table Serializer
---------------------------------------------------------------------------

local function serializeValue(val, depth)
    depth = depth or 0
    if depth > 20 then return "nil" end

    local t = type(val)
    if t == "string" then
        return string.format("%q", val)
    elseif t == "number" then
        if val ~= val then return "0" end
        if val == math.huge then return "math.huge" end
        if val == -math.huge then return "-math.huge" end
        return tostring(val)
    elseif t == "boolean" then
        return val and "true" or "false"
    elseif t == "table" then
        local parts = {}
        local arrayLen = #val
        for i = 1, arrayLen do
            parts[#parts + 1] = serializeValue(val[i], depth + 1)
        end
        for k, v in pairs(val) do
            local skip = false
            if type(k) == "number" and k >= 1 and k <= arrayLen and k == math.floor(k) then
                skip = true
            end
            if not skip then
                local key
                if type(k) == "number" then
                    key = "[" .. tostring(k) .. "]"
                elseif type(k) == "string" then
                    if k:match("^[%a_][%w_]*$") then
                        key = k
                    else
                        key = "[" .. string.format("%q", k) .. "]"
                    end
                end
                if key then
                    parts[#parts + 1] = key .. "=" .. serializeValue(v, depth + 1)
                end
            end
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "nil"
end

local function deserializeValue(str)
    if not str or str == "" then return nil end
    local func, err = loadstring("return " .. str)
    if not func then return nil end
    setfenv(func, {})
    local ok, result = pcall(func)
    if ok then return result end
    return nil
end

function ns.Serialize(tbl)
    return serializeValue(tbl, 0)
end

function ns.Deserialize(str)
    return deserializeValue(str)
end

---------------------------------------------------------------------------
-- Encode / Decode Pipeline
---------------------------------------------------------------------------

function ns.Encode(tbl)
    local serialized = ns.Serialize(tbl)
    if not serialized then return nil end
    local compressed = LibDeflate:CompressDeflate(serialized)
    if not compressed then return nil end
    local encoded = LibDeflate:EncodeForPrint(compressed)
    return encoded
end

function ns.Decode(str)
    if not str or str == "" then return nil end
    local decoded = LibDeflate:DecodeForPrint(str)
    if not decoded then return nil end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return nil end
    return ns.Deserialize(decompressed)
end

---------------------------------------------------------------------------
-- Export: Global Profile (all classes)
---------------------------------------------------------------------------

function ns.ExportGlobalProfile(uuid)
    local profile = ns.db.globalProfiles[uuid]
    if not profile then return nil, "Profile not found." end

    local layoutCount = 0
    local layoutsOut = {}
    for classToken, classLayouts in pairs(profile.layouts) do
        layoutsOut[classToken] = {}
        for i, entry in ipairs(classLayouts) do
            layoutsOut[classToken][i] = {
                name = entry.name,
                spec = entry.spec,
                data = entry.data,
            }
            layoutCount = layoutCount + 1
        end
    end

    if layoutCount == 0 then return nil, "Profile has no layouts." end

    local payload = {
        v = 2,
        scope = "globalProfile",
        name = profile.name,
        description = profile.description,
        layouts = layoutsOut,
    }

    local encoded = ns.Encode(payload)
    if not encoded then return nil, "Failed to encode." end
    return PREFIX_PROFILE .. encoded
end

---------------------------------------------------------------------------
-- Export: Layouts for one class from a profile
---------------------------------------------------------------------------

function ns.ExportProfileClass(uuid, classToken)
    local profile = ns.db.globalProfiles[uuid]
    if not profile then return nil, "Profile not found." end
    local classLayouts = profile.layouts[classToken]
    if not classLayouts or #classLayouts == 0 then
        return nil, "No layouts for " .. classToken .. "."
    end

    local layoutsOut = {}
    for i, entry in ipairs(classLayouts) do
        layoutsOut[i] = {
            name = entry.name,
            spec = entry.spec,
            data = entry.data,
        }
    end

    local payload = {
        v = 2,
        scope = "classLayouts",
        class = classToken,
        profileName = profile.name,
        layouts = layoutsOut,
    }

    local encoded = ns.Encode(payload)
    if not encoded then return nil, "Failed to encode." end
    return PREFIX_CLASS .. encoded
end

---------------------------------------------------------------------------
-- Export: Single layout
---------------------------------------------------------------------------

function ns.ExportSingleLayout(data, name, class, spec)
    if not data or data == "" then return nil, "No data." end

    local payload = {
        v = 2,
        scope = "singleLayout",
        name = name or "Layout",
        class = class or "UNKNOWN",
        spec = spec,
        data = data,
    }

    local encoded = ns.Encode(payload)
    if not encoded then return nil, "Failed to encode." end
    return PREFIX_LAYOUT .. encoded
end

---------------------------------------------------------------------------
-- Export: Single template
---------------------------------------------------------------------------

function ns.ExportTemplate(uuid)
    local tmpl = ns.db.templateLibrary[uuid]
    if not tmpl then return nil, "Template not found." end

    local payload = {
        v = 2,
        scope = "template",
        name = tmpl.name,
        class = tmpl.class,
        spec = tmpl.spec,
        data = tmpl.data,
    }

    local encoded = ns.Encode(payload)
    if not encoded then return nil, "Failed to encode." end
    return PREFIX_TEMPLATE .. encoded
end

---------------------------------------------------------------------------
-- Import: Auto-detect format
---------------------------------------------------------------------------

function ns.ImportString(str)
    if not str then return nil, nil, "No string provided." end
    str = str:match("^%s*(.-)%s*$")
    if str == "" then return nil, nil, "Empty string." end

    -- Raw CDM string (starts with version|data)
    if str:match("^%d+|") then
        return { scope = "cdm", data = str }, "cdm", nil
    end

    -- Prefixed formats (5-char prefix)
    if str:sub(1, 5) == PREFIX_PROFILE then
        local decoded = ns.Decode(str:sub(6))
        if not decoded then return nil, nil, "Failed to decode global profile export." end
        return decoded, "globalProfile", nil
    end

    if str:sub(1, 5) == PREFIX_CLASS then
        local decoded = ns.Decode(str:sub(6))
        if not decoded then return nil, nil, "Failed to decode class export." end
        return decoded, "classLayouts", nil
    end

    if str:sub(1, 5) == PREFIX_LAYOUT then
        local decoded = ns.Decode(str:sub(6))
        if not decoded then return nil, nil, "Failed to decode layout export." end
        return decoded, "singleLayout", nil
    end

    if str:sub(1, 5) == PREFIX_TEMPLATE then
        local decoded = ns.Decode(str:sub(6))
        if not decoded then return nil, nil, "Failed to decode template export." end
        return decoded, "template", nil
    end

    return nil, nil, "Unrecognized format. Paste a CDM string (1|...) or CooldownMaster export."
end

--- Apply imported data
function ns.ApplyImport(decoded, scope)
    if not decoded then return false, "No data." end

    if scope == "globalProfile" then
        -- Import as a new global profile with all class layouts
        local name = decoded.name or "Imported Profile"
        local uuid, err = ns.CreateGlobalProfile(name, decoded.description)
        if not uuid then return false, err end

        local profile = ns.db.globalProfiles[uuid]
        local totalLayouts = 0

        if decoded.layouts then
            for classToken, classLayouts in pairs(decoded.layouts) do
                profile.layouts[classToken] = {}
                for _, entry in ipairs(classLayouts) do
                    if entry.data and entry.data ~= "" then
                        profile.layouts[classToken][#profile.layouts[classToken] + 1] = {
                            name = entry.name or "Layout",
                            spec = entry.spec,
                            data = entry.data,
                            created = time(),
                            modified = time(),
                        }
                        totalLayouts = totalLayouts + 1
                    end
                end
            end
        end

        if ns.RefreshUI then ns.RefreshUI() end
        return true, "Imported profile '" .. name .. "' with " .. totalLayouts .. " layout(s)."

    elseif scope == "classLayouts" then
        -- Import class layouts into the active global profile (or create one)
        local classToken = decoded.class
        if not classToken then return false, "No class specified." end

        local activeUUID = ns.GetActiveGlobalProfileUUID and ns.GetActiveGlobalProfileUUID()
        if not activeUUID then
            -- Create a new profile to hold the import
            local uuid, err = ns.CreateGlobalProfile(decoded.profileName or "Imported")
            if not uuid then return false, err end
            activeUUID = uuid
        end

        local profile = ns.db.globalProfiles[activeUUID]
        if not profile then return false, "Profile not found." end

        if not profile.layouts[classToken] then profile.layouts[classToken] = {} end
        local imported = 0

        for _, entry in ipairs(decoded.layouts or {}) do
            if entry.data and entry.data ~= "" then
                profile.layouts[classToken][#profile.layouts[classToken] + 1] = {
                    name = entry.name or "Layout",
                    spec = entry.spec,
                    data = entry.data,
                    created = time(),
                    modified = time(),
                }
                imported = imported + 1
            end
        end

        profile.modified = time()
        if ns.RefreshUI then ns.RefreshUI() end
        return true, "Imported " .. imported .. " layout(s) for " .. classToken .. " into profile '" .. profile.name .. "'."

    elseif scope == "singleLayout" or scope == "template" then
        -- Import as a template into the library
        local name = decoded.name or "Imported"
        local class = decoded.class or "UNKNOWN"
        local uuid, err = ns.AddTemplate(name, class, decoded.spec, decoded.data)
        if not uuid then return false, err end
        return true, "Imported template: " .. name .. " (" .. class .. ")"
    end

    return false, "Unknown scope."
end

---------------------------------------------------------------------------
-- Import Conflict Helpers
---------------------------------------------------------------------------

--- Find a global profile by name, return its UUID or nil
function ns.FindGlobalProfileByName(name)
    if not name then return nil end
    for uuid, profile in pairs(ns.db.globalProfiles) do
        if profile.name == name then return uuid end
    end
    return nil
end

--- Find layer names that conflict between imported layouts and existing profile layouts
--- Returns a list of conflicting name strings
function ns.FindConflictingLayerNames(profileUUID, classToken, importedLayouts)
    local conflicts = {}
    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return conflicts end

    local existing = profile.layouts[classToken]
    if not existing or #existing == 0 then return conflicts end

    local existingNames = {}
    for _, entry in ipairs(existing) do
        existingNames[entry.name] = true
    end

    local seen = {}
    for _, entry in ipairs(importedLayouts or {}) do
        local name = entry.name or "Layout"
        if existingNames[name] and not seen[name] then
            conflicts[#conflicts + 1] = name
            seen[name] = true
        end
    end

    return conflicts
end

--- Copy decoded layouts into a profile table (shared helper)
local function copyLayoutsIntoProfile(profile, decodedLayouts)
    local totalLayouts = 0
    if decodedLayouts then
        for classToken, classLayouts in pairs(decodedLayouts) do
            profile.layouts[classToken] = {}
            for _, entry in ipairs(classLayouts) do
                if entry.data and entry.data ~= "" then
                    profile.layouts[classToken][#profile.layouts[classToken] + 1] = {
                        name = entry.name or "Layout",
                        spec = entry.spec,
                        data = entry.data,
                        created = time(),
                        modified = time(),
                    }
                    totalLayouts = totalLayouts + 1
                end
            end
        end
    end
    return totalLayouts
end

--- Import a global profile with conflict resolution mode
--- mode: "copy" = create with " (Copy)" suffix, "overwrite" = replace existing
function ns.ApplyImportProfile(decoded, mode, existingUUID)
    if not decoded then return false, "No data." end

    if mode == "copy" then
        local name = (decoded.name or "Imported Profile") .. " (Copy)"
        local uuid, err = ns.CreateGlobalProfile(name, decoded.description)
        if not uuid then return false, err end

        local profile = ns.db.globalProfiles[uuid]
        local totalLayouts = copyLayoutsIntoProfile(profile, decoded.layouts)

        if ns.RefreshUI then ns.RefreshUI() end
        return true, "Imported profile '" .. name .. "' with " .. totalLayouts .. " layout(s)."

    elseif mode == "overwrite" then
        if not existingUUID then return false, "No existing profile to overwrite." end
        local profile = ns.db.globalProfiles[existingUUID]
        if not profile then return false, "Profile not found." end

        profile.layouts = {}
        if decoded.description and decoded.description ~= "" then
            profile.description = decoded.description
        end

        local totalLayouts = copyLayoutsIntoProfile(profile, decoded.layouts)
        profile.modified = time()

        if ns.RefreshUI then ns.RefreshUI() end
        return true, "Overwritten profile '" .. profile.name .. "' with " .. totalLayouts .. " layout(s)."
    end

    return false, "Invalid mode."
end

--- Import class layouts with conflict resolution mode
--- mode: "copy" = append " (Copy)" to conflicting names, "overwrite" = replace matching layouts
function ns.ApplyImportClassLayouts(decoded, profileUUID, mode)
    if not decoded then return false, "No data." end
    local classToken = decoded.class
    if not classToken then return false, "No class specified." end

    local profile = ns.db.globalProfiles[profileUUID]
    if not profile then return false, "Profile not found." end

    if not profile.layouts[classToken] then profile.layouts[classToken] = {} end
    local existing = profile.layouts[classToken]

    if mode == "copy" then
        local existingNames = {}
        for _, entry in ipairs(existing) do
            existingNames[entry.name] = true
        end

        local imported = 0
        for _, entry in ipairs(decoded.layouts or {}) do
            if entry.data and entry.data ~= "" then
                local name = entry.name or "Layout"
                if existingNames[name] then
                    name = name .. " (Copy)"
                end
                existing[#existing + 1] = {
                    name = name,
                    spec = entry.spec,
                    data = entry.data,
                    created = time(),
                    modified = time(),
                }
                imported = imported + 1
            end
        end

        profile.modified = time()
        if ns.RefreshUI then ns.RefreshUI() end
        return true, "Imported " .. imported .. " layout(s) for " .. classToken .. " (copies created for conflicts)."

    elseif mode == "overwrite" then
        -- Build index of existing layouts by name for fast lookup
        local nameIndex = {}
        for i, entry in ipairs(existing) do
            nameIndex[entry.name] = i
        end

        local imported, overwritten = 0, 0
        for _, entry in ipairs(decoded.layouts or {}) do
            if entry.data and entry.data ~= "" then
                local name = entry.name or "Layout"
                local idx = nameIndex[name]
                if idx then
                    -- Overwrite existing layout
                    existing[idx].data = entry.data
                    existing[idx].spec = entry.spec
                    existing[idx].modified = time()
                    overwritten = overwritten + 1
                else
                    -- Add as new
                    existing[#existing + 1] = {
                        name = name,
                        spec = entry.spec,
                        data = entry.data,
                        created = time(),
                        modified = time(),
                    }
                end
                imported = imported + 1
            end
        end

        profile.modified = time()
        if ns.RefreshUI then ns.RefreshUI() end
        return true, "Imported " .. imported .. " layout(s) for " .. classToken .. " (" .. overwritten .. " overwritten)."
    end

    return false, "Invalid mode."
end
