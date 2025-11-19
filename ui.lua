local NV = NexusVault

local frame
local toggles = {}
local dropdown
local sliderSellValue
local sliderDestroyValue

local function createCheckbox(parent, label, key, yOffset)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", 16, yOffset)
    if check.Text then
        check.Text:SetText(label)
    end

    check:SetScript("OnClick", function(self)
        NV:ToggleFeature(key, self:GetChecked())
    end)

    toggles[key] = check
    return check
end

local function updateToggleStates()
    for key, check in pairs(toggles) do
        check:SetChecked(NV:IsFeatureEnabled(key))
    end
end

local function onSpecSelected(self)
    UIDropDownMenu_SetSelectedValue(dropdown, self.value)
    NV:SetActiveSpec(self.value)
end

local function initDropdown()
    local active = NV:GetActiveSpec()
    UIDropDownMenu_SetWidth(dropdown, 160)
    UIDropDownMenu_SetSelectedValue(dropdown, active)
    UIDropDownMenu_SetText(dropdown, "Active Spec: " .. active)

    UIDropDownMenu_Initialize(dropdown, function(_, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = onSpecSelected
        for i = 1, 3 do
            info.text = "Specialization " .. i
            info.value = i
            info.checked = active == i
            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

local function createSlider(parent, label, minVal, maxVal, step, onValueChanged)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then
        slider:SetObeyStepOnDrag(true)
    end
    slider:SetWidth(200)
    slider:SetScript("OnValueChanged", function(self, value)
        self.Text:SetText(label .. ": " .. value)
        onValueChanged(value)
    end)
    slider.Low:SetText(minVal)
    slider.High:SetText(maxVal)
    slider.Text:SetText(label)
    return slider
end

function NV:ToggleUI()
    if not frame then
        frame = CreateFrame("Frame", "NexusVaultConfig", UIParent)
        frame:SetSize(360, 320)
        frame:SetPoint("CENTER")

        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })

        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        frame.title:SetPoint("TOP", 0, -12)
        frame.title:SetText("Nexus Vault")

        toggles.autoSell = createCheckbox(frame, "Enable Auto-Sell", "autoSell", -40)
        toggles.autoDestroy = createCheckbox(frame, "Enable Auto-Destruction", "autoDestroy", -70)
        toggles.autoEquip = createCheckbox(frame, "Enable Auto-Equip", "autoEquip", -100)
        toggles.transmog = createCheckbox(frame, "Enable Transmog Automation", "transmog", -130)

        dropdown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", 10, -170)
        initDropdown()

        sliderSellValue = createSlider(frame, "Sell Min Value", 0, 100000, 100, function(value)
            NV:GetConfig().rules.sellValue = value
        end)
        sliderSellValue:SetPoint("TOPLEFT", 20, -210)
        sliderSellValue:SetValue(NV:GetConfig().rules.sellValue)

        sliderDestroyValue = createSlider(frame, "Destroy Max Value", 0, 100000, 100, function(value)
            NV:GetConfig().rules.destroyValue = value
        end)
        sliderDestroyValue:SetPoint("TOPLEFT", 20, -250)
        sliderDestroyValue:SetValue(NV:GetConfig().rules.destroyValue)

        local startTransmog = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        startTransmog:SetPoint("BOTTOMLEFT", 16, 16)
        startTransmog:SetSize(140, 22)
        startTransmog:SetText("Start Transmog Run")
        startTransmog:SetScript("OnClick", function()
            NV:StartTransmogLearning()
        end)

        local stopTransmog = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        stopTransmog:SetPoint("BOTTOMLEFT", 180, 16)
        stopTransmog:SetSize(140, 22)
        stopTransmog:SetText("Stop Transmog Run")
        stopTransmog:SetScript("OnClick", function()
            NV:StopTransmogLearning()
        end)
    end

    if frame:IsShown() then
        frame:Hide()
    else
        updateToggleStates()
        initDropdown()
        frame:Show()
    end
end

