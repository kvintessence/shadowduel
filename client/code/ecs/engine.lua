local class = require("lib/middleclass")

local module = {}

module.Engine = class('ecs/Engine')

function module.Engine:initialize()
    self.__entities__ = {}
    self.__systems__ = {}
end

function module.Engine:addSystem(newSystem)
    newSystem.engine = self
    self.__systems__[newSystem] = true
end

function module.Engine:removeSystem(systemToBeRemoved)
    systemToBeRemoved.engine = nil
    self.__systems__[systemToBeRemoved] = nil
end

function module.Engine:addEntity(newEntity)
    self.__entities__[newEntity] = true
end

function module.Engine:removeEntity(entityToBeRemoved)
    self.__entities__[entityToBeRemoved] = nil
end

function module.Engine:update(delta)
    for system, _ in pairs(self.__systems__) do
        local filteredComponents = self.entitiesWithComponents(system:componentTypes())
        system:update(filteredComponents, delta)
    end
end

function module.Engine:entitiesWithComponent(component)
    return self:entitiesWithComponents({ component })
end

function module.Engine:entitiesWithComponents(components)
    local result = {}

    for entity, _ in pairs(self.__entities__) do
        if entity:has(unpack(components)) then table.insert(result, entity) end
    end

    return result
end

return module
