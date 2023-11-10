IconDropdownMixin = {}

function IconDropdownMixin:test()
    print("Hello world!")
end

function IconDropdownMixin:SetActiveOption(name)
    -- print("Setting option to " .. name)
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
        local mainIconWidget = self.mainIconWidget
        mainIconWidget:SetNormalTexture(buttonWidget.iconPath)
        -- I tried just using GetNormalTexture from the buttonwidget, but that
        -- just returned the unchanged vanilla button texture.

        if self.stateIsPressed == true then
            ToggleDropdownMenu(mainIconWidget)
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

function IconDropdownMixin:AddOption(icon, name)
    -- print("Adding ", name, "with icon", icon)
    local children = self.childButtons

    local globalName = self:GetName() .. "_button_" .. #children
    local newButton = CreateFrame("Button", globalName, self, "IconDropdownIconButtonTemplate")
    newButton["iconName"] = name
    newButton["iconPath"] = icon
    local height = self:GetHeight()

    -- Special case when no other children
    newButton:SetSize(self:GetSize())
    local parent = nil
    if #children == 0 then
        parent = self
        self.activeOption = newButton
    else
        parent = children[#children]
    end
    newButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, height)
    newButton:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, 0)
    newButton:SetNormalTexture(icon)
    -- print(name .. " texture ", newButton:GetNormalTexture())
    newButton:Hide()
    table.insert(self.childButtons, newButton)
end

function IconDropdownHandleButtonClick(self)
    print("An icon dropdown button was clicked", self, self.iconName)
    self:GetParent():SetActiveOption(self["iconName"])
end

function IconDropdownInitialize(self)
    self.childButtons = {}
    self.stateIsPressed = false
    self.activeOption = nil
    local children = { self:GetChildren() }
    local searchName = self:GetName() .. "_mainIcon"
    local mainIconWidget = nil
    for _, child in ipairs(children) do
        if child:GetName() == searchName then
            mainIconWidget = child
            break
        end
    end
    self.mainIconWidget = mainIconWidget
end

function ToggleDropdownMenu(self)
    local IconDropdown = self:GetParent()
    local stateIsPressed = IconDropdown.stateIsPressed

    if stateIsPressed == false then
        -- print("Show")
        for i = 1,#IconDropdown.childButtons do
            IconDropdown.childButtons[i]:Show()
            -- print("Showbutton")
        end
    else
        -- print("Hide")
        for i = 1,#IconDropdown.childButtons do
            IconDropdown.childButtons[i]:Hide()
            -- print("Showbutton")
        end
    end
    IconDropdown.stateIsPressed = not stateIsPressed
end

function IconDropdownResizeElements(self)
    print("Resize")
    local mainIconWidget = self.mainIconWidget
    local childButtons = self.childButtons
    mainIconWidget:SetSize(self:GetSize())
    local lastButton = mainIconWidget
    for i = 1,#childButtons do
        local buttonWidget = childButtons[i]
        buttonWidget:SetPoint("TOPLEFT", lastButton, "TOPLEFT", 0, self:GetHeight())
        buttonWidget:SetPoint("BOTTOMRIGHT", lastButton, "TOPRIGHT", 0, 0)
        -- print(i)
    end
    print("Resize Done")
end