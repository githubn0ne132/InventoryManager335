local NV = NexusVault

local inventorySlots = {
    INVSLOT_HEAD,
    INVSLOT_NECK,
    INVSLOT_SHOULDER,
    INVSLOT_CHEST,
    INVSLOT_WAIST,
    INVSLOT_LEGS,
    INVSLOT_FEET,
    INVSLOT_WRIST,
    INVSLOT_HAND,
    INVSLOT_FINGER1,
    INVSLOT_FINGER2,
    INVSLOT_TRINKET1,
    INVSLOT_TRINKET2,
    INVSLOT_BACK,
    INVSLOT_MAINHAND,
    INVSLOT_OFFHAND,
    INVSLOT_RANGED,
}

local function getItemScore(link, weights)
    if not link or not weights then
        return 0
    end

    local stats = GetItemStats(link)
    if not stats then
        return 0
    end

    local score = 0
    for stat, value in pairs(stats) do
        local weight = weights[stat]
        if weight then
            score = score + (value * weight)
        end
    end
    return score
end

local function scanEquipped(weights)
    local equipped = {}
    for _, slotId in ipairs(inventorySlots) do
        local itemLink = GetInventoryItemLink("player", slotId)
        equipped[slotId] = {
            link = itemLink,
            score = getItemScore(itemLink, weights),
        }
    end
    return equipped
end

local function compareBagItems(weights, equipped)
    local upgrades = {}

    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local _, _, quality, _, _, _, _, _, equipSlot = GetItemInfo(link)
                if equipSlot and quality and quality > 1 then
                    local score = getItemScore(link, weights)
                    for _, slotId in ipairs(inventorySlots) do
                        local current = equipped[slotId]
                        if current and score > (current.score or 0) then
                            upgrades[#upgrades + 1] = {
                                bag = bag,
                                slot = slot,
                                score = score,
                                slotId = slotId,
                                link = link,
                                currentScore = current.score or 0,
                            }
                        end
                    end
                end
            end
        end
    end

    table.sort(upgrades, function(a, b)
        return (a.score - a.currentScore) > (b.score - b.currentScore)
    end)

    return upgrades
end

local function equipUpgrade(upgrade)
    if not upgrade then
        return
    end

    NV:Print(string.format("Equipping %s (%.2f > %.2f)", upgrade.link or "item", upgrade.score, upgrade.currentScore or 0))
    NV.EquipItem(upgrade.bag, upgrade.slot)
end

function NV:RunGearEvaluation()
    if not NV:IsFeatureEnabled("autoEquip") then
        return
    end

    local weights = NV:GetWeightsForSpec(NV:GetActiveSpec())
    local equipped = scanEquipped(weights)
    local upgrades = compareBagItems(weights, equipped)

    for _, upgrade in ipairs(upgrades) do
        equipUpgrade(upgrade)
    end
end

function NV:SetupGearEvaluator()
    NV:RegisterInventoryHandler(function(event)
        if event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE" then
            NV:RunGearEvaluation()
        end
    end)

    NV:RegisterSpecHandler(function()
        NV:RunGearEvaluation()
    end)

    NV:RegisterLoginHandler(function()
        NV:RunGearEvaluation()
    end)
end

