local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")
local json = require("lib/json")

local globals = require("code/globals")

local Position = require("code/components/position").Position
local PhysicalBody = require("code/components/physicalBody").PhysicalBody
local NetworkInput = require("code/components/networkInput").NetworkInput

local module = {}

module.NetworkInputReceiverSystem = tinyECS.system(class('systems/networkInputReceiver'))

function module.NetworkInputReceiverSystem:initialize()
    self.entitiesByName = {}
end

function module.NetworkInputReceiverSystem:filter(entity)
    return entity[NetworkInput]
end

function module.NetworkInputReceiverSystem:onAdd(entity)
    local name = entity[NetworkInput].name

    if name then
        self.entitiesByName[name] = entity
    end
end

function module.NetworkInputReceiverSystem:onRemove(entity)
    local name = entity[NetworkInput].name

    if name then
        self.entitiesByName[name] = nil
    end
end

function module.NetworkInputReceiverSystem:update()
    if not globals.socket then
        return
    end

    while true do
        :: networkStart ::

        local data, networkError = globals.socket:receive()
        if not data then
            if networkError ~= "timeout" then
                print("Couldn't receive network data: ", networkError)
            end
            return
        end

        local decodedData, jsonError = json:decode(data)
        if not decodedData then
            print("Couldn't decode json: ", jsonError)
            goto networkStart
        end

        local entity = self.entitiesByName[decodedData.entityName]
        if not entity then
            print("Got info about non-existent entity: ", decodedData.entityName)
            goto networkStart
        end

        local component = entity[NetworkInput]:componentByName(decodedData.componentName)
        if component and entity[component] then
            entity[component]:deserialize(decodedData)
        end
    end
end

return module
