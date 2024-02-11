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
    -- local test = {unit="raid1", name="Bukubuku", class="Shaman"}
    -- table.insert(raidComp, test)
    -- local test = {unit="raid1", name="Shamalama", class="Shaman"}
    -- table.insert(raidComp, test)
    -- for i = 1,7 do
    --     local test = {unit="raid1", name="shamshamsham", class="Shaman"}
    --     table.insert(raidComp, test)
    -- end
    -- test = {unit="raid2", name="Crucial", class="Shaman"}
    -- table.insert(raidComp, test)
    -- test = {unit="raid3", name="Saron", class="Paladin"}
    -- table.insert(raidComp, test)
    -- test = {unit="raid4", name="Shurima", class="Paladin"}
    -- table.insert(raidComp, test)
    -- test = {unit="raid5", name="ScrubPally", class="Paladin"}
    -- table.insert(raidComp, test)
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

    -- Create shaman totem widgets
    local paddingFrame = CreateFrame("Frame", nil, BuffFrame)
    paddingFrame:SetSize(10,1)
    paddingFrame:SetPoint("TOPLEFT", BuffFrame, "TOPLEFT", 0, 0)
    local shamans = {}
    local lastWidget = paddingFrame
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
    local contentFrame = CreateFrame("Frame", nil, SPBuffFrame)
    contentFrame:SetSize(SPBuffFrame:GetWidth() - 30, SPBuffFrame:GetHeight())
    contentFrame:SetPoint("TOPLEFT", SPBuffFrame, "TOPLEFT", 20, -20)

    CreateShamanEntries(contentFrame)
    local nShams = 0
    for i = 1,#raidComp do
        if raidComp[i].class == "Shaman" then
            nShams = nShams + 1
        end
    end
    if nShams == 0 then
        nShams = 1
    end
    local spacing = 44
    local offset = 85
    MainWidget:SetHeight((nShams-1)*spacing + offset)
    MainWidget:Show()
end

function ThatsMyBuff:OnInitialize()
    -- print("Init")
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
    -- print("Done")
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
--comment