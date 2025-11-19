local NV = NexusVault

local qualityMap = {
    poor = 0,
    common = 1,
    uncommon = 2,
    rare = 3,
    epic = 4,
    legendary = 5,
}

local function shouldSell(quality, value)
    local rules = NV:GetConfig().rules
    return NV:IsFeatureEnabled("autoSell") and quality <= rules.sellQuality and value >= rules.sellValue
end

local function shouldDestroy(quality, value)
    local rules = NV:GetConfig().rules
    return NV:IsFeatureEnabled("autoDestroy") and quality <= rules.destroyQuality and value <= rules.destroyValue
end

local function iterateItems(predicate, action)
    local sold = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local _, _, quality, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(link)
                if predicate(quality or 0, vendorPrice or 0) then
                    action(bag, slot, link)
                    sold[#sold + 1] = link
                end
            end
        end
    end
    return sold
end

local function logSummary(actionName, items)
    if #items == 0 then
        return
    end

    NV:Print(actionName .. ": " .. table.concat(items, ", "))
end

function NV:HandleVendor()
    local sold = iterateItems(shouldSell, function(bag, slot)
        NV.SellItem(bag, slot)
    end)
    logSummary("Sold", sold)
end

function NV:HandleDestruction()
    local destroyed = iterateItems(shouldDestroy, function(bag, slot)
        NV.DestroyItem(bag, slot)
    end)
    logSummary("Destroyed", destroyed)
end

function NV:SetupVendor()
    NV:RegisterMerchantHandler(function()
        NV:HandleVendor()
    end)

    NV:RegisterInventoryHandler(function(event)
        if event == "BAG_UPDATE" and NV:IsFeatureEnabled("autoDestroy") then
            NV:HandleDestruction()
        end
    end)
end

