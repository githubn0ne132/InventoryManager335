local NV = NexusVault

local defaultWeights = {
    [1] = { -- spec 1
        ITEM_MOD_STRENGTH_SHORT = 1.0,
        ITEM_MOD_AGILITY_SHORT = 0.5,
        ITEM_MOD_STAMINA_SHORT = 0.4,
        ITEM_MOD_INTELLECT_SHORT = 0.2,
        ITEM_MOD_SPIRIT_SHORT = 0,
        ITEM_MOD_HASTE_RATING_SHORT = 0.6,
        ITEM_MOD_CRIT_RATING_SHORT = 0.7,
    },
    [2] = { -- spec 2
        ITEM_MOD_STRENGTH_SHORT = 0.3,
        ITEM_MOD_AGILITY_SHORT = 0.8,
        ITEM_MOD_STAMINA_SHORT = 0.4,
        ITEM_MOD_INTELLECT_SHORT = 0.4,
        ITEM_MOD_SPIRIT_SHORT = 0,
        ITEM_MOD_HASTE_RATING_SHORT = 0.5,
        ITEM_MOD_CRIT_RATING_SHORT = 0.9,
    },
    [3] = { -- spec 3
        ITEM_MOD_STRENGTH_SHORT = 0.2,
        ITEM_MOD_AGILITY_SHORT = 0.3,
        ITEM_MOD_STAMINA_SHORT = 0.5,
        ITEM_MOD_INTELLECT_SHORT = 1.0,
        ITEM_MOD_SPIRIT_SHORT = 0.5,
        ITEM_MOD_HASTE_RATING_SHORT = 0.8,
        ITEM_MOD_CRIT_RATING_SHORT = 0.6,
    },
}

function NV:SetupWeights()
    NexusVaultDB.weights = NexusVaultDB.weights or {}
    for specIndex, defaults in pairs(defaultWeights) do
        NexusVaultDB.weights[specIndex] = NexusVaultDB.weights[specIndex] or {}
        for stat, weight in pairs(defaults) do
            if NexusVaultDB.weights[specIndex][stat] == nil then
                NexusVaultDB.weights[specIndex][stat] = weight
            end
        end
    end
end

function NV:GetWeights(specIndex)
    return NexusVaultDB.weights[specIndex] or defaultWeights[specIndex] or {}
end

function NV:SetWeight(specIndex, stat, value)
    NexusVaultDB.weights[specIndex] = NexusVaultDB.weights[specIndex] or {}
    NexusVaultDB.weights[specIndex][stat] = value
end

