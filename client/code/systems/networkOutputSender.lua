local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")
local json = require("lib/json")

local globals = require("code/globals")

local NetworkOutput = require("code/components/networkOutput").NetworkOutput

local module = {}

module.NetworkOutputSenderSystem = tinyECS.processingSystem(class('systems/networkOutputSender'))

function module.NetworkOutputSenderSystem:filter(entity)
    return entity[NetworkOutput]
end

function module.NetworkOutputSenderSystem:process(entity)
    local name = entity[NetworkOutput].name
    if not name or not globals.socket then
        return
    end

    for _, component in ipairs(entity[NetworkOutput].sync) do
        if entity[component] and entity[component].serialize then
            local serializedData = entity[component]:serialize()
            serializedData.entityName = name
            serializedData.componentName = component.name

            local result, errorMessage = globals.socket:send(json:encode(serializedData) .. "\n")
            if not result then
                print("Couldn't send data: ", errorMessage)
            end
        end
    end
end

return module
