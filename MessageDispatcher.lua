_,Core = ...
local ThatsMyBuff = Core.ThatsMyBuff

local MessageDispatcher = {}
Core.MessageDispatcher = MessageDispatcher

MessageDispatcher.registeredMessages = {}
--@param messageName string
--@param functionCb function(payload)
function MessageDispatcher:RegisterMessage(messageName, functionCb)
    local registration = {}
    registration.messageName = messageName
    registration.functionCb = functionCb
    table.insert(self.registeredMessages,registration)
end

--@param messageName string
--@param payload table
function MessageDispatcher:SendMessage(messageName, payload)
    local registeredMessages = self.registeredMessages
    for i = 1,#registeredMessages do
        local registration = registeredMessages[i]
        if messageName == registration.messageName then
            registration.functionCb(payload)
        end
    end
end