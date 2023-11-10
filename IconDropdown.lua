_, Core = ...
Core.IconDropdown = {}
local IconDropdownNamespace = Core.IconDropdown
local AceEvent = LibStub("AceEvent-3.0")

IconDropdownMixin = {}
IconButtonMixin = {}

local function CallbackResize(self)
    self:HandleResize()
end

local function CallbackMainIconClick(self)
    self:GetParent():ToggleDropdownVisibility()
end

local function CallbackButtonClick(self)
    local dropdown = self:GetParent()
    dropdown:SetActiveOption(self.iconName)
    if dropdown.buttonClickCb then
        dropdown:buttonClickCb(self)
    end
end

function IconDropdownNamespace:Create(name, parent, width, height, buttonClickCb)
    local dropdown = CreateFrame("Frame", name, parent)
    dropdown.childButtons = {}
    dropdown.isShowingOptions = false
    dropdown.activeOption = nil
    dropdown.buttonClickCb = buttonClickCb

    Mixin(dropdown, IconDropdownMixin)
    dropdown:SetScript("OnSizeChanged", CallbackResize)
    dropdown:SetSize(width,height)

    local mainIcon = CreateFrame("Button", nil, dropdown, "UIPanelButtonTemplate")
    mainIcon:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 0, 0)
    mainIcon:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMRIGHT", 0, 0)
    mainIcon:SetNormalTexture("Interface\\Addons\\ThatsMyBuff\\art\\ClassIcon_Druid.blp")
    dropdown.mainIcon = mainIcon
    mainIcon:SetScript("OnClick", CallbackMainIconClick)

    --TODO: Fix this
    -- local dropdownButtonIcon = mainIcon:CreateTexture()
    -- dropdownButtonIcon:SetTexture("BlizzardInterfaceArt\\Interface\\BUTTONS\\Arrow-Down-Down.blp")
    -- dropdownButtonIcon:SetPoint("TOPLEFT", mainIcon, "TOPRIGHT")
    -- dropdownButtonIcon:SetPoint("BOTTOMLEFT", mainIcon, "TOPRIGHT", -10,-10)
    -- dropdown.dropdownButtonIcon = dropdownButtonIcon
    return dropdown
end

function IconDropdownMixin:test()
    print(self, "test")
end

function IconDropdownMixin:HandleResize()
    local mainIconWidget = self.mainIcon
    local childButtons = self.childButtons
    mainIconWidget:SetSize(self:GetSize())
    local lastButton = mainIconWidget
    for i = 1,#childButtons do
        local buttonWidget = childButtons[i]
        buttonWidget:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0)
        buttonWidget:SetPoint("BOTTOMRIGHT", lastButton, "BOTTOMRIGHT", 0, -self:GetHeight())
        lastButton = buttonWidget
    end
    local dropdownButtonIcon = self.dropdownButtonIcon
    dropdownButtonIcon:SetPoint("TOPRIGHT", mainIconWidget, "TOPRIGHT")
    dropdownButtonIcon:SetPoint("BOTTOMLEFT", mainIconWidget, "TOPRIGHT", -self:GetWidth()/10,-self:GetHeight()/10)

end

function IconDropdownMixin:ToggleDropdownVisibility()
    local buttons = self.childButtons
    for i = 1,#buttons do
        if self.isShowingOptions then
            buttons[i]:Hide()
        else
            buttons[i]:Show()
        end
    end

    self.isShowingOptions = not self.isShowingOptions
end

function IconDropdownMixin:AddOption(icon, name)
    local height = self:GetHeight()
    local children = self.childButtons
    local newButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
    newButton["iconName"] = name
    newButton["iconPath"] = icon
    newButton:SetSize(self:GetSize())
    newButton:SetScript("OnClick", CallbackButtonClick)
    newButton:SetFrameStrata("FULLSCREEN")

    -- Special case when no other children
    local relWidget = nil
    if #children == 0 then
        relWidget = self.mainIcon
        self.activeOption = newButton --Default active option to first option
        self.mainIcon:SetNormalTexture(icon)
    else
        relWidget = children[#children]
    end

    newButton:SetPoint("TOPLEFT", relWidget, "BOTTOMLEFT", 0, 0)
    newButton:SetPoint("BOTTOMRIGHT", relWidget, "BOTTOMRIGHT", 0, -self:GetHeight())
    newButton:SetNormalTexture(icon)
    newButton:Hide()
    -- newButton:Show()
    table.insert(self.childButtons, newButton)
end

function IconDropdownMixin:SetActiveOption(name)
    local childButtons = self.childButtons
    local buttonWidget = nil
    for i = 1,#childButtons do
        if childButtons[i].iconName == name then
            buttonWidget = childButtons[i]
            break
        end
    end

    if buttonWidget then
        self.activeOption = buttonWidget
        local mainIconWidget = self.mainIcon
        mainIconWidget:SetNormalTexture(buttonWidget.iconPath)

        if self.isShowingOptions == true then
            CallbackMainIconClick(mainIconWidget)
        end
    end
end

function IconDropdownMixin:GetActiveOption()
    if self.activeOption then
        return self.activeOption["iconName"]
    else
        return nil
    end
end