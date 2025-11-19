local addonName, _ = ...

local NexusVault = {
    version = "0.1.0",
    defaults = {
        activeSpec = 1,
        toggles = {
            autoSell = true,
            autoDestroy = false,
            transmog = false,
            autoEquip = true,
        },
        rules = {
            destroyQuality = 2, -- uncommon
            destroyValue = 0,
            sellQuality = 1, -- common
            sellValue = 0,
        },
        weights = {},
    },
    handlers = {
        inventory = {},
        merchant = {},
        toggle = {},
        spec = {},
        login = {},
    },
}

_G.NexusVault = NexusVault

local eventFrame = CreateFrame("Frame")

local function CloneDefaults()
    local copy = {}
    for key, value in pairs(NexusVault.defaults) do
        if type(value) == "table" then
            local inner = {}
            for k, v in pairs(value) do
                inner[k] = v
            end
            copy[key] = inner
        else
            copy[key] = value
        end
    end
    return copy
end

function NexusVault:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99NexusVault|r: " .. tostring(msg))
end

function NexusVault:Omagad(script)
    if type(self.customOmagad) == "function" then
        return self:customOmagad(script)
    end

    if Omagad and type(Omagad) == "function" then
        return Omagad(script)
    end

    -- fallback to RunScript for non-production environments
    return RunScript(script)
end

function NexusVault:LoadDefaults()
    for key, value in pairs(NexusVault.defaults) do
        if NexusVaultDB[key] == nil then
            if type(value) == "table" then
                NexusVaultDB[key] = CloneDefaults()[key]
            else
                NexusVaultDB[key] = value
            end
        end
    end
end

local function OnAddonLoaded(_, event, name)
    if name ~= addonName then
        return
    end

    NexusVaultDB = NexusVaultDB or {}
    NexusVault:LoadDefaults()

    NexusVault:RegisterSlash()
    NexusVault:RegisterMinimapButton()
    NexusVault:RegisterModules()
    NexusVault:Print("Loaded v" .. NexusVault.version)
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(self, event, ...)
    elseif event == "PLAYER_LOGIN" then
        if NexusVault.OnPlayerLogin then
            NexusVault:OnPlayerLogin()
        end
        for _, handler in ipairs(NexusVault.handlers.login) do
            handler()
        end
    elseif event == "BAG_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" then
        for _, handler in ipairs(NexusVault.handlers.inventory) do
            handler(event, ...)
        end
    elseif event == "MERCHANT_SHOW" then
        for _, handler in ipairs(NexusVault.handlers.merchant) do
            handler()
        end
    end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("MERCHANT_SHOW")

function NexusVault:RegisterModules()
    if NexusVault.SetupWeights then
        NexusVault:SetupWeights()
    end

    if NexusVault.SetupGearEvaluator then
        NexusVault:SetupGearEvaluator()
    end

    if NexusVault.SetupTransmog then
        NexusVault:SetupTransmog()
    end

    if NexusVault.SetupVendor then
        NexusVault:SetupVendor()
    end
end

function NexusVault:RegisterInventoryHandler(handler)
    table.insert(self.handlers.inventory, handler)
end

function NexusVault:RegisterMerchantHandler(handler)
    table.insert(self.handlers.merchant, handler)
end

function NexusVault:RegisterToggleHandler(handler)
    table.insert(self.handlers.toggle, handler)
end

function NexusVault:RegisterSpecHandler(handler)
    table.insert(self.handlers.spec, handler)
end

function NexusVault:RegisterLoginHandler(handler)
    table.insert(self.handlers.login, handler)
end

function NexusVault:RegisterSlash()
    SLASH_NEXUSVAULT1 = "/nv"
    SlashCmdList["NEXUSVAULT"] = function(msg)
        if NexusVault.ToggleUI then
            NexusVault:ToggleUI(msg)
        end
    end
end

function NexusVault:RegisterMinimapButton()
    local button = CreateFrame("Button", "NexusVaultMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)

    button:SetNormalTexture("Interface\\AddOns\\" .. addonName .. "\\Media\\Minimap")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetSize(54, 54)
    overlay:SetPoint("TOPLEFT", -10, 8)

    button:SetScript("OnClick", function()
        if NexusVault.ToggleUI then
            NexusVault:ToggleUI()
        end
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Nexus Vault")
        GameTooltip:AddLine("Click to open control panel", 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
    NexusVault.minimapButton = button
end

function NexusVault:ToggleFeature(key, enabled)
    if NexusVaultDB.toggles[key] ~= enabled then
        NexusVaultDB.toggles[key] = enabled
        NexusVault:Print(key .. " " .. (enabled and "enabled" or "disabled"))
    end

    if NexusVault.OnToggleChanged then
        NexusVault:OnToggleChanged(key, enabled)
    end

    for _, handler in ipairs(NexusVault.handlers.toggle) do
        handler(key, enabled)
    end
end

function NexusVault:IsFeatureEnabled(key)
    return NexusVaultDB.toggles[key]
end

function NexusVault:SetActiveSpec(specIndex)
    NexusVaultDB.activeSpec = specIndex
    if NexusVault.OnSpecChanged then
        NexusVault:OnSpecChanged(specIndex)
    end
    for _, handler in ipairs(NexusVault.handlers.spec) do
        handler(specIndex)
    end
end

function NexusVault:GetActiveSpec()
    return NexusVaultDB.activeSpec or 1
end

function NexusVault:GetWeightsForSpec(specIndex)
    if NexusVault.GetWeights then
        return NexusVault:GetWeights(specIndex or NexusVault:GetActiveSpec())
    end
    return {}
end

function NexusVault:GetConfig()
    return NexusVaultDB
end

