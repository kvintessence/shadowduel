local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")
local json = require("lib/json")

local globals = require("code/globals")

local Position = require("code/components/position").Position
local PhysicalBody = require("code/components/physicalBody").PhysicalBody
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

    if entity[Position] then
        local x, y = entity[Position]:get()
        local rotation = entity[Position].rotation
        local encodedData = json:encode({
            name = name,
            component = "Position",
            x = x,
            y = y,
            rotation = rotation,
        })

        local result, errorMessage = globals.socket:send(encodedData .. "\n")
        if not result then
            print("Couldn't send data: ", errorMessage)
        end
    end

    if entity[PhysicalBody] then
        local collider = entity[PhysicalBody].collider
        local linearVelocityX, linearVelocityY = collider:getLinearVelocity()

        local encodedData = json:encode({
            name = name,
            component = "PhysicalBody",
            x = collider:getX(),
            y = collider:getY(),
            linearVelocityX = linearVelocityX,
            linearVelocityY = linearVelocityY,
        })

        local result, errorMessage = globals.socket:send(encodedData .. "\n")
        if not result then
            print("Couldn't send data: ", errorMessage)
        end
    end
end

return module
