_, Core = ...
local ThatsMyBuff = Core.ThatsMyBuff

local MainWidget = nil
local IconDropdown = Core.IconDropdown
local Comms = Core.Comms
local Widgets = Core.Widgets
local MessageDispatcher = Core.MessageDispatcher
local raidComp = {}

local BuffUpdateEvent = "BuffUpdate"


--[[

    TODO

    1. Add event register for tracking player entering group/raid.
    2. Update raid comp when player leaves/joins group
    3. Add detection of leader in group, assist privileges
    4. Add protection for changing buffs:
        Perms: Leader decides if assists can change. Leader can check individual persons
    5. 

]]--

local function getRaidComp()
    raidComp = {}
    for i = 1,40 do
        local unit = format("%s%i", 'raid', i)
        local name = GetUnitName(unit)
        local class = UnitClass(unit)
        local unitTable = {unit=unit,name=name,class=class}
        if name ~= nil then
            table.insert(raidComp, unitTable)
        end
    end

    -- Search for party if raid is empty
    if #raidComp == 0 then
        for i = 1,5 do
            local unit = format("%s%i", 'party', i)
            local name = GetUnitName(unit)
            local class = UnitClass(unit)
            local unitTable = {unit=unit,name=name,class=class}
            if name ~= nil then
                table.insert(raidComp, unitTable)
            end
        end
    end

    local unit = "player"
    local name = GetUnitName(unit)
    local class = UnitClass(unit)
    local unitTable = {unit=unit,name=name,class=class}
    if name ~= nil then
        table.insert(raidComp, unitTable)
    end

    -- TESTING ONLY
    local test = {unit="raid1", name="Bukubuku", class="Shaman"}
    table.insert(raidComp, test)
    test = {unit="raid2", name="Crucial", class="Shaman"}
    table.insert(raidComp, test)
    test = {unit="raid3", name="Saron", class="Paladin"}
    table.insert(raidComp, test)
    test = {unit="raid4", name="Shurima", class="Paladin"}
    table.insert(raidComp, test)
    test = {unit="raid5", name="ScrubPally", class="Paladin"}
    table.insert(raidComp, test)
end

local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 20);
	
	if (newValue < 0) then
		newValue = 0;
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange();
	end
	
	self:SetVerticalScroll(newValue);
end

local function handleShamanBuffUpdate(payload)
    if MainWidget == nil then
        return
    end
    local name = payload.name
    local totemType = payload.buff.totemType
    local totemName = payload.buff.totemName
    local shamans = MainWidget.shamanBuffFrame.shamanTable

    local shaman = nil
    for i = 1,#shamans do
        if shamans[i].name == name then
            shaman = shamans[i]
            break
        end
    end

    if shaman then
        local dropdown = nil
        if totemType == "earth" then
            dropdown = shaman.earthDropdown
        elseif totemType == "fire" then
            dropdown = shaman.fireDropdown
        elseif totemType == "water" then
            dropdown = shaman.waterDropdown
        elseif totemType == "air" then
            dropdown = shaman.airDropdown
        else
            return
        end

        dropdown:SetActiveOption(totemName)

        -- If this is the player, update their totems
        if name == UnitName("player") then
            local totemSlot = TotemSlotElementsFire
            if totemType == "earth" then
                totemSlot = TotemSlotElementsEarth
            elseif totemType == "fire" then
                totemSlot = TotemSlotElementsFire
            elseif totemType == "water" then
                totemSlot = TotemSlotElementsWater
            elseif totemType == "air" then
                totemSlot = TotemSlotElementsAir
            end

            Core.Totems:SetPlayerTotemByName(totemSlot, totemName)
        end
    end
end

local function handlePaladinBuffUpdate(payload)
end

local function callbackHandleBuffUpdate(payload)
    local name = payload.name
    local class = payload.class
    if class == "shaman" then
        handleShamanBuffUpdate(payload)
    elseif class == "paladin" then
        handlePaladinBuffUpdate(payload)
    end
end

local function sendBuffUpdate(name, class, buff)
    local payload = {}
    payload.class = class
    payload.name = name
    payload.buff = buff
    Comms:SendEvent(BuffUpdateEvent, payload)
end

local function callbackHandleShamanTotemUpdate(payload)
    local shamanName = payload.name
    local totemType = payload.totemType
    local totemName = payload.totemName
    local buff = {totemType = totemType, totemName = totemName}
    sendBuffUpdate(shamanName, "shaman", buff)

    -- If this is the player, update their totems
    if shamanName == UnitName("player") then
        local totemSlot = TotemSlotElementsFire
        if totemType == "earth" then
            totemSlot = TotemSlotElementsEarth
        elseif totemType == "fire" then
            totemSlot = TotemSlotElementsFire
        elseif totemType == "water" then
            totemSlot = TotemSlotElementsWater
        elseif totemType == "air" then
            totemSlot = TotemSlotElementsAir
        end

        Core.Totems:SetPlayerTotemByName(totemSlot, totemName)
    end
end


local function CreateShamanEntries(parentWidget)
    local BuffFrame = CreateFrame("Frame", nil, parentWidget)
    BuffFrame:SetSize(parentWidget:GetWidth(), 200);
    BuffFrame:SetPoint("TOPLEFT", parentWidget, "TOPLEFT", 0, 0);
    MainWidget.shamanBuffFrame = BuffFrame;

    local title = BuffFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", BuffFrame, "TOPLEFT", 0, 0);
    title:SetText("Shaman Totems");
    BuffFrame.title = title

    -- Create shaman totem widgets
    local shamans = {}
    local lastWidget = title
    for i = 1,#raidComp do
        if raidComp[i].class == "Shaman" then
            local shaman = Widgets.ShamanWidget:Create(raidComp[i].name, BuffFrame, lastWidget)
            lastWidget = shaman.titleWidget
            table.insert(shamans, shaman)
        end
    end
    BuffFrame.shamanTable = shamans

    -- Register totem change event
    MessageDispatcher:RegisterMessage(Widgets.ShamanWidget.EventName, callbackHandleShamanTotemUpdate)

end

local function callbackHandlePaladinAuraUpdate(payload)
    local pallyName = payload.name
    local buffType = payload.buffType
    local buffName = payload.buffName
    local buffIdx = payload.buffIdx
    local buff = {buffType = buffType, buffName = buffName, buffIdx = buffIdx}
    sendBuffUpdate(pallyName, "paladin", buff)
    print("Received pally aura update", pallyName, buffType, buffName, buffIdx)

    if pallyName == UnitName("Player") then
        Core.PallyBuffs.PlayerTable.aura = Core.PallyBuffs:GetAuraByName()
    end

    -- local shamanName = payload.name
    -- local totemType = payload.totemType
    -- local totemName = payload.totemName
    -- local buff = {totemType = totemType, totemName = totemName}
    -- sendBuffUpdate(shamanName, "shaman", buff)

    -- -- If this is the player, update their totems
    -- if shamanName == UnitName("player") then
    --     local totemSlot = TotemSlotElementsFire
    --     if totemType == "earth" then
    --         totemSlot = TotemSlotElementsEarth
    --     elseif totemType == "fire" then
    --         totemSlot = TotemSlotElementsFire
    --     elseif totemType == "water" then
    --         totemSlot = TotemSlotElementsWater
    --     elseif totemType == "air" then
    --         totemSlot = TotemSlotElementsAir
    --     end

    --     Core.Totems:SetPlayerTotemByName(totemSlot, totemName)
    -- end
end

local function callbackHandlePaladinJudgementUpdate(payload)
    local pallyName = payload.name
    local buffType = payload.buffType
    local buffName = payload.buffName
    local buffIdx = payload.buffIdx
    local buff = {buffType = buffType, buffName = buffName, buffIdx = buffIdx}
    sendBuffUpdate(pallyName, "paladin", buff)
    print("Received pally aura update", pallyName, buffType, buffName, buffIdx)

    if pallyName == UnitName("Player") then
        Core.PallyBuffs.PlayerTable.aura = Core.PallyBuffs:GetAuraByName()
    end
end

local function callbackHAndlePaladinBlessingUpdate(payload)
end

local function CreatePaladinEntries(parentWidget)
    local numClassesAndSpecs = 13           -- Number of separate blessing asssignments
    local numIcons = numClassesAndSpecs + 3 -- #+3 for aura/judgement/assignall

    local shamanTable = MainWidget.shamanBuffFrame.shamanTable
    local lastShamanElement = shamanTable[#shamanTable].titleWidget

    local BuffFrame = CreateFrame("Frame", nil, parentWidget)
    BuffFrame:SetSize(parentWidget:GetWidth(), 200);
    BuffFrame:SetPoint("TOPLEFT", lastShamanElement, "BOTTOMLEFT", 0, -30);
    parentWidget.paladinBuffFrame = BuffFrame;

    local title = BuffFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", BuffFrame, "TOPLEFT", 0, 0);
    title:SetText("Paladin Buffs");
    BuffFrame.title = title
    local header = Widgets.PaladinHeaderWidget:Create(BuffFrame, title, numIcons)
    BuffFrame.header = header

    local paladins = {}
    local lastWidget = header.horizontalBar
    for i = 1,#raidComp do
        if raidComp[i].class == "Paladin" then
            local paladin = Widgets.PaladinWidget:Create(raidComp[i].name, BuffFrame, lastWidget, numClassesAndSpecs, header.iconMargin, header.iconSpacing)
            lastWidget = paladin.titleWidget
            table.insert(paladins, paladin)
        end
    end
    BuffFrame.paladinTable = paladins

    -- Update the player's table to have an empty blessing for each spot.
    local playerPallyTable = Core.PallyBuffs.PlayerTable
    playerPallyTable.blessings = {}
    for i = 1,numClassesAndSpecs do
        playerPallyTable.blessings[i] = BlessingNone
    end

    -- Register pally buff change event
    MessageDispatcher:RegisterMessage(Widgets.PaladinWidget.EventNameAura, callbackHandlePaladinAuraUpdate)
    MessageDispatcher:RegisterMessage(Widgets.PaladinWidget.EventNameJudgement, callbackHandlePaladinJudgementUpdate)
    MessageDispatcher:RegisterMessage(Widgets.PaladinWidget.EventNameBlessing, callbackHAndlePaladinBlessingUpdate)


    -- Create grid bars
    local gridBars = {}
    gridBars['horizontal'] = {}
    for i = 1,#paladins-1 do
        local relativeWidget = paladins[i].titleWidget
        local horizontalBar = parentWidget:CreateTexture()
        horizontalBar:SetColorTexture(1,1,1)
        horizontalBar:SetPoint("TOPLEFT", relativeWidget, 0, -20)
        horizontalBar:SetSize(parentWidget:GetWidth(), 1.5)
        table.insert(gridBars['horizontal'], horizontalBar)
    end
    gridBars['vertical'] = {}
    local lastPallyLabel = paladins[#paladins].titleWidget
    local verticalBarIntervals = {0,3,6,7,8,10,11,12,14,15} -- manually set to group by class
    -- local verticalBarIntervals = {0,2,5,6,7}
    for i = 1,#verticalBarIntervals do
        local interval = verticalBarIntervals[i]
        local verticalBar = parentWidget:CreateTexture()
        verticalBar:SetColorTexture(1,1,1)
        local x = header.iconMargin + (interval-0.5)*header.iconSpacing
        x = math.floor(x)
        verticalBar:SetPoint("TOPLEFT", BuffFrame, x, -30)
        verticalBar:SetPoint("BOTTOMRIGHT", lastPallyLabel, "BOTTOMLEFT", x+1.5, -10)
        table.insert(gridBars['vertical'], verticalBar)
    end
end

local function GetFirstFrame(self)
    local frameWidget = nil
    local children = { self:GetChildren() };
    local searchstr = self:GetName() .. "_tabFrame1"
    for _, child in ipairs(children) do
        local childname = child:GetName()
        if childname then
            if string.find(childname, searchstr) and (#childname == #searchstr) then
                frameWidget = child
                break
            end
        end
    end

    return frameWidget
end

local function CreateBuffWindow()
    MainWidget = CreateFrame("Frame", "TMB_MainFrame", UIParent, "TMB_MainWidget")
    local SPBuffFrame = GetFirstFrame(MainWidget)

    local scrollContainer = CreateFrame("ScrollFrame", nil, SPBuffFrame, "UIPanelSCrollFrameTemplate")
    scrollContainer:SetPoint("TOPLEFT", SPBuffFrame, "TOPLEFT", 15, -30)
    scrollContainer:SetPoint("BOTTOMRIGHT", SPBuffFrame, "BOTTOMRIGHT", 0, 10);
    scrollContainer:SetClipsChildren(true)
    scrollContainer:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    scrollContainer.ScrollBar:ClearAllPoints()

    local scrollXOffset = -20
    local scrollYOffset = -45
    local scrollX2Offset = -20
    local scrollY2Offset = 25
    scrollContainer.ScrollBar:SetPoint("TOPLEFT", SPBuffFrame, "TOPRIGHT", scrollXOffset, scrollYOffset)
    scrollContainer.ScrollBar:SetPoint("BOTTOMRIGHT", SPBuffFrame, "BOTTOMRIGHT", scrollX2Offset, scrollY2Offset)
    MainWidget.scrollContainer = scrollContainer

    local scrollChild = CreateFrame("Frame", nil, scrollContainer);
    scrollChild:SetSize(scrollContainer:GetWidth() + scrollXOffset, 500);
    scrollContainer:SetScrollChild(scrollChild)
    MainWidget.scrollChild = scrollChild

    CreateShamanEntries(scrollChild)
    CreatePaladinEntries(scrollChild)
    MainWidget:Show()
end

function ThatsMyBuff:OnInitialize()
    print("Init")
    ------------------------
    -- Initialization before GUI
    ------------------------
    getRaidComp()
    Core.Totems:TotemFetchIcons()
    Core.PallyBuffs:FetchIcons()
    ------------------------
    -- Create GUI
    ------------------------
    CreateBuffWindow()
    Comms:RegisterEvent(BuffUpdateEvent, callbackHandleBuffUpdate)
    print("Done")
end

function ThatsMyBuff:OnDisable()
    print("Disabled!")
end

local function showWidget()
    if MainWidget ~= nil then
        MainWidget:Show()
    end
end

SLASH_SHOW1 = "/show"
SlashCmdList["SHOW"] = showWidget