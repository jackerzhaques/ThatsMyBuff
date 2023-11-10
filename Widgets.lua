_, Core = ...
local ThatsMyBuff = Core.ThatsMyBuff
local IconDropdown = Core.IconDropdown
local MessageDispatcher = Core.MessageDispatcher
local PallyBuffs = Core.PallyBuffs

local Widgets = {}
Core.Widgets = Widgets
local ShamanWidget = {}
ShamanWidget.EventName = "ShamanTotemUpdate"
Widgets.ShamanWidget = ShamanWidget
local PaladinWidget = {}
PaladinWidget.EventNameAura = "PaladinAuraUpdate"
PaladinWidget.EventNameJudgement = "PaladinJudgementUpdate"
PaladinWidget.EventNameBlessing = "PaladinBlessingUpdate"
Widgets.PaladinWidget = PaladinWidget
local PaladinHeaderWidget = {}
Widgets.PaladinHeaderWidget = PaladinHeaderWidget



--[[
    TODO

    Add a display for the actual shaman totems selected
    Maybe a smaller icon above the totem dropdown, and make it glow if it doesn't match
]]
function ShamanWidget:DropdownOptionClicked(buttonWidget)
    local payload = {name=self.shamanName, totemType=self.totemType, totemName=buttonWidget.iconName}
    MessageDispatcher:SendMessage(ShamanWidget.EventName, payload)
end

function ShamanWidget:Create(name, parentWidget, relativeWidget)
    local shaman = {}
    shaman.name = name
    local playerLabel = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
    playerLabel:SetPoint("TOPLEFT", relativeWidget, "BOTTOMLEFT", 0, -30)
    playerLabel:SetText(name)
    shaman.titleWidget = playerLabel

    -- EARTH
    local earthDropdown = IconDropdown:Create(nil, parentWidget, 60, 60, self.DropdownOptionClicked)
    earthDropdown.shamanName = name
    earthDropdown.totemType = "earth"
    earthDropdown:SetSize(30,30)
    earthDropdown:SetPoint("LEFT", playerLabel, "LEFT", 90, 0)
    local earthTotems = TotemTableEarth
    for totemIdx = 1,#earthTotems do
        local totem = earthTotems[totemIdx]
        earthDropdown:AddOption(totem["icon"], totem["name"])
    end
    shaman.earthDropdown = earthDropdown

    -- FIRE
    local fireDropdown = IconDropdown:Create(nil, parentWidget, 60, 60, self.DropdownOptionClicked)
    fireDropdown.shamanName = name
    fireDropdown.totemType = "fire"
    fireDropdown:SetSize(30,30)
    fireDropdown:SetPoint("LEFT", earthDropdown, "RIGHT", 30, 0)
    local fireTotems = TotemTableFire
    for totemIdx = 1,#fireTotems do
        local totem = fireTotems[totemIdx]
        fireDropdown:AddOption(totem["icon"], totem["name"])
    end
    shaman.fireDropdown = fireDropdown

    -- WATER
    local waterDropdown = IconDropdown:Create(nil, parentWidget, 60, 60, self.DropdownOptionClicked)
    waterDropdown.shamanName = name
    waterDropdown.totemType = "water"
    waterDropdown:SetSize(30,30)
    waterDropdown:SetPoint("LEFT", fireDropdown, "RIGHT", 30, 0)
    local waterTotems = TotemTableWater
    for totemIdx = 1,#waterTotems do
        local totem = waterTotems[totemIdx]
        waterDropdown:AddOption(totem["icon"], totem["name"])
    end
    shaman.waterDropdown = waterDropdown

    -- AIR
    local airDropdown = IconDropdown:Create(nil, parentWidget, 60, 60, self.DropdownOptionClicked)
    airDropdown.shamanName = name
    airDropdown.totemType = "air"
    airDropdown:SetSize(30,30)
    airDropdown:SetPoint("LEFT", waterDropdown, "RIGHT", 30, 0)
    local airTotems = TotemTableAir
    for totemIdx = 1,#airTotems do
        local totem = airTotems[totemIdx]
        airDropdown:AddOption(totem["icon"], totem["name"])
    end
    shaman.airDropdown = airDropdown

    return shaman
end

-- TODO: Implement
function PaladinWidget:DropdownOptionClicked(buttonWidget)
    local buffType = self.buffType
    local pallyName = self.paladinName
    local payload = {
        name=pallyName, 
        buffType=buffType, 
        buffName = buttonWidget.iconName,
        buffIdx = self.blessingIdx,
    }
    print("Received buff change for", pallyName, "on buff type", buffType, "with name:", buttonWidget.iconName)

    MessageDispatcher:SendMessage(buffType, payload)

    -- local payload = {name=self.shamanName, totemType=self.totemType, totemName=buttonWidget.iconName}
    -- MessageDispatcher:SendMessage(ShamanWidget.EventName, payload)
end

function PaladinWidget:Create(name, parentWidget, relativeWidget, numEntries, margin, spacing)
    local iconSize = 30
    local paladin = {}

    local title = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
    title:SetPoint("TOPLEFT", relativeWidget, "BOTTOMLEFT", 0, -30)
    title:SetText(name)
    paladin.titleWidget = title

    local dropdowns = {}
    local lastWidget = nil
    for i = 1,numEntries do
        local dropdown = IconDropdown:Create(nil, parentWidget, iconSize, iconSize, self.DropdownOptionClicked)
        dropdown.setName = i
        dropdown.paladinName = name
        dropdown.blessingIdx = i
        if lastWidget == nil then
            dropdown:SetPoint("CENTER", relativeWidget, "BOTTOMLEFT", margin, -30)
        else
            dropdown:SetPoint("CENTER", lastWidget, "CENTER", spacing, 0)
        end

        if i == 1 then
            local auras = AuraTableAll
            for buffIdx = 1,#auras do
                local aura = auras[buffIdx]
                dropdown:AddOption(aura["icon"], aura["name"])
                dropdown.buffType = PaladinWidget.EventNameAura
            end
        elseif i == 2 then
            local judgements = JudgementTableAll
            for buffIdx = 1,#judgements do
                local judgement = judgements[buffIdx]
                dropdown:AddOption(judgement["icon"], judgement["name"])
                dropdown.buffType = PaladinWidget.EventNameJudgement
            end
        else
            local buffs = BlessingTableAll
            for buffIdx = 1,#buffs do
                local buff = buffs[buffIdx]
                dropdown:AddOption(buff["icon"], buff["name"])
                dropdown.buffType = PaladinWidget.EventNameBlessing
            end
        end

        lastWidget = dropdown
        table.insert(dropdowns, dropdown)
    end
    paladin.dropdowns = dropdowns
    
    return paladin
end

-- TODO: Move all icon paths to a globals file
local iconPathRestoDruid = "BlizzardInterfaceArt\\Interface\\ICONS\\Ability_Druid_TreeofLife.blp"
local iconPathDruid = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Druid.blp"
local iconPathBalanceDruid = "BlizzardInterfaceArt\\Interface\\ICONS\\ability_druid_improvedmoonkinform.blp"
local iconPathFeralDruid = "BlizzardInterfaceArt\\Interface\\ICONS\\Ability_Druid_CatForm.blp"
local iconPathHunter = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Hunter.blp"
local iconPathMage = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Mage.blp"
local iconPathPaladin = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Paladin.blp"
local iconPathRetPaladin = "BlizzardInterfaceArt\\Interface\\ICONS\\Spell_Holy_AuraOfLight.blp"
local iconPathHolyPaladin = "BlizzardInterfaceArt\\Interface\\ICONS\\Spell_Holy_HolyBolt.blp"
local iconPathProtPaladin = "BlizzardInterfaceArt\\Interface\\ICONS\\SPELL_HOLY_DEVOTIONAURA.blp"
local iconPathPriest = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Priest.blp"
local iconPathRogue = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Rogue.blp"
local iconPathShaman = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Shaman.blp"
local iconPathShamanEnhance = "BlizzardInterfaceArt\\Interface\\ICONS\\Ability_Shaman_Stormstrike.blp"
local iconPathWarlock = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Warlock.blp"
local iconPathWarrior = "BlizzardInterfaceArt\\Interface\\ICONS\\ClassIcon_Warrior.blp"
local iconPathJudgements = "BlizzardInterfaceArt\\Interface\\ICONS\\ability_paladin_judgementofthepure.blp"
local iconPathAuraGeneric = "BlizzardInterfaceArt\\Interface\\ICONS\\Spell_Holy_AuraMastery.blp"
local iconPathGreaterMight = "BlizzardInterfaceArt\\Interface\\ICONS\\Spell_Holy_GreaterBlessingofKings.blp"

--@param parentWidget
--@param relativeWidget Frame
--@param numIcons number
--@return table
function PaladinHeaderWidget:Create(parentWidget, relativeWidget, numIcons)
    -- TODO: Make these configurable parameters instead
    local iconMargin = 150
    local iconMarginRight = 40
    local iconSize = 30
    local iconSpacing = (parentWidget:GetWidth() - iconMargin - iconMarginRight) / (numIcons-1)
    print("parent", parentWidget:GetWidth())
    
    local paladinHeader = {}
    paladinHeader.iconMargin = iconMargin
    paladinHeader.iconSize = iconSize
    paladinHeader.iconSpacing = iconSpacing

    local iconAura = parentWidget:CreateTexture()
    iconAura:SetPoint("TOPLEFT", relativeWidget, "BOTTOMLEFT", iconMargin-iconSize/2, -20)
    iconAura:SetSize(iconSize, iconSize)
    iconAura:SetTexture(iconPathAuraGeneric)
    paladinHeader.iconAura = iconAura

    local iconJudgements = parentWidget:CreateTexture()
    iconJudgements:SetPoint("CENTER", iconAura, "CENTER", iconSpacing, 0)
    iconJudgements:SetSize(iconSize, iconSize)
    iconJudgements:SetTexture(iconPathJudgements)
    paladinHeader.iconJudgements = iconJudgements

    local iconAssignAll = parentWidget:CreateTexture()
    iconAssignAll:SetPoint("CENTER", iconJudgements, "CENTER", iconSpacing, 0)
    iconAssignAll:SetSize(iconSize, iconSize)
    iconAssignAll:SetTexture(iconPathGreaterMight)
    paladinHeader.iconAssignAll = iconAssignAll

    local iconDruidFeral = parentWidget:CreateTexture()
    -- iconDruidFeral:SetPoint("TOPLEFT", relativeWidget, "BOTTOMLEFT", iconMargin-iconSize/2, -20)
    iconDruidFeral:SetPoint("CENTER", iconAssignAll, "CENTER", iconSpacing, 0)
    iconDruidFeral:SetSize(iconSize, iconSize)
    iconDruidFeral:SetTexture(iconPathRestoDruid)
    paladinHeader.druidFeral = iconDruidFeral

    local iconDruidResto = parentWidget:CreateTexture()
    iconDruidResto:SetPoint("CENTER", iconDruidFeral, "CENTER", iconSpacing, 0)
    iconDruidResto:SetSize(iconSize, iconSize)
    iconDruidResto:SetTexture(iconPathFeralDruid)
    paladinHeader.druidResto = iconDruidResto
    
    local iconDruidBoomie = parentWidget:CreateTexture()
    iconDruidBoomie:SetPoint("CENTER", iconDruidResto, "CENTER", iconSpacing, 0)
    iconDruidBoomie:SetSize(iconSize, iconSize)
    iconDruidBoomie:SetTexture(iconPathBalanceDruid)
    paladinHeader.druidBoomkin = iconDruidBoomie

    local text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Druid")
    local x = (2*iconSpacing + iconSize)/2
    local y = 10
    text:SetPoint("CENTER", iconDruidFeral, "TOPLEFT", x, y)
    paladinHeader.druidtext = text

    local iconHunter = parentWidget:CreateTexture()
    iconHunter:SetPoint("CENTER", iconDruidBoomie, "CENTER", iconSpacing, 0)
    iconHunter:SetSize(iconSize, iconSize)
    iconHunter:SetTexture(iconPathHunter)
    paladinHeader.hunter = iconHunter

    text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Hunter")
    x = iconSize/2
    y = 10
    text:SetPoint("CENTER", iconHunter, "TOPLEFT", x, y)
    paladinHeader.druidtext = text

    local iconMage = parentWidget:CreateTexture()
    iconMage:SetPoint("CENTER", iconHunter, "CENTER", iconSpacing, 0)
    iconMage:SetSize(iconSize, iconSize)
    iconMage:SetTexture(iconPathMage)
    paladinHeader.mage = iconMage

    text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Mage")
    x = iconSize/2
    y = 10
    text:SetPoint("CENTER", iconMage, "TOPLEFT", x, y)
    paladinHeader.mageText = text

    local iconPaladin = parentWidget:CreateTexture()
    iconPaladin:SetPoint("CENTER", iconMage, "CENTER", iconSpacing, 0)
    iconPaladin:SetSize(iconSize, iconSize)
    iconPaladin:SetTexture(iconPathPaladin)
    paladinHeader.paladin = iconPaladin

    local iconPaladinHoly = parentWidget:CreateTexture()
    iconPaladinHoly:SetPoint("CENTER", iconPaladin, "CENTER", iconSpacing, 0)
    iconPaladinHoly:SetSize(iconSize, iconSize)
    iconPaladinHoly:SetTexture(iconPathHolyPaladin)
    paladinHeader.paladinHoly = iconPaladinHoly

    text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Paladin")
    x = iconSize/2 + iconSpacing/2
    y = 10
    text:SetPoint("CENTER", iconPaladin, "TOPLEFT", x, y)
    paladinHeader.paladinText = text

    local iconPriest = parentWidget:CreateTexture()
    iconPriest:SetPoint("CENTER", iconPaladinHoly, "CENTER", iconSpacing, 0)
    iconPriest:SetSize(iconSize, iconSize)
    iconPriest:SetTexture(iconPathPriest)
    paladinHeader.priest = iconPriest

    text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Priest")
    x = iconSize/2
    y = 10
    text:SetPoint("CENTER", iconPriest, "TOPLEFT", x, y)
    paladinHeader.priestText = text

    local iconRogue = parentWidget:CreateTexture()
    iconRogue:SetPoint("CENTER", iconPriest, "CENTER", iconSpacing, 0)
    iconRogue:SetSize(iconSize, iconSize)
    iconRogue:SetTexture(iconPathRogue)
    paladinHeader.rogue = iconRogue

    text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Rogue")
    x = iconSize/2
    y = 10
    text:SetPoint("CENTER", iconRogue, "TOPLEFT", x, y)
    paladinHeader.rogueText = text

    local iconShaman = parentWidget:CreateTexture()
    iconShaman:SetPoint("CENTER", iconRogue, "CENTER", iconSpacing, 0)
    iconShaman:SetSize(iconSize, iconSize)
    iconShaman:SetTexture(iconPathShaman)
    paladinHeader.shaman = iconShaman

    local iconShamanEnh = parentWidget:CreateTexture()
    iconShamanEnh:SetPoint("CENTER", iconShaman, "CENTER", iconSpacing, 0)
    iconShamanEnh:SetSize(iconSize, iconSize)
    iconShamanEnh:SetTexture(iconPathShamanEnhance)
    paladinHeader.shamanEnhance = iconShamanEnh

    text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Shaman")
    x = iconSize/2 + iconSpacing/2
    y = 10
    text:SetPoint("CENTER", iconShaman, "TOPLEFT", x, y)
    paladinHeader.shamanText = text

    local iconWarlock = parentWidget:CreateTexture()
    iconWarlock:SetPoint("CENTER", iconShamanEnh, "CENTER", iconSpacing, 0)
    iconWarlock:SetSize(iconSize, iconSize)
    iconWarlock:SetTexture(iconPathWarlock)
    paladinHeader.warlock = iconWarlock

    text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Warlock")
    x = iconSize/2
    y = 10
    text:SetPoint("CENTER", iconWarlock, "TOPLEFT", x, y)
    paladinHeader.warlockText = text

    local iconWarrior = parentWidget:CreateTexture()
    iconWarrior:SetPoint("CENTER", iconWarlock, "CENTER", iconSpacing, 0)
    iconWarrior:SetSize(iconSize, iconSize)
    iconWarrior:SetTexture(iconPathWarrior)
    paladinHeader.warrior = iconWarrior

    text = parentWidget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    text:SetText("Warrior")
    x = iconSize/2
    y = 10
    text:SetPoint("CENTER", iconWarrior, "TOPLEFT", x, y)
    paladinHeader.warriorText = text

    local horizontalBar = parentWidget:CreateTexture()
    horizontalBar:SetColorTexture(1,1,1)
    horizontalBar:SetPoint("TOPLEFT", relativeWidget, 0, -70)
    horizontalBar:SetSize(parentWidget:GetWidth(), 2)
    paladinHeader.horizontalBar = horizontalBar

    return paladinHeader
end

local HorizontalLayout = {}
local VerticalLayout = {}
local GridLayout = {}
Widgets.HorizontalLayout = HorizontalLayout
Widgets.VerticalLayout = VerticalLayout
Widgets.GridLayout = GridLayout

local function ResizeLayout(self)
    self:Resize()
end

--@param parentWidget Frame
--@return Frame
function HorizontalLayout:Create(parentWidget)
    local widget = CreateFrame("Frame", nil, parentWidget)
    widget.padding = 0
    widget.margin = 0
    Mixin(widget, HorizontalLayout)
    widget:SetScript("OnSizeChanged", ResizeLayout)
    widget.items = {}
    return widget
end

function HorizontalLayout:Resize()
    local containerHeight = self:GetHeight()
    local totalWidth = self:GetWidth() - (2*self.margin)
    local N = #self.items
    local widthPerObject = (totalWidth - (N-1)*self.padding) / N
    for i = 1,#self.items do
        local item = self.items[i]
        local x = (i-1)*(widthPerObject+self.padding) + self.margin
        item:SetWidth(widthPerObject)
        if item.fixedWidth then
            local extraSpace = widthPerObject - item.fixedWidth
            x = x + extraSpace/2
            item:SetWidth(item.fixedWidth)
        end
        local y = -containerHeight/2
        item:SetPoint("TOPLEFT", self, "TOPLEFT", x, y)
    end
end

function HorizontalLayout:GetMaxHeight()
    local height = 0

    for i = 1,#self.items do
        local item = self.items[i]
        if item:GetHeight() > height then
            height = item:GetHeight()
        end
    end

    return height
end

--@param childWidget Frame
function HorizontalLayout:AddChild(childWidget)
    print("Inserting frame", childWidget, "into position ", #self.items+1)
    table.insert(self.items, childWidget)
    self:Resize()
end

function GridLayout:Create(numRows, numCols, parentWidget)
    local layout = CreateFrame("Frame", nil, parentWidget)
    layout.padding = 0
    layout.margin = 0
    Mixin(layout, HorizontalLayout)
    layout:SetScript("OnSizeChanged", ResizeLayout)
    layout.items = {}
    for row = 1,numRows do
        layout.items[row] = {}
        for col = 1,numCols do
            layout.items[row][col] = {}
        end
    end
    return layout
end

function GridLayout:Resize()
    local containerHeight = self:GetHeight()
    local containerWidth = self:GetWidth()
end