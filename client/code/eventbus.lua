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
    table.insert(eventHandlers, utility.createWeakRef(handler))
end

function eventBus.EventBus:post(eventName)
    local eventHandlers = self:__handlersForEventName__(eventName)

    for key, handlerWeakRef in pairs(eventHandlers) do
        local handler = handlerWeakRef()

        if handler then
            handler()
        else
            eventHandlers[key] = nil
        end
    end
end

eventBus.default = eventBus.EventBus:new()

return eventBus
