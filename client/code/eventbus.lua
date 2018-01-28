local class = require("lib/middleclass")
local utility = require("code/utility")

local eventBus = {}

eventBus.EventBus = class('EventBus')

function eventBus.EventBus:initialize()
    self.__handlers__ = {}
end

function eventBus.EventBus:__handlersForEventName__(eventName)
    self.__handlers__[eventName] = self.__handlers__[eventName] or {}
    return self.__handlers__[eventName]
end

function eventBus.EventBus:subscribe(eventName, handler)
    local eventHandlers = self:__handlersForEventName__(eventName)
    eventHandlers[#eventHandlers + 1] = utility.createWeakRef(handler)
end

function eventBus.EventBus:post(eventName)
    local eventHandlers = self:__handlersForEventName__(eventName)

    for index, handlerWeakRef in ipairs(eventHandlers) do
        local handler = handlerWeakRef()

        if handler then
            handler()
        else
            eventHandlers[index] = nil
        end
    end
end

eventBus.default = eventBus.EventBus:new()

return eventBus
