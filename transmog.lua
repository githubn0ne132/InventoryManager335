local NV = NexusVault

local isLearning = false
local progress = {
    total = 0,
    processed = 0,
}

local function canLearn(link)
    if not link then
        return false
    end

    local _, _, quality, _, _, class, subclass, _, equipSlot = GetItemInfo(link)
    if not equipSlot or not quality then
        return false
    end

    local usable = IsUsableItem(link)
    if not usable then
        return false
    end

    return class == "Armor" or class == "Weapon"
end

local function iterateCandidates()
    local list = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link and canLearn(link) then
                local isCollected = select(13, GetItemInfo(link)) -- placeholder for appearance flag
                if not isCollected then
                    list[#list + 1] = { bag = bag, slot = slot, link = link }
                end
            end
        end
    end
    return list
end

local previousGear = {}
local function snapshotGear()
    wipe(previousGear)
    for slot = 1, 19 do
        previousGear[slot] = GetInventoryItemLink("player", slot)
    end
end

local function restoreGear()
    for slot, link in pairs(previousGear) do
        if link then
            NV.SafeEquipInventorySlot(slot)
        end
    end
    NV:RunGearEvaluation()
end

local function learnNext(candidates)
    if #candidates == 0 then
        NV:Print("Transmog learning complete")
        restoreGear()
        isLearning = false
        return
    end

    local entry = table.remove(candidates)
    progress.processed = progress.processed + 1
    NV:Print(string.format("Learning appearance: %s (%d/%d)", entry.link or "item", progress.processed, progress.total))
    NV.TryLearnAppearance(entry.bag, entry.slot)
    C_Timer.After(0.1, function()
        learnNext(candidates)
    end)
end

function NV:StartTransmogLearning()
    if isLearning then
        NV:Print("Already learning appearances")
        return
    end

    local candidates = iterateCandidates()
    progress.total = #candidates
    progress.processed = 0

    if progress.total == 0 then
        NV:Print("No new appearances found")
        return
    end

    isLearning = true
    snapshotGear()
    learnNext(candidates)
end

function NV:StopTransmogLearning()
    isLearning = false
    NV:Print("Transmog learning stopped")
end

function NV:SetupTransmog()
    NV:RegisterToggleHandler(function(key, enabled)
        if key == "transmog" and not enabled and isLearning then
            NV:StopTransmogLearning()
        end
    end)
end

