AceComms = LibStub("AceComm-3.0")
AceSerial = LibStub("AceSerializer-3.0")
_, Core = ...
Core.Comms = {}
local AddonComms = Core.Comms
local Prefix = "TMB_Updates"
--[[

    TODO

    1. Add event register for tracking player entering group/raid
        Need to have way to track change from party to raid

]]--

-- local CommChannel = "RAID"
local CommChannel = "RAID"

local function autoSetCommChannel()
    if IsInRaid() then
        CommChannel = "RAID"
    elseif IsInGroup() then
        CommChannel = "PARTY"
    else
        CommChannel = "SAY"
    end
end

local registeredEvents = {}
local function handleEventFromOtherClient(prefix, message, distribution, sender)
    local success, data = AceSerial:Deserialize(message)
    if success then
        if data["event"] then
            data["prefix"] = prefix
            data["distribution"] = distribution
            data["sender"] = sender
            for i = 1,#registeredEvents do
                if registeredEvents[i]["eventFilter"] == data["event"] then
                    registeredEvents[i]["callback"](data)
                end
            end
        end
    end
end

------------------------
-- Wow API Event Handling
------------------------
local function handleBlizzEvents(self, event, ...)
    -- print("event!")
    if event == "RAID_ROSTER_UPDATE" then
        print("Raid roster update")
    elseif event == "PARTY_LEADER_CHANGED" then
        -- print("Party leader changed")
    elseif event == "PARTY_MEMBERS_CHANGED" then
        -- print("Raid members changed")
    elseif event == "PLAYER_STARTED_MOVING" then
        -- print("Player started moving")
    else
        -- print("Some other event", event)
    end
end

local frame = CreateFrame("Frame")
AddonComms.frame = frame

frame:RegisterEvent("RAID_ROSTER_UPDATE")
-- frame:RegisterEvent("PARTY_CONVERTED_TO_RAID")
frame:RegisterEvent("PARTY_LEADER_CHANGED")
-- frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
-- frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
-- frame:RegisterEvent("PLAYER_STARTED_MOVING")
frame:SetScript("OnEvent", function(self, event, ...) handleBlizzEvents(self, event, ...) end)


------------------------
-- Addon Communication
------------------------
AceComms:RegisterComm("TMB_Updates", handleEventFromOtherClient)

------------------------
-- Mixin Functions
------------------------
--@param eventFilter string
--@param eventFilter function(table)
function AddonComms:RegisterEvent(eventFilter, callbackFcn)
    local registration = {eventFilter=eventFilter, callback=callbackFcn}
    registeredEvents[#registeredEvents+1] = registration
end

--@param eventFilter string
--@param payloadTable table
function AddonComms:SendEvent(eventFilter, payloadTable)
    payloadTable["event"] = eventFilter
    local serialized_data = AceSerial:Serialize(payloadTable)
    AceComms:SendCommMessage(Prefix, serialized_data, CommChannel)
end


--[[
    Potential events

    PARTY_CONVERTED_TO_RAID
    PARTY_LEADER_CHANGED
    PARTY_MEMBERS_CHANGED       may be firing excessive events, see api reference
    RAID_ROSTER_UPDATE          may be better than PARTY_MEMBERS_CHANGED
]]