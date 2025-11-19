local addonName, _ = ...
local NV = NexusVault

local function safeCall(script)
    local ok, result = pcall(function()
        return NV:Omagad(script)
    end)

    if not ok then
        NV:Print("Omagad call failed: " .. tostring(result))
        return nil
    end

    return result
end

function NV.CastSpell(spellName)
    if not spellName then
        return
    end
    return safeCall(string.format("CastSpellByName('%s')", spellName))
end

function NV.DestroyItem(bag, slot)
    if bag == nil or slot == nil then
        return
    end
    return safeCall(string.format("PickupContainerItem(%d,%d); DeleteCursorItem()", bag, slot))
end

function NV.EquipItem(bag, slot)
    if bag == nil or slot == nil then
        return
    end
    return safeCall(string.format("UseContainerItem(%d,%d)", bag, slot))
end

function NV.SellItem(bag, slot)
    if not MerchantFrame or not MerchantFrame:IsShown() then
        return
    end
    return safeCall(string.format("UseContainerItem(%d,%d)", bag, slot))
end

function NV.TryLearnAppearance(bag, slot)
    if bag == nil or slot == nil then
        return
    end
    return safeCall(string.format("UseContainerItem(%d,%d)", bag, slot))
end

function NV.SafePickup(bag, slot)
    if bag == nil or slot == nil then
        return
    end
    return safeCall(string.format("PickupContainerItem(%d,%d)", bag, slot))
end

function NV.SafeEquipInventorySlot(slotId)
    if not slotId then
        return
    end
    return safeCall(string.format("EquipPendingItem(%d)", slotId))
end
